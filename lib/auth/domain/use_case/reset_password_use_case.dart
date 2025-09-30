import 'package:injectable/injectable.dart';

import '../../../core/network/common/api_result.dart';
import '../entity/forgot_password_response_entity.dart';
import '../repo/auth_repo.dart';

@injectable
class ResetPasswordUseCase {
  final AuthRepository _authRepository;
  ResetPasswordUseCase(this._authRepository);

  Future<Result<String>> call(
      {required String email, required String newPassword}) =>
      _authRepository.resetPassword(email: email, newPassword: newPassword);
}
