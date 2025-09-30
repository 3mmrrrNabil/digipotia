import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/network/remote/api_constants.dart';
import '../../domain/entity/forgot_password_response_entity.dart';
import '../model/forget_password/forget_password_request_dto.dart';
import '../model/forget_password/reset_password_request.dart';
import '../model/forget_password/verify_reset_code_request_dto.dart';
import '../model/login/login_dto.dart';
import '../model/register/register_request.dart';
import '../model/register/register_response.dart';
part 'auth_retrofit.g.dart';
@lazySingleton
@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class AuthRetrofitClient {
  @factoryMethod
  factory AuthRetrofitClient(Dio dio) = _AuthRetrofitClient;

  @POST("auth/register")
  Future<RegisterResponse> register(
      @Body() RegisterRequestModel registerRequest);

  @POST("auth/login")
  Future<LoginDto?> login(
      @Field("email") String email, @Field("password") String password);
  @POST("auth/forget-password")
  Future<String> forgotPassword(
      @Body() ForgotPasswordRequestDto request);

  @POST("auth/verify-otp")
  Future<String> verifyResetCode(
      @Body() VerifyResetCodeDtoRequest request);

  @POST("auth/reset-password")
  Future<String> resetPassword(@Body() ResetPasswordRequestDto request);
}
