import 'package:injectable/injectable.dart';

import '../../../core/network/common/api_result.dart';
import '../entity/forgot_password_response_entity.dart';
import '../repo/auth_repo.dart';

@injectable
class ForgotPasswordUseCase {
  final AuthRepository _authRepository;

  ForgotPasswordUseCase(this._authRepository);

  Future<Result<String>> call({required String email}) =>
      _authRepository.forgotPassword(email: email);
}
