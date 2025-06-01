import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Invoicedetail extends StatefulWidget {
  final String status; 

  const Invoicedetail({super.key, required this.status});

  @override
  State<Invoicedetail> createState() => _InvoicedetailState();
}


class _InvoicedetailState extends State<Invoicedetail> {
  int _selectedPaymentIndex = 0;
  final List<String> imageList = [
    'assets/cctv.png',
    'assets/cctv.png',
  ];

  @override
  Widget build(BuildContext context) {
    bool isPaid = widget.status == 'Paid';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF028EEA),
        title: const Text('Incident', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
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
                      children: const [
                        Text('Invoice summary',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(width: 4),
                        Icon(Icons.info_outline, size: 18)
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
                      items: imageList
                          .map((item) => ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(item,
                                    fit: BoxFit.cover, width: double.infinity),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Location ID', '#001001'),
                    _buildInfoRow('Asset ID', '#001001'),
                    _buildInfoRow('Asset name', 'CCTV'),
                    _buildInfoRow('Person in charge', 'Margareth'),
                    _buildInfoRow('Phone number', '081208120812'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Saluran sudah kembali normal :\n• terdapat kerusakan di kabel dikarenakan digigit tikus',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    _buildInfoRow('Price', 'Rp. 200.000,-', isPrice: true),
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
      onPressed: () {},
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
    child: const Text(
      'QRIS  125081208120812',
      style: TextStyle(fontWeight: FontWeight.w500),
    ),
  ),
],
            ],
          ),
        ),
      ),
    );
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
}
