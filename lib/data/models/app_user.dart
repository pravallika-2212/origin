enum UserRole { guest, member, admin }

class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    this.country = 'United States',
    this.role = UserRole.member,
    required this.createdAt,
  });

  final String uid;
  final String name;
  final String email;
  final String phone;
  final String country;
  final UserRole role;
  final DateTime createdAt;

  bool get isAdmin => role == UserRole.admin;
  String get firstName => name.trim().split(' ').first;
}
