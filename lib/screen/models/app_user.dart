import 'package:asset_management/screen/models/user_role.dart'; 
import 'package:asset_management/screen/models/organization.dart'; 

class AppUser {
  final String id;
  final String name;
  final String email;
  final String password; 
  final String phone;
  final UserRole role; 
  final Organization? organization; 

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