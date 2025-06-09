// lib/models/app_user.dart
import 'package:asset_management/screen/models/user_role.dart'; // Import UserRole enum
import 'package:asset_management/screen/models/organization.dart'; // Import Organization model

class AppUser {
  final String id;
  final String name;
  final String email;
  final String password; // In real app, never store plaintext password
  final String phone;
  final UserRole role; // user, admin, superAdmin
  final Organization? organization; // Optional for users, null for admins/superadmins

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.role,
    this.organization,
  });
}