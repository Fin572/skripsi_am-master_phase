// lib/models/incident_ticket.dart
import 'package:asset_management/screen/models/location.dart'; // Adjust path
import 'package:asset_management/screen/models/asset.dart';     // Adjust path
import 'dart:io'; // For File

class IncidentTicket {
  final String ticketId;
  final Asset asset;
  final Location location;
  final String description;
  final DateTime submissionTime;
  final List<String> imageUrls; // Storing paths as Strings
  final String status; // e.g., 'Assigned', 'On progress', 'Rejected', 'Done'

  IncidentTicket({
    required this.ticketId,
    required this.asset,
    required this.location,
    required this.description,
    required this.submissionTime,
    required this.imageUrls,
    required this.status,
  });
}