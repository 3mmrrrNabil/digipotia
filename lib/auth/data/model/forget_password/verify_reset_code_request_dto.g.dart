// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_reset_code_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyResetCodeDtoRequest _$VerifyResetCodeDtoRequestFromJson(
        Map<String, dynamic> json) =>
    VerifyResetCodeDtoRequest(
      otb: json['otp'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$VerifyResetCodeDtoRequestToJson(
        VerifyResetCodeDtoRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'otp': instance.otb,
    };
