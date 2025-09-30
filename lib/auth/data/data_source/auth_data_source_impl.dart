import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../../../core/network/common/api_result.dart';
import '../../../../core/network/remote/api_manager.dart';


import '../../domain/entity/forgot_password_response_entity.dart';
import '../../domain/entity/login_entity.dart';
import '../api/auth_retrofit.dart';
import '../model/forget_password/forget_password_request_dto.dart';
import '../model/forget_password/reset_password_request.dart';
import '../model/forget_password/response/forget_password_respone.dart';
import '../model/forget_password/verify_reset_code_request_dto.dart';
import '../model/login/login_dto.dart';
import '../model/register/register_request.dart';
import 'auth_data_source.dart';

@Injectable(as: AuthDataSource)
class AuthDataSourceImpl implements AuthDataSource {
  final ApiManager apiManager;
  final AuthRetrofitClient apiService;


  AuthRetrofitClient apiClient;

  AuthDataSourceImpl(this.apiService, this.apiManager, this.apiClient);




  @override
  Future<Result<LoginEntity>> login({required String email, required String password}) async {
    final result = await apiManager.execute<LoginDto>(() async {
      final response = await apiService.login(email, password);

      if (response == null) {
        throw Exception("Null response from login API");
      }

      return response;
    });
    switch (result) {
      case SuccessResult<LoginDto>():
        return SuccessResult<LoginEntity>(result.data.toLoginEntity());
      case FailureResult<LoginDto>():
        return FailureResult<LoginEntity>(result.exception);
    }
  }


  @override
  Future<String> register(RegisterRequestModel registerRequest) async {
    final ans = await apiService .register(registerRequest);
    return ans.id!;
  }

  @override
  Future<Result<String>> forgotPassword(
      {required String email}) async {
    final result = await apiManager.execute<String>(() async {
      final response =
      await apiService.forgotPassword(ForgotPasswordRequestDto(email: email));
      return response;
    });

    switch (result) {
      case SuccessResult<String>():
        return SuccessResult<String>(result.data);
      case FailureResult<String>():
        return FailureResult<String>(result.exception);
    }
  }

  @override
  Future<Result<String>> verifyResetCode(
      {required String code,required String email}) async {
    final result = await apiManager.execute<String>(() async {
      final response =
      await apiService.verifyResetCode(VerifyResetCodeDtoRequest(email: email,otb: code));
      return response;
    });

    switch (result) {
      case SuccessResult<String>():
        return SuccessResult<String>(result.data);
      case FailureResult<String>():
        return FailureResult<String>(result.exception);
    }
  }

  @override
  Future<Result<String>> resetPassword(
      {required String email, required String newPassword}) async {
    final result = await apiManager.execute<String>(() async {
      final response = await apiService
          .resetPassword(ResetPasswordRequestDto(email: email ,newPassword: newPassword));
      return response;
    });

    switch (result) {
      case SuccessResult<String>():
        return SuccessResult<String>(result.data);
      case FailureResult<String>():
        return FailureResult<String>(result.exception);
    }
  }

}
