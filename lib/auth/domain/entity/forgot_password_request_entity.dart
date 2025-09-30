import 'package:equatable/equatable.dart';

class ForgotPasswordRequestEntity extends Equatable {
  final String email;
  final String otb;
  final String newPassword;
  const ForgotPasswordRequestEntity({
    required this.email,
    required this.otb,
    required this.newPassword,
  });
  // copyWith
  ForgotPasswordRequestEntity copyWith({
    String? email,
    String? otb,
    String? newPassword,
  }) {
    return ForgotPasswordRequestEntity(
      email: email ?? this.email,
      otb: otb ?? this.otb,
      newPassword: newPassword ?? this.newPassword,
    );
  }

  @override
  List<Object?> get props => [email, otb, newPassword];
}
