class Location {
  final String id; 
  final String? organizationId; 
  final String name; 
  final String? address; 
  final String? detail; 
  final String? personInCharge; 
  final String? phoneNumber; 
  final double? latitude; 
  final double? longitude; 
  final int? deviceCount; 

  Location({
    required this.id,
    this.organizationId, 
    required this.name,
    this.address,
    this.detail,
    this.personInCharge,
    this.phoneNumber,
    this.latitude,
    this.longitude,
    this.deviceCount, 
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organization_id': organizationId,
      'location_name': name,
      'address': address,
      'detail': detail,
      'person_In_Charge': personInCharge,
      'phone_number': phoneNumber,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'].toString(), 
      name: json['name'] as String,
     
      organizationId: json['owner_organization']?.toString(), 
      address: json['address'] as String?,
      detail: json['detail'] as String?,
      personInCharge: json['person_In_Charge'] as String?,
      phoneNumber: json['phonenumber'] as String?, 
      latitude: json['geolocation'] != null ? double.tryParse(json['geolocation'].split(',')[0]) : null, 
      longitude: json['geolocation'] != null ? double.tryParse(json['geolocation'].split(',')[1]) : null,
      deviceCount: json['device_count'] != null ? int.tryParse(json['device_count'].toString()) : 0, 
    );
  }
}