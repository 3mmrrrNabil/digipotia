import 'package:digipotia/auth/presentation/view_model/register/register_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/base_state/base_state.dart';
import '../../../../core/network/common/api_result.dart';
import '../../../data/model/register/register_request.dart';
import '../../../domain/use_case/register_usecase.dart';

@injectable
class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._registerUseCase) : super(RegisterState());

  final RegisterUseCase _registerUseCase;

  register(RegisterRequestModel registerRequest) async {
    emit(state.copyWith(registerState: BaseLoadingState()));

    Result<String> ans = await _registerUseCase(registerRequest);

    switch (ans) {
      case SuccessResult<String>():
        {
          print("----------------------------------------");
          await Future.delayed(const Duration(seconds: 2));
          emit(state.copyWith(
            registerState: BaseSuccessState<String>(data: "success"),
          ));
          print("ppppppppppppppppppppppppppp");
        }
      case FailureResult<String>():
        {
          await Future.delayed(const Duration(seconds: 2));
          emit(state.copyWith(
            registerState: BaseErrorState(
              errorMessage: ans.exception.toString(),
            ),
          ));
        }
    }
  }
}
