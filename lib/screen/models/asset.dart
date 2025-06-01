// lib/screen/models/asset.dart
// No need to import location.dart here unless Asset *contains* a Location object directly
// If it only references locationId, then location.dart is not strictly needed here.

class Asset { // This class now represents a specific device/asset with all its details
  final String id; // Device ID, e.g., #001001
  final String name; // e.g., "CCTV"
  final String category; // e.g., "Electronics"
  final String locationId; // The ID of the location it belongs to
  final String locationInfo; // e.g., "Jl Pertiwi 12"
  final double latitude; // Coordinate latitude
  final double longitude; // Coordinate longitude
  final String personInCharge; // e.g., "Danny"
  final String phoneNumber; // e.g., "081208120812"
  final String? barcodeData; // Optional: data for the barcode

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
    this.barcodeData, // Made optional
  });
}