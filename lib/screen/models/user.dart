// lib/screen/models/user.dart
class User {
  final String name;
  final String email;
  final String companyName;
  final String userId; // Corresponds to #000001 in the image
  final String addedDate; // From the list screen, useful to pass along

  const User({
    required this.name,
    required this.email,
    required this.companyName,
    required this.userId,
    required this.addedDate,
  });
}