// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginDto _$LoginDtoFromJson(Map<String, dynamic> json) => LoginDto(
      token: json['token'] as String,
      userId: json['userId'] as String,
      refreshToken: json['refreshToken'] as String,
      expiry: json['expiry'] as String,
    );

Map<String, dynamic> _$LoginDtoToJson(LoginDto instance) => <String, dynamic>{
      'token': instance.token,
      'userId': instance.userId,
      'refreshToken': instance.refreshToken,
      'expiry': instance.expiry,
    };
