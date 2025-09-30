import 'package:digipotia/auth/presentation/view_model/forget_password/forget_password_cubit.dart';
import 'package:digipotia/core/extensions/media_query_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/dialogs/app_dialogs.dart';
import '../../../core/dialogs/app_toasts.dart';
import '../../../core/routes/routes.dart';
import '../../../core/utils/validator.dart';
import '../../../../core/constants/app_colors.dart';
import '../view_model/forget_password/forget_password_state.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  late GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({required String label, String? hint}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.cairo(
        fontSize: 16,
        color: Colors.black87,
      ),
      hintText: hint ?? label,
      hintStyle: GoogleFonts.cairo(fontSize: 14, color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.green),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      floatingLabelBehavior: FloatingLabelBehavior.always,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ForgetPasswordCubit, ForgetPasswordState>(
        listener: (context, state) {
          if (state.isResetPasswordLoading) {
            AppDialogs.showLoadingDialog(context);
          }
          if (state.isResetPasswordSuccess) {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed(Routes.login);
          }
          if (state.isResetPasswordError) {
            Navigator.of(context).pop();
            AppToast.showToast(
              context: context,
              title: "خطأ",
              description: "حدث خطأ غير متوقع في السيرفر",
              type: ToastificationType.error,
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "إعادة تعيين كلمة المرور",
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: context.hp(1.5)),
                Text(
                  "يجب أن تتكون كلمة المرور من 8 أحرف على الأقل وتشمل أحرف كبيرة وصغيرة وأرقام",
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.hp(3.5)),

                // New Password
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: _inputDecoration(
                    label: "كلمة المرور الجديدة",
                    hint: "أدخل كلمة المرور الجديدة",
                  ),
                  validator: (value) => Validator.validatePassword(value),
                ),
                SizedBox(height: context.hp(2.5)),

                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: _inputDecoration(
                    label: "تأكيد كلمة المرور",
                    hint: "أعد إدخال كلمة المرور",
                  ),
                  validator: (value) => Validator.validateConfirmPassword(
                      value, _newPasswordController.text),
                ),
                SizedBox(height: context.hp(4.5)),

                // Confirm Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context
                            .read<ForgetPasswordCubit>()
                            .resetPassword(_newPasswordController.text);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "تأكيد",
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
