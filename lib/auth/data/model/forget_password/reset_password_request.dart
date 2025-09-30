import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entity/forgot_password_request_entity.dart';


part 'reset_password_request.g.dart';

@JsonSerializable()
class ResetPasswordRequestDto {
  final String? email;
  final String? otp;
  final String? newPassword;

  ResetPasswordRequestDto({
    this.email,
    this.newPassword,
    this.otp
  });

  Map<String, dynamic> toJson() => _$ResetPasswordRequestDtoToJson(this);

  ForgotPasswordRequestEntity toEntity() {
    return ForgotPasswordRequestEntity(
      email: email ?? "",
      otb: otp??"",
      newPassword: newPassword ?? "",
    );
  }
}
