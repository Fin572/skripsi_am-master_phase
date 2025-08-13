// lib/models/incident_ticket.dart
import 'package:asset_management/screen/models/location.dart'; 
import 'package:asset_management/screen/models/asset.dart';    
import 'dart:io'; 

class IncidentTicket {
  final String ticketId;
  final Asset asset;
  final Location location;
  final String description;
  final DateTime submissionTime;
  final List<String> imageUrls; 
  final String status; 

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