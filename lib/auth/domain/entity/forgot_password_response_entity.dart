// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class ForgotPasswordResponseEntity extends Equatable {
  final String message;
  const ForgotPasswordResponseEntity({
    required this.message,
  });
  // copyWith
  ForgotPasswordResponseEntity copyWith({
    String? message,
  }) {
    return ForgotPasswordResponseEntity(
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [message];
}
