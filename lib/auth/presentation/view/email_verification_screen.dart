import 'package:digipotia/core/extensions/media_query_extensions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../core/dialogs/app_dialogs.dart';
import '../../../core/dialogs/app_toasts.dart';
import '../../../core/routes/routes.dart';
import '../../../core/utils/validator.dart';
import '../../../generated/locale_keys.g.dart';
import '../view_model/forget_password/forget_password_cubit.dart';
import '../view_model/forget_password/forget_password_state.dart';
import 'package:digipotia/core/extensions/media_query_extensions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../core/dialogs/app_dialogs.dart';
import '../../../core/dialogs/app_toasts.dart';
import '../../../core/routes/routes.dart';
import '../../../core/utils/validator.dart';
import '../view_model/forget_password/forget_password_cubit.dart';
import '../view_model/forget_password/forget_password_state.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final titleFontSize = width * 0.06;
    final subtitleFontSize = width * 0.04;
    final buttonHeight = height * 0.07;
    final buttonFontSize = width * 0.045;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "كلمة المرور",
          style: TextStyle(fontSize: width * 0.05, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
        listener: (context, state) {
          if (state.isVerifyResetCodeLoading || state.isForgotPasswordLoading) {
            AppDialogs.showLoadingDialog(context);
          }
          if (state.isVerifyResetCodeSuccess) {
            context.pop();
            context.pushNamed(Routes.resetPassword,
                arguments: context.read<ForgetPasswordCubit>());
          }
          if (state.isVerifyResetCodeError) {
            context.pop();
            AppToast.showToast(
              context: context,
              title: "خطأ",
              description: "حدث خطأ غير متوقع في الخادم",
              type: ToastificationType.error,
            );
          }
        },
        builder: (context, state) => SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: height * 0.04),
                Text(
                  "التحقق من البريد الإلكتروني",
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: height * 0.015),
                Text(
                  "ادخل الكود الذي تم إرساله إلى بريدك الإلكتروني",
                  style: TextStyle(fontSize: subtitleFontSize, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: height * 0.035),
                TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'أدخل الكود هنا',
                    hintStyle: TextStyle(fontSize: subtitleFontSize, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.green),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    contentPadding: EdgeInsets.symmetric(
                        vertical: height * 0.025, horizontal: width * 0.05),
                  ),
                  validator: (value) => Validator.validateCode(value),
                ),
                SizedBox(height: height * 0.05),
                SizedBox(
                  width: double.infinity,
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context
                            .read<ForgetPasswordCubit>()
                            .verifyResetCode(_codeController.text);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "تأكيد",
                      style: TextStyle(
                        fontSize: buttonFontSize,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "لم تستلم الكود؟",
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: width * 0.01),
                    InkWell(
                      onTap: () => context
                          .read<ForgetPasswordCubit>()
                          .forgotPassword(state.email),
                      child: Text(
                        "إعادة الإرسال",
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          fontWeight: FontWeight.w400,
                          color: Colors.pink,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.pink,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
