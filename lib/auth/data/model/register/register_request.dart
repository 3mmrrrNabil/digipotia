class RegisterRequestModel {
  final String email;
  final String displayName;
  final String password;

  RegisterRequestModel(
      {
        required this.email,
        required this.displayName,
        required this.password,
      });

  Map<String, dynamic> toJson() => {
    "email": email,
    "password": password,
    "displayName":displayName
  };
}
