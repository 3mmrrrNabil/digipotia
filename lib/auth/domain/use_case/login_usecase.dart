import 'package:injectable/injectable.dart';
import '../../../core/network/common/api_result.dart';
import '../entity/login_entity.dart';
import '../repo/auth_repo.dart';
@injectable
class LoginUseCase {
  AuthRepository loginRepository;
  LoginUseCase(this.loginRepository);
  Future<Result<LoginEntity?>>call({required String email, required String password})async {
    return  await loginRepository.login(email: email, password: password);
  }
}