import 'package:injectable/injectable.dart';

import '../../../core/network/common/api_result.dart';
import '../../data/model/register/register_request.dart';
import '../repo/auth_repo.dart';

@injectable
class RegisterUseCase {
  AuthRepository _authRepository;
  RegisterUseCase(this._authRepository);
  Future<Result<String>> call(RegisterRequestModel registerRequest) =>
      _authRepository.register(registerRequest);
}
