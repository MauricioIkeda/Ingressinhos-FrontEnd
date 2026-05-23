class UserModel {
  final String name;
  final String role;
  final int? sellerId;

  UserModel({
    required this.name,
    required this.role,
    this.sellerId,
  });
}