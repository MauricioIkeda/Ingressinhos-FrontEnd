class RegisterUserClientModel {
  final String name;
  final String email;
  final String cpf;
  final String password;

  RegisterUserClientModel({
    required this.name,
    required this.email,
    required this.cpf,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'cpf': cpf,
      'password': password,
    };
  }
}