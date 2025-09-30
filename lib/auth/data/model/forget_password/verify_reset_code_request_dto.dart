import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entity/forgot_password_request_entity.dart';
part 'verify_reset_code_request_dto.g.dart';

@JsonSerializable()
class VerifyResetCodeDtoRequest {
  final String? email;

  final String? otb;
  VerifyResetCodeDtoRequest({this.otb,this.email});

  Map<String, dynamic> toJson() => _$VerifyResetCodeDtoRequestToJson(this);

  ForgotPasswordRequestEntity toEntity() {
    return ForgotPasswordRequestEntity(
      email: email??"",
      otb: otb ?? "",
      newPassword: "",
    );
  }
}
