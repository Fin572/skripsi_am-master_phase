// lib/screens/invoice_detail.dart
import 'package:asset_management/screen/user_Invoice.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';


class Invoicedetail extends StatefulWidget {
  final String status;
  final int incident_id;
  final InvoiceModel? invoice;
  final void Function(InvoiceModel)? onPaymentConfirmed; // Corrected type in previous step

  const Invoicedetail({
    super.key,
    required this.status,
    required this.incident_id,
    this.invoice,
    this.onPaymentConfirmed,
  });

  @override
  State<Invoicedetail> createState() => _InvoicedetailState();
}

class _InvoicedetailState extends State<Invoicedetail> {
  int _selectedPaymentIndex = 0;
  Uint8List? afterPhotos;
  String locationId = '';
  String assetId = '';
  String title = '';
  String picId = '';
  String description = '';
  String value = '';
  String paymentMethod = '';
  bool isLoading = false;
  bool isPaid = false;

  List<Widget> _carouselImages = [];

  @override
  void initState() {
    super.initState();
    isPaid = widget.status == 'Paid';
    _fetchInvoiceDetail();
  }

  Future<void> _fetchInvoiceDetail() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('http://assetin.my.id/skripsi/get_invoices_detail.php?incident_id=${widget.incident_id}'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            locationId = data['location_id']?.toString() ?? '';
            assetId = data['asset_id']?.toString() ?? '';
            title = data['title']?.toString() ?? '';
            picId = data['pic_id']?.toString() ?? '';
            description = data['description']?.toString() ?? '';
            value = data['value']?.toString() ?? '';
            paymentMethod = data['payment_method']?.toString() ?? '';
            if (data['after_photos'] != null && data['after_photos'].isNotEmpty) {
              afterPhotos = base64Decode(data['after_photos']);
              _carouselImages = [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(afterPhotos!, fit: BoxFit.cover, width: double.infinity),
                )
              ];
            } else {
              _carouselImages = [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Center(child: Text('No image available', style: TextStyle(color: Colors.grey))),
                )
              ];
            }
            isLoading = false;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load details: ${data['message']}')));
          setState(() {
            isLoading = false;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to connect to server')));
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching details: $e')));
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _confirmPayment() async {
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('http://assetin.my.id/skripsi/update_payment.php'),
        body: {'incident_id': widget.incident_id.toString()},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            isPaid = true;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment confirmed!')));
            if (widget.onPaymentConfirmed != null && widget.invoice != null) {
              final updatedInvoice = InvoiceModel(
                id: widget.invoice!.id,
                title: widget.invoice!.title,
                companyName: widget.invoice!.companyName,
                companyId: widget.invoice!.companyId,
                dateTime: widget.invoice!.dateTime,
                status: 'Paid',
                incidentId: widget.invoice!.incidentId,
              );
              widget.onPaymentConfirmed!(updatedInvoice);
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to confirm payment: ${data['message']}')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to connect to server for payment confirmation')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error confirming payment: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildInfoRow(String title, String value, {bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: isPrice ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontWeight: isPrice ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(int index, String method, String account) {
    final isSelected = _selectedPaymentIndex == index;
    return GestureDetector(
      onTap: () {
        if (method != 'Coming soon') {
          setState(() {
            _selectedPaymentIndex = index;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                method == 'Coming soon' ? method : '$method  $account',
                style: TextStyle(
                  color: method == 'Coming soon' ? Colors.grey : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Payment'),
          content: const Text('Are you sure you want to confirm your payment?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _confirmPayment();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const double consistentAppBarHeight = 95.0;

    return Scaffold(
      backgroundColor: const Color.fromARGB(245, 245, 245, 245),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(consistentAppBarHeight),
        child: Stack(
          children: [
            Image.asset(
              'assets/bg_image.png',
              height: consistentAppBarHeight,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Invoice',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                isPaid ? 'Paid' : 'Unpaid',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              if (!isPaid)
                                const Icon(Icons.warning_amber_rounded,
                                    color: Colors.orange, size: 24),
                            ],
                          ),
                          const SizedBox(height: 12),
                          CarouselSlider(
                            options: CarouselOptions(
                              height: 200,
                              enableInfiniteScroll: true,
                              enlargeCenterPage: true,
                              viewportFraction: 1.0,
                            ),
                            items: _carouselImages.isEmpty
                                ? [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Center(child: Text('No images available', style: TextStyle(color: Colors.grey))),
                                    )
                                  ]
                                : _carouselImages,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('Location ID', locationId),
                          _buildInfoRow('Asset ID', assetId),
                          _buildInfoRow('Asset name', title),
                          _buildInfoRow('Person in charge', picId),
                          _buildInfoRow('Phone number', '081208120812'),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              description,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          _buildInfoRow('Price', value, isPrice: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!isPaid) ...[
                      const Text(
                        'Select payment method*',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      _buildPaymentOption(0, 'QRIS', '125081208120812'),
                      const SizedBox(height: 12),
                      _buildPaymentOption(1, 'Coming soon', ''),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF028EEA),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            _showConfirmPaymentDialog(context);
                          },
                          child: const Text('Confirm payment',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'Payment Method',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          '$paymentMethod  125081208120812',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}