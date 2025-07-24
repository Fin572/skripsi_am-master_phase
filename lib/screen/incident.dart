// lib/screens/incident.dart
import 'package:asset_management/screen/models/incident_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:asset_management/screen/incident_detail.dart';
import 'package:asset_management/screen/models/incident_view_screen.dart';
import 'package:asset_management/screen/models/location.dart';
import 'package:asset_management/screen/models/asset.dart';
import 'package:asset_management/screen/models/incident_ticket.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class Incident extends StatefulWidget {
  final bool isAdmin;
  const Incident({Key? key, this.isAdmin = false}) : super(key: key); 
  
  @override
  State<Incident> createState() => _IncidentState();
}

class _IncidentState extends State<Incident> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<IncidentTicket> _assignedTickets = [];
  List<IncidentTicket> _onProgressTickets = [];
  List<IncidentTicket> _rejectedTickets = [];
  List<IncidentTicket> _doneTickets = [];

  bool _isLoadingAssigned = true;
  bool _isLoadingOnProgress = true;
  bool _isLoadingRejected = true;
  bool _isLoadingDone = true;

  String _errorAssigned = '';
  String _errorOnProgress = '';
  String _errorRejected = '';
  String _errorDone = '';

  final List<Location> _mockLocations = [
    // Location(id: 'LOC001', name: 'Kantor Pusat Cakung', address: 'Jl. Pertiwi 12', detail: 'Disebelah SPBU', personInCharge: 'Reina', phoneNumber: '081208120812'),
    // Location(id: 'LOC002', name: 'Gudang Barat', address: 'Jl. Industri 45', detail: 'Dekat pabrik', personInCharge: 'Budi', phoneNumber: '081122334455'),
    // Location(id: 'LOC003', name: 'Cabang Selatan', address: 'Jl. Raya Selatan 10', detail: 'Samping minimarket', personInCharge: 'Siti', phoneNumber: '087766554433'),
  ];

  final List<Asset> _mockAssets = [
    Asset(id: 'AST001', name: 'Server Rack 1', locationId: 'LOC001', category: 'IT Equipment', locationInfo: 'Server Room', latitude: -6.1753924, longitude: 106.8271528, personInCharge: 'Budi', phoneNumber: '081234567890', barcodeData: 'SR001'),
    Asset(id: 'AST002', name: 'CCTV Camera 5', locationId: 'LOC001', category: 'Security', locationInfo: 'Main Building', latitude: -6.1753924, longitude: 106.8271528, personInCharge: 'Andi', phoneNumber: '081298765432', barcodeData: 'CCTV005'),
    Asset(id: 'AST003', name: 'Network Switch A', locationId: 'LOC002', category: 'IT Equipment', locationInfo: 'Network Closet', latitude: -6.2000, longitude: 106.8500, personInCharge: 'Sasa', phoneNumber: '081112233445', barcodeData: 'NTA001'),
    Asset(id: 'AST004', name: 'Fire Extinguisher', locationId: 'LOC002', category: 'Safety', locationInfo: 'Hallway', latitude: -6.2000, longitude: 106.8500, personInCharge: 'Dina', phoneNumber: '087766554433', barcodeData: 'FE004'),
    Asset(id: 'AST005', name: 'AC Unit 3', locationId: 'LOC003', category: 'HVAC', locationInfo: 'Office 3A', latitude: -6.2500, longitude: 106.7500, personInCharge: 'Fajar', phoneNumber: '089900112233', barcodeData: 'ACU003'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _fetchIncidentData();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchIncidentData() async {
    await Future.wait([
      _fetchTickets('assigned', _assignedTickets, (val) => setState(() { _isLoadingAssigned = val; }), (val) => setState(() { _errorAssigned = val; })),
      _fetchTickets('on_progress', _onProgressTickets, (val) => setState(() { _isLoadingOnProgress = val; }), (val) => setState(() { _errorOnProgress = val; })),
      _fetchTickets('rejected', _rejectedTickets, (val) => setState(() { _isLoadingRejected = val; }), (val) => setState(() { _errorRejected = val; })),
      _fetchTickets('done', _doneTickets, (val) => setState(() { _isLoadingDone = val; }), (val) => setState(() { _errorDone = val; })),
    ]);
  }

  Future<void> _fetchTickets(String statusParam, List<IncidentTicket> ticketList, ValueSetter<bool> setLoading, ValueSetter<String> setError) async {
    try {
      // PERBAIKAN: Tambah retry mechanism sederhana hingga 3 kali untuk handle timeout
      http.Response? response; // PERBAIKAN: Ubah dari 'Response?' ke 'http.Response?' untuk definisi class yang benar dari package http
      int retryCount = 0;
      const int maxRetries = 3;
      while (response == null && retryCount < maxRetries) {
        try {
          response = await http.get(Uri.parse('http://assetin.my.id/skripsi/incident_get.php?status=$statusParam')).timeout(const Duration(seconds: 30)); // PERBAIKAN: Tingkatkan timeout dari 10 ke 30 detik
        } catch (e) {
          retryCount++;
          print('Retry $retryCount for status $statusParam due to error: $e');
          if (retryCount >= maxRetries) {
            throw e; // Lempar error jika gagal setelah retry
          }
          await Future.delayed(const Duration(seconds: 2)); // Delay sebelum retry
        }
      }
      print('Response Status: ${response!.statusCode}');
      print('Raw Response Body: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Decoded Response for $statusParam: ${jsonEncode(data)}');
        if (data['status'] == 'success' && data['data'] is List) {
          ticketList.clear();
          ticketList.addAll((data['data'] as List).map((item) {
            print('Raw Item: $item');
            if (item['before_photos'] == null) print('Warning: before_photos is null for item ${item['incident_id']}');
            DateTime parsedDate = DateTime.parse(item['incident_date']);
            String formattedDate = DateFormat('dd MMM yyyy HH:mm:ss').format(parsedDate) + ' WIB';
            final asset = _mockAssets.firstWhere(
                (a) => a.id == (item['asset_id']?.toString() ?? ''),
                orElse: () => Asset(id: item['asset_id']?.toString() ?? '0', name: item['title'] ?? 'Unknown Asset', locationId: item['location_id']?.toString() ?? '0', category: '', locationInfo: '', latitude: 0.0, longitude: 0.0, personInCharge: '', phoneNumber: '', barcodeData: ''),
            );
            final location = _mockLocations.firstWhere(
                (l) => l.id == (item['location_id']?.toString() ?? ''),
                orElse: () => Location(id: item['location_id']?.toString() ?? '0', name: 'Unknown Location'),
            );
            var imageUrls = (item['before_photos'] as List<dynamic>?)?.map((e) {
                  String base64Str = e.toString().trim();
                  if (base64Str.isEmpty) {
                    print('Empty base64 string detected for item ${item['incident_id']}');
                    return null; // Skip empty
                  }
                  if (base64Str.startsWith('data:image/')) {
                    base64Str = base64Str.split(',').last;
                  }
                  base64Str = base64Str.replaceAll('\n', '').replaceAll('\r', '').replaceAll(' ', '');
                  if (base64Str.length < 100) { // Minimal length untuk image valid
                    print('Invalid short base64 string for item ${item['incident_id']}');
                    return null;
                  }
                  // Tambahkan padding jika diperlukan untuk base64 yang valid
                  while (base64Str.length % 4 != 0) {
                    base64Str += '=';
                  }
                  try {
                    base64Decode(base64Str); // Test decode tanpa simpan, untuk verifikasi
                    return base64Str;
                  } catch (error) {
                    print('Error decoding base64 for item ${item['incident_id']}: $error');
                    return null; // Skip jika invalid
                  }
                }).where((s) => s != null).cast<String>().toList() ?? [];
            if (imageUrls.length > 4) {
              imageUrls = imageUrls.sublist(0, 4);
              print('Limited to 4 images for item ${item['incident_id']}');
            }
            final incident = IncidentTicket(
                ticketId: item['incident_id']?.toString() ?? '0',
                asset: asset,
                location: location,
                status: _mapStatusFromDb(item['status'] ?? '', statusParam),
                description: item['description'] ?? '',
                submissionTime: parsedDate,
                imageUrls: imageUrls,
            );
            print('Incident ${incident.ticketId} - Image URLs count: ${incident.imageUrls.length}');
            return incident;
          }).toList());
          setLoading(false);
        } else {
          setError('Invalid data format: ${jsonEncode(data)}');
          setLoading(false);
        }
      } else {
        setError('Server error: ${response.statusCode} - ${response.body}');
        setLoading(false);
      }
    } catch (e, stack) {
      // PERBAIKAN: Pesan error lebih informatif untuk user
      setError('Gagal memuat data: Koneksi timeout atau server tidak responsif. Silakan periksa koneksi internet atau coba lagi nanti. Detail: $e');
      setLoading(false);
      print('Exception in fetch: $e\nStack trace: $stack');
    }
  }

  String _mapStatusFromDb(String dbStatus, String param) {
    if (param == 'assigned') return 'Assigned';
    if (param == 'on_progress') return 'On progress';
    if (param == 'rejected') return 'Rejected';
    if (param == 'done') return 'Done';
    return dbStatus;
  }

  List<IncidentTicket> _getFilteredTickets() {
    List<IncidentTicket> tickets = [];
    switch (_tabController.index) {
      case 0:
        tickets = _assignedTickets;
        break;
      case 1:
        tickets = _onProgressTickets;
        break;
      case 2:
        tickets = _rejectedTickets;
        break;
      case 3:
        tickets = _doneTickets;
        break;
    }
    final search = _searchController.text.toLowerCase();
    return tickets.where((ticket) => ticket.ticketId.toLowerCase().contains(search) || ticket.asset.name.toLowerCase().contains(search)).toList();
  }

  Widget _buildTabContent(bool isLoading, String error, List<IncidentTicket> tickets) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error.isNotEmpty) {
      return Center(child: Text('Error: $error'));
    }
    if (tickets.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return _buildTicketCard(ticket);
      },
    );
  }

  void _showDeletionConfirmationPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1),
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Color(0xFF00796B),
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Attention',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your request has been deleted',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const Align(
                    alignment: Alignment.topRight,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Text(
          "Incident",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: const Image(
          image: AssetImage('assets/bg_image.png'),
          fit: BoxFit.cover,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.blue,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Assigned'),
                Tab(text: 'On progress'),
                Tab(text: 'Rejected'),
                Tab(text: 'Done'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent(_isLoadingAssigned, _errorAssigned, _getFilteredTickets()),
                _buildTabContent(_isLoadingOnProgress, _errorOnProgress, _getFilteredTickets()),
                _buildTabContent(_isLoadingRejected, _errorRejected, _getFilteredTickets()),
                _buildTabContent(_isLoadingDone, _errorDone, _getFilteredTickets()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: ElevatedButton(
              onPressed: () async {
                final dynamic result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IncidentDetailScreen(
                      availableLocations: _mockLocations,
                      availableAssets: _mockAssets,
                    ),
                  ),
                );
                if (result is IncidentTicket) {
                  setState(() {
                    _fetchIncidentData();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ticket ${result.ticketId} submitted!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (result == false) {
                  _showDeletionConfirmationPopup(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(52, 152, 219, 1),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text(
                'Add Ticket',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/nodata.png',
            width: 100,
          ),
          const SizedBox(height: 20),
          const Text('No data'),
        ],
      ),
    );
  }

  Widget _buildTicketCard(IncidentTicket ticket) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ticket ID: ${ticket.ticketId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  ticket.status,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(ticket.status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Asset: ${ticket.asset.name} (${ticket.asset.id})',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              'Location: ${ticket.location.name}',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () async {
                    final dynamic result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IncidentViewScreen(
                          incidentTicket: ticket,
                        ),
                      ),
                    );
                    if (result is String) {
                      _fetchIncidentData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Ticket $result has been deleted.'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                  child: const Row(
                    children: [
                      Text('Detail', style: TextStyle(color: Colors.blue)),
                      Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Assigned':
        return Colors.orange;
      case 'On progress':
        return Colors.blue;
      case 'Rejected':
        return Colors.red;
      case 'Done':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}