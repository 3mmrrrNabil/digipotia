import 'dart:io';
import '../../../core/network/common/api_result.dart';
import '../../data/model/register/register_request.dart';
import '../entity/forgot_password_response_entity.dart';
import '../entity/login_entity.dart';

abstract class AuthRepository {
  Future<Result<String>> forgotPassword({required String email});
  Future<Result<String>> verifyResetCode({required String code,required String email});
  Future<Result<String>> resetPassword(
      {required String email, required String newPassword});
  Future<Result<String>> register(RegisterRequestModel registerRequest);
  Future<Result<LoginEntity?>> login({required String email, required String password});

}



