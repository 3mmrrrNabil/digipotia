import 'package:injectable/injectable.dart';
import '../../../core/network/common/api_result.dart';
import '../entity/forgot_password_response_entity.dart';
import '../repo/auth_repo.dart';

@injectable
class VerifyResetCodeUseCase {
  final AuthRepository _authRepository;

  VerifyResetCodeUseCase(this._authRepository);

  Future<Result<String>> call({required String code,required String email}) =>
      _authRepository.verifyResetCode(code: code, email: email);
}
