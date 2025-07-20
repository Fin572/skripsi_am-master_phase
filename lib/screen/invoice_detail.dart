import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class Invoicedetail extends StatefulWidget {
  final String status;
  final int incident_id;

  const Invoicedetail({super.key, required this.status, required this.incident_id});

  @override
  State<Invoicedetail> createState() => _InvoicedetailState();
}

class _InvoicedetailState extends State<Invoicedetail> {
  int _selectedPaymentIndex = 0;
  Uint8List? afterPhotos; // To store decoded image data
  String locationId = '';
  String assetId = '';
  String title = '';
  String picId = '';
  String description = '';
  String value = '';
  String paymentMethod = '';
  bool isLoading = false;
  bool isPaid = false;

  @override
  void initState() {
    super.initState();
    isPaid = widget.status == 'Paid';
    _fetchInvoiceDetail();
  }

  Future<void> _fetchInvoiceDetail() async {
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
            // Decode base64 string to Uint8List for the image
            if (data['after_photos'] != null && data['after_photos'].isNotEmpty) {
              afterPhotos = base64Decode(data['after_photos']);
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load details: ${data['message']}')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to connect to server')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching details: $e')));
    }
  }

  Future<void> _confirmPayment() async {
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.3/skripsi/update_payment.php'),
        body: {'incident_id': widget.incident_id.toString()},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            isPaid = true;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment confirmed!')));
          });
        }
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
          Text(title, style: TextStyle(fontWeight: isPrice ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isPrice ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(int index, String method, String account) {
    final isSelected = _selectedPaymentIndex == index;
    return GestureDetector(
      onTap: () {
        if (method != 'Coming soon') {
          setState(() => _selectedPaymentIndex = index);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey[300]!, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(child: Text(method == 'Coming soon' ? method : '$method  $account', style: TextStyle(color: method == 'Coming soon' ? Colors.grey : Colors.black, fontWeight: FontWeight.w500))),
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? Colors.blue : Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF028EEA),
        title: const Text('Incident', style: TextStyle(color: Colors.white)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
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
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: const [Text('Invoice summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(width: 4), Icon(Icons.info_outline, size: 18)]),
                          const SizedBox(height: 12),
                          // Use MemoryImage if afterPhotos is available, otherwise show placeholder
                          Container(
                            height: 200,
                            child: afterPhotos != null
                                ? Image.memory(afterPhotos!, fit: BoxFit.cover)
                                : const Center(child: Text('No image available')),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('Location ID', locationId),
                          _buildInfoRow('Asset ID', assetId),
                          _buildInfoRow('Asset name', title),
                          _buildInfoRow('Person in charge', picId),
                          const SizedBox(height: 12),
                          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8)), child: Text(description)),
                          const SizedBox(height: 16),
                          const Divider(),
                          _buildInfoRow('Price', value, isPrice: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!isPaid) ...[
                      const Text('Select payment method*', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      _buildPaymentOption(0, 'QRIS', '125081208120812'),
                      const SizedBox(height: 12),
                      _buildPaymentOption(1, 'Coming soon', ''),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF028EEA), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 16)),
                          onPressed: _confirmPayment,
                          child: const Text('Confirm payment', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ] else ...[
                      const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
                        child: const Text('QRIS  125081208120812', style: TextStyle(fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}