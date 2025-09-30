import 'package:json_annotation/json_annotation.dart';

import '../../../../domain/entity/forgot_password_response_entity.dart';

part 'forget_password_respone.g.dart';

@JsonSerializable()
class ForgotPasswordResponseDto {
  String? message;

  ForgotPasswordResponseDto({this.message});

  factory ForgotPasswordResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordResponseDtoFromJson(json);

  // toEntity
  ForgotPasswordResponseEntity toEntity() {
    return ForgotPasswordResponseEntity(
      message: message ?? "",

    );
  }
}
