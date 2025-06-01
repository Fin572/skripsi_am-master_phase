// lib/screens/incident.dart
import 'package:asset_management/screen/models/incident_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:asset_management/screen/incident_detail.dart';
import 'package:asset_management/screen/models/incident_view_screen.dart'; // Import the view screen
import 'package:asset_management/screen/models/location.dart';
import 'package:asset_management/screen/models/asset.dart';
import 'package:asset_management/screen/models/incident_ticket.dart';

class Incident extends StatefulWidget {
  const Incident({Key? key}) : super(key: key);

  @override
  State<Incident> createState() => _IncidentState();
}

class _IncidentState extends State<Incident> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  final List<IncidentTicket> _submittedTickets = [];

  final List<Location> _mockLocations = [
    // Location(id: 'LOC001', name: 'Kantor Pusat Cakung', address: 'Jl. Pertiwi 12', detail: 'Disebelah SPBU', personInCharge: 'Reina', phoneNumber: '081208120812'),
    // Location(id: 'LOC002', name: 'Gudang Barat', address: 'Jl. Industri 45', detail: 'Dekat pabrik', personInCharge: 'Budi', phoneNumber: '081122334455'),
    // Location(id: 'LOC003', name: 'Cabang Selatan', address: 'Jl. Raya Selatan 10', detail: 'Samping minimarket', personInCharge: 'Siti', phoneNumber: '087766554433'),
  ];

  final List<Asset> _mockAssets = [
    Asset(
      id: 'AST001',
      name: 'Server Rack 1',
      locationId: 'LOC001',
      category: 'IT Equipment', // NEW: Example value
      locationInfo: 'Server Room', // NEW: Example value
      latitude: -6.1753924, // NEW: Example value (Monas for Jakarta)
      longitude: 106.8271528, // NEW: Example value
      personInCharge: 'Budi', // NEW: Example value
      phoneNumber: '081234567890', // NEW: Example value
      barcodeData: 'SR001' // NEW: Optional, but good to include if defined
    ),
    Asset(
      id: 'AST002',
      name: 'CCTV Camera 5',
      locationId: 'LOC001',
      category: 'Security', // NEW: Example value
      locationInfo: 'Main Building', // NEW: Example value
      latitude: -6.1753924,
      longitude: 106.8271528,
      personInCharge: 'Andi',
      phoneNumber: '081298765432',
      barcodeData: 'CCTV005'
    ),
    Asset(
      id: 'AST003',
      name: 'Network Switch A',
      locationId: 'LOC002',
      category: 'IT Equipment',
      locationInfo: 'Network Closet',
      latitude: -6.2000, // Different location for variety
      longitude: 106.8500,
      personInCharge: 'Sasa',
      phoneNumber: '081112233445',
      barcodeData: 'NTA001'
    ),
    Asset(
      id: 'AST004',
      name: 'Fire Extinguisher',
      locationId: 'LOC002',
      category: 'Safety',
      locationInfo: 'Hallway',
      latitude: -6.2000,
      longitude: 106.8500,
      personInCharge: 'Dina',
      phoneNumber: '087766554433',
      barcodeData: 'FE004'
    ),
    Asset(
      id: 'AST005',
      name: 'AC Unit 3',
      locationId: 'LOC003',
      category: 'HVAC',
      locationInfo: 'Office 3A',
      latitude: -6.2500, // Different location
      longitude: 106.7500,
      personInCharge: 'Fajar',
      phoneNumber: '089900112233',
      barcodeData: 'ACU003'
    ),
  ];


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<IncidentTicket> _getFilteredTickets() {
    String currentStatus = '';
    switch (_tabController.index) {
      case 0:
        currentStatus = 'Assigned';
        break;
      case 1:
        currentStatus = 'On progress';
        break;
      case 2:
        currentStatus = 'Rejected';
        break;
      case 3:
        currentStatus = 'Done';
        break;
    }

    return _submittedTickets
        .where((ticket) => ticket.status == currentStatus)
        .toList();
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
    List<IncidentTicket> filteredTickets = _getFilteredTickets();

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
                onChanged: (value) {
                  setState(() {
                    // This will trigger a rebuild and re-filter if you implement actual search
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: filteredTickets.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: filteredTickets.length,
                    itemBuilder: (context, index) {
                      final ticket = filteredTickets[index];
                      return _buildTicketCard(ticket);
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: ElevatedButton(
              onPressed: () async {
                final dynamic result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IncidentDetail( // Corrected to IncidentDetail (no 'Screen')
                      availableLocations: _mockLocations,
                      availableAssets: _mockAssets,
                    ),
                  ),
                );

                if (result is IncidentTicket) {
                  setState(() {
                    _submittedTickets.add(result);
                    if (result.status == 'Assigned' && _tabController.index != 0) {
                      _tabController.animateTo(0);
                    }
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
                    // Navigate to IncidentViewScreen and await the result (ticketId if deleted)
                    final dynamic result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IncidentViewScreen(
                          incidentTicket: ticket,
                        ),
                      ),
                    );

                    if (result is String) { // Check if a String (ticketId) was returned, indicating deletion
                      setState(() {
                        _submittedTickets.removeWhere((t) => t.ticketId == result);
                      });
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