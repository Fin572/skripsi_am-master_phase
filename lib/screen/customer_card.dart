import 'package:flutter/material.dart';
import 'package:asset_management/screen/models/customer.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;

  const CustomerCard({Key? key, required this.customer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        color: const Color(0xFF0099FF), // From NEW UI
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // From NEW UI
        ),
        elevation: 4, // From NEW UI
        child: Padding(
          padding: const EdgeInsets.all(20.0), // From NEW UI
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.business, size: 40, color: Colors.white), // From NEW UI
                  const SizedBox(width: 12), // From NEW UI
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${customer.id}',
                        style: const TextStyle(
                          color: Colors.white, // From NEW UI
                          fontSize: 18, // From NEW UI
                          fontWeight: FontWeight.bold, // From NEW UI
                        ),
                      ),
                      const SizedBox(height: 4), // From NEW UI
                      Text(
                        customer.name,
                        style: const TextStyle(
                          color: Colors.white70, // From NEW UI
                          fontSize: 16, // From NEW UI
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20), // From NEW UI
              Row(
                children: [
                  const Icon(Icons.folder, size: 20, color: Colors.white70), // From NEW UI
                  const SizedBox(width: 8), // From NEW UI
                  Text(
                    '${customer.totalAssets} Asset',
                    style: const TextStyle(
                      color: Colors.white70, // From NEW UI
                      fontSize: 16, // From NEW UI
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}