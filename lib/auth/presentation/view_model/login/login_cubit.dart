import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/network/common/api_result.dart';
import '../../../../core/error/failure.dart';
import '../../../domain/entity/login_entity.dart';
import '../../../domain/use_case/login_usecase.dart';
import 'login_state.dart';

@injectable
class LoginCubit extends Cubit<LoginStates> {
  final LoginUseCase loginUseCase;

  LoginCubit(this.loginUseCase) : super(LoginInitial());

  void login({required String email, required String password}) async {
    emit(LoginLoadingState());

    if (email.isEmpty || password.isEmpty) {
      emit(LoginErrorState(
        ValidationFailure("Please enter your email and password"),
      ));
      return;
    }

    try {
      final result = await loginUseCase.call(email: email, password: password);

      switch (result) {
        case SuccessResult<LoginEntity?>():
          final data = result.data;
          if (data == null) {
            await Future.delayed(const Duration(seconds: 2)); // ✅ استنى ثانيتين
            emit(LoginErrorState(ServerFailure("Empty response")));
            return;
          }
          await Future.delayed(const Duration(seconds: 2)); // ✅ استنى ثانيتين
          emit(LoginSuccessState(loginEntity: data));

        case FailureResult<LoginEntity?>():
          final failure = _extractFailure(result.exception);
          await Future.delayed(const Duration(seconds: 2)); // ✅ استنى ثانيتين
          emit(LoginErrorState(failure));
      }
    } catch (e) {
      await Future.delayed(const Duration(seconds: 2)); // ✅ استنى ثانيتين
      emit(LoginErrorState(ServerFailure(e.toString())));
    }
  }

  Failure _extractFailure(Object exception) {
    if (exception is Failure) {
      return exception;
    }
    return ServerFailure(exception.toString());
  }
}
