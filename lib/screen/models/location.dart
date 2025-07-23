class Location {
  final String id; // Unique identifier for each location
  final String? organizationId; // ID of the organization the location belongs to
  final String name; // Location name
  final String? address; // Location address
  final String? detail; // Additional details about the location
  final String? personInCharge; // The person in charge (PIC) of the location
  final String? phoneNumber; // Contact number for the location
  final double? latitude; // Optional: Latitude coordinate (for map positioning)
  final double? longitude; // Optional: Longitude coordinate (for map positioning)
  final int? deviceCount; // Added for display in card, can be fetched or default

  Location({
    required this.id,
    this.organizationId, // Made nullable as it might not be in initial fetch
    required this.name,
    this.address,
    this.detail,
    this.personInCharge,
    this.phoneNumber,
    this.latitude,
    this.longitude,
    this.deviceCount, // Made nullable
  });

  // Convert the Location object to a Map so we can send it to the backend
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

  // Factory constructor to create a Location object from a JSON map
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'].toString(), // Ensure it's a String as per your model
      name: json['name'] as String,
      // Properti lain yang tidak ada di respons PHP saat ini akan null
      // Jika Anda ingin properti ini diisi, Anda perlu memodifikasi kueri PHP Anda
      organizationId: json['owner_organization']?.toString(), // Assuming PHP might return this
      address: json['address'] as String?,
      detail: json['detail'] as String?,
      personInCharge: json['person_In_Charge'] as String?,
      phoneNumber: json['phonenumber'] as String?, // Note: PHP uses 'phonenumber'
      latitude: json['geolocation'] != null ? double.tryParse(json['geolocation'].split(',')[0]) : null, // Assuming geolocation is "lat,lon" string
      longitude: json['geolocation'] != null ? double.tryParse(json['geolocation'].split(',')[1]) : null,
      // deviceCount tidak ada di respons PHP Anda saat ini, jadi kita bisa default atau ambil dari API lain
      deviceCount: json['device_count'] != null ? int.tryParse(json['device_count'].toString()) : 0, // Placeholder or fetched
    );
  }
}