import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/enum/status.dart';
import '../../../../core/network/common/api_result.dart';
import '../../../domain/entity/forgot_password_response_entity.dart';
import '../../../domain/use_case/forget_password_use_case.dart';
import '../../../domain/use_case/reset_password_use_case.dart';
import '../../../domain/use_case/verify_reset_code_use_case.dart';
import 'forget_password_state.dart';

@injectable
class ForgetPasswordCubit extends Cubit<ForgetPasswordState> {
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final VerifyResetCodeUseCase _verifyResetCodeUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  ForgetPasswordCubit(
      this._forgotPasswordUseCase,
      this._verifyResetCodeUseCase,
      this._resetPasswordUseCase,
      ) : super(const ForgetPasswordState());

  Future<void> forgotPassword(String email) async {
    emit(state.copyWith(forgotPasswordStatus: Status.loading));
    final result = await _forgotPasswordUseCase.call(email: email);
    switch (result) {
      case SuccessResult<String>():
        emit(state.copyWith(
          forgotPasswordStatus: Status.success,
          email: email, // 🆕 خزن الايميل
        ));
      case FailureResult<String>():
        emit(state.copyWith(
          forgotPasswordStatus: Status.failure,
          errorMessage: result.exception.toString(),
        ));
    }
  }

  Future<void> verifyResetCode(String code) async {
    emit(state.copyWith(verifyResetCodeStatus: Status.loading));
    final result = await _verifyResetCodeUseCase.call(code: code, email: state.email); // 🆕 استخدم الايميل المخزن
    switch (result) {
      case SuccessResult<String>():
        emit(state.copyWith(
          verifyResetCodeStatus: Status.success,
          otp: code, // 🆕 خزن الـ otp
        ));
      case FailureResult<String>():
        emit(state.copyWith(
          verifyResetCodeStatus: Status.failure,
          errorMessage: result.exception.toString(),
        ));
    }
  }

  Future<void> resetPassword(String newPassword) async {
    emit(state.copyWith(resPasswordStatus: Status.loading));
    final result = await _resetPasswordUseCase.call(
      newPassword: newPassword,
      email: state.email, // 🆕 من state
          // 🆕 من state
    );

    switch (result) {
      case SuccessResult<String>():
        emit(state.copyWith(resPasswordStatus: Status.success));
      case FailureResult<String>():
        emit(state.copyWith(
          resPasswordStatus: Status.failure,
          errorMessage: result.exception.toString(),
        ));
    }
  }



}
