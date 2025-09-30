import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';
import 'package:google_fonts/google_fonts.dart';
import '../view_model/forget_password/forget_password_cubit.dart';
import '../view_model/forget_password/forget_password_state.dart';
import '../../../core/dialogs/app_dialogs.dart';
import '../../../core/dialogs/app_toasts.dart';
import '../../../core/routes/routes.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  late TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      body: BlocListener<ForgetPasswordCubit, ForgetPasswordState>(
        listener: (context, state) {
          if (state.isForgotPasswordLoading) {
            AppDialogs.showLoadingDialog(context);
          }
          if (state.isForgotPasswordSuccess) {
            Navigator.of(context).pushNamed(
              Routes.emailVerification,
              arguments: context.read<ForgetPasswordCubit>(),
            );
          }
          if (state.isForgotPasswordError) {
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
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.06,
            vertical: size.height * 0.04,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // صورة
              Center(
                child: Image.asset(
                  "assets/images/login_icon.png",
                  height: size.height * 0.25,
                  width: size.height * 0.25,
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: size.height * 0.02),

              // عنوان
              Text(
                "تأكيد الهوية",
                style: GoogleFonts.cairo(
                  fontSize: 20 * textScale,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: size.height * 0.02),

              // وصف
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    labelText: "البريد الإلكتروني",
                    labelStyle: GoogleFonts.cairo(
                        fontSize: 16 * textScale, color: Colors.black87),
                    hintText: "أدخل بريدك الإلكتروني",
                    hintStyle: GoogleFonts.cairo(
                        fontSize: 14 * textScale, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.green),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: size.height * 0.025,
                      horizontal: size.width * 0.05,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "هذا الحقل مطلوب";
                    }
                    if (!val.contains("@")) {
                      return "البريد الإلكتروني غير صالح";
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: size.height * 0.04),

              // زر تأكيد
              SizedBox(
                width: double.infinity,
                height: size.height * 0.065,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context
                          .read<ForgetPasswordCubit>()
                          .forgotPassword(_emailController.text);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "التالي",
                    style: GoogleFonts.cairo(
                      fontSize: 18 * textScale,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.025),

              // رابط العودة لتسجيل الدخول
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "العودة لتسجيل الدخول",
                    style: GoogleFonts.cairo(
                      fontSize: 14 * textScale,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
