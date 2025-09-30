import 'dart:io';

import '../../../../core/network/common/api_result.dart';
import '../../domain/entity/forgot_password_response_entity.dart';
import '../../domain/entity/login_entity.dart';
import '../model/forget_password/response/forget_password_respone.dart';
import '../model/register/register_request.dart';


abstract class AuthDataSource {
  Future< Result <LoginEntity?>>login({required String email, required String password});
  Future<String>register(RegisterRequestModel registerRequest);
  Future<Result<String>> forgotPassword({required String email});

  Future<Result<String>> verifyResetCode({required String code,required String email});

  Future<Result<String>> resetPassword(
      {required String email, required String newPassword});


}