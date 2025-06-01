class Customer {
  final String id;
  final String name;
  final int totalAssets;

  Customer({
    required this.id,
    required this.name,
    required this.totalAssets,
  });

  // Contoh factory constructor untuk dari JSON (backend)
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'].toString(),
      name: json['name'],
      totalAssets: json['totalAssets'],
    );
  }
}
