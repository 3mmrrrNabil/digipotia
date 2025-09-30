import 'dart:io';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/app_values.dart';
import '../../../../core/network/common/api_result.dart';
import '../../../../core/network/remote/api_manager.dart';
import '../../../core/storage_helper/app_shared_preference_helper.dart';
import '../../domain/entity/forgot_password_response_entity.dart';
import '../../domain/entity/login_entity.dart';
import '../../domain/repo/auth_repo.dart';
import '../data_source/auth_data_source.dart';
import '../model/register/register_request.dart';


@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource authDataSource;

  final ApiManager _apiManager;

  AuthRepositoryImpl(
      this._apiManager, this.authDataSource);

  @override
  Future<Result<String>> register(RegisterRequestModel registerRequest) async {
    final ans = await _apiManager.execute(() {
      return authDataSource.register(registerRequest);
    });
    return ans;
  }


  @override
  @override
  Future<Result<LoginEntity>> login({
    required String email,
    required String password,
  }) async {
    final result = await authDataSource.login(email: email, password: password);

    switch (result) {
      case SuccessResult<LoginEntity?>():
        final data = result.data;
        if (data == null) {
          // Empty response case
          return FailureResult<LoginEntity>(Exception("البريد الالكتروني او كلمه المرور غير صحيحه"));
        }

        await SharedPreferencesHelper.saveData(
            key: AppValues.token, value: data.token);
        await SharedPreferencesHelper.saveData(
            key: AppValues.userId, value: data.userId);

        return SuccessResult<LoginEntity>(data);

      case FailureResult<LoginEntity?>():
        return FailureResult<LoginEntity>(Exception("البريد الالكتروني او كلمه المرور غير صحيحه"));
    }

  }
  @override
  Future<Result<String>> forgotPassword(
      {required String email}) {
    return authDataSource.forgotPassword(email: email);
  }

  @override
  Future<Result<String>> resetPassword(
      {required String email, required String newPassword}) {
    return authDataSource.resetPassword(email: email, newPassword: newPassword);
  }

  @override
  Future<Result<String>> verifyResetCode(
      {required String code,required String email}) {
    return authDataSource.verifyResetCode(code: code, email: email,);
  }
}
