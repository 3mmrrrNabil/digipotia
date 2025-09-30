import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entity/login_entity.dart';
part 'login_dto.g.dart';

// LoginDto
@JsonSerializable()
class LoginDto {
  final String token;
  final String userId;
  final String refreshToken;
  final String expiry;


  LoginDto({
    required this.token,
    required this.userId,
    required this.refreshToken,
    required this.expiry
  });

  LoginEntity toLoginEntity() {
    return LoginEntity(

      token: token,
      userId: userId,
      refreshToken: refreshToken,
        expiry:expiry
    );
  }

  factory LoginDto.fromJson(Map<String, dynamic> json) => _$LoginDtoFromJson(json);
  Map<String, dynamic> toJson() => _$LoginDtoToJson(this);
}



