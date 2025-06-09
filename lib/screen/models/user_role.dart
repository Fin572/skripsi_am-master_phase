// lib/models/user_role.dart

enum UserRole {
  customer,
  admin,
  superAdmin,
  unknown, // Use this for unauthenticated state or if role is not recognized
}