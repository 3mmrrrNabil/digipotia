import 'package:equatable/equatable.dart';

import '../../../../core/enum/status.dart';
extension RegisterStatusX on ForgetPasswordState {
  // send email
  bool get isForgotPasswordLoading => forgotPasswordStatus == Status.loading;
  bool get isForgotPasswordSuccess => forgotPasswordStatus == Status.success;
  bool get isForgotPasswordError => forgotPasswordStatus == Status.failure;
  // send code
  bool get isVerifyResetCodeLoading => verifyResetCodeStatus == Status.loading;
  bool get isVerifyResetCodeSuccess => verifyResetCodeStatus == Status.success;
  bool get isVerifyResetCodeError => verifyResetCodeStatus == Status.failure;
  // reset password status
  bool get isResetPasswordLoading => resPasswordStatus == Status.loading;
  bool get isResetPasswordSuccess => resPasswordStatus == Status.success;
  bool get isResetPasswordError => resPasswordStatus == Status.failure;
}
class ForgetPasswordState extends Equatable {
  final Status forgotPasswordStatus;
  final Status verifyResetCodeStatus;
  final Status resPasswordStatus;
  final String errorMessage;
  final String email;
  final String otp; // 🆕 أضفناها

  const ForgetPasswordState({
    this.forgotPasswordStatus = Status.initial,
    this.verifyResetCodeStatus = Status.initial,
    this.resPasswordStatus = Status.initial,
    this.errorMessage = '',
    this.email = '',
    this.otp = '', // 🆕 initial empty
  });

  ForgetPasswordState copyWith({
    Status? forgotPasswordStatus,
    Status? verifyResetCodeStatus,
    Status? resPasswordStatus,
    String? errorMessage,
    String? email,
    String? otp, // 🆕
  }) {
    return ForgetPasswordState(
      forgotPasswordStatus: forgotPasswordStatus ?? this.forgotPasswordStatus,
      verifyResetCodeStatus: verifyResetCodeStatus ?? this.verifyResetCodeStatus,
      resPasswordStatus: resPasswordStatus ?? this.resPasswordStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      email: email ?? this.email,
      otp: otp ?? this.otp, // 🆕
    );
  }

  @override
  List<Object> get props => [
    forgotPasswordStatus,
    errorMessage,
    email,
    otp, // 🆕
    verifyResetCodeStatus,
    resPasswordStatus
  ];
}
