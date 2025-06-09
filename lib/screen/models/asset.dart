// lib/screens/models/asset.dart
class Asset {
  final String id;
  final String name;
  final String category;
  final String locationId;
  final String locationInfo;
  final double latitude;
  final double longitude;
  final String personInCharge;
  final String phoneNumber;
  final String barcodeData;

  Asset({
    required this.id,
    required this.name,
    required this.category,
    required this.locationId,
    required this.locationInfo,
    required this.latitude,
    required this.longitude,
    required this.personInCharge,
    required this.phoneNumber,
    this.barcodeData = '',
  });
}