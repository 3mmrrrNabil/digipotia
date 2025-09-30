import 'package:digipotia/auth/data/model/register/register_request.dart';
import 'package:digipotia/auth/presentation/view_model/register/register_cubit.dart';
import 'package:digipotia/auth/presentation/view_model/register/register_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/base_state/base_state.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/dialogs/app_dialogs.dart';
import '../../../core/utils/validator.dart';
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  late RegisterCubit registerCubit;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _submitted = false;

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    registerCubit = serviceLocator.get<RegisterCubit>();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 4),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.fastLinearToSlowEaseIn,
    ));

    _controller.forward();

    // listeners عشان يمسحوا الغلط أول ما يكتب
    _displayNameController.addListener(_validateOnChange);
    _emailController.addListener(_validateOnChange);
    _passwordController.addListener(_validateOnChange);
    _confirmPasswordController.addListener(_validateOnChange);
  }

  void _validateOnChange() {
    if (_submitted) setState(() {});
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onRegister() {
    setState(() => _submitted = true);

    final nameError = Validator.validateName(_displayNameController.text.trim());
    final emailError = Validator.validateEmail(_emailController.text.trim());
    final passwordError = Validator.validatePassword(_passwordController.text.trim());
    final confirmPasswordError = Validator.validateConfirmPassword(
      _confirmPasswordController.text.trim(),
      _passwordController.text.trim(),
    );

    if (nameError == null &&
        emailError == null &&
        passwordError == null &&
        confirmPasswordError == null) {
      final request = RegisterRequestModel(
        displayName: _displayNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      registerCubit.register(request);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterCubit, RegisterState>(
      bloc: registerCubit,
      listener: (context, state) {
        if (state.registerState is BaseLoadingState) {
          AppDialogs.showLoadingDialog(context);
        } else if (state.registerState is BaseSuccessState) {
          Navigator.of(context).pop();
          AppDialogs.showSuccessDialog(context, message: "تم التسجيل بنجاح",);
        } else if (state.registerState is BaseErrorState) {
          Navigator.of(context).pop();
          AppDialogs.showFailureDialog(
            context,
            message: 'البريد الإلكتروني مسجل مسبقًا',
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Image.asset(
                    "assets/images/login_icon.png",
                    height: 200,
                    width: 200,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "انشاء حساب جديد",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildTextField(
                          controller: _displayNameController,
                          hint: "مثال : هانيا هشام",
                          label: "الاسم بالكامل",
                          errorMessage: _submitted
                              ? Validator.validateName(_displayNameController.text.trim())
                              : null,
                        ),
                        _buildTextField(
                          controller: _emailController,
                          hint: "مثال : hanya@gmail.com",
                          label: "البريد الإلكتروني",
                          errorMessage: _submitted
                              ? Validator.validateEmail(_emailController.text.trim())
                              : null,
                        ),
                        _buildTextField(
                          controller: _passwordController,
                          hint: "********",
                          label: "كلمة مرور جديدة",
                          isPassword: true,
                          obscureText: _obscurePassword,
                          toggleObscure: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                          errorMessage: _submitted
                              ? Validator.validatePassword(_passwordController.text.trim())
                              : null,
                        ),
                        _buildTextField(
                          controller: _confirmPasswordController,
                          hint: "********",
                          label: "تأكيد كلمة المرور",
                          isPassword: true,
                          obscureText: _obscureConfirmPassword,
                          toggleObscure: () =>
                              setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          errorMessage: _submitted
                              ? Validator.validateConfirmPassword(
                            _confirmPasswordController.text.trim(),
                            _passwordController.text.trim(),
                          )
                              : null,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _onRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              "تسجيل",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "تسجيل الدخول",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const Text(
                              "  لديك حساب؟ ",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required String label,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? toggleObscure,
    String? errorMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text("*", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))
            ],
            border: Border.all(color: errorMessage != null ? Colors.red : Colors.transparent, width: 1.5),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              suffixIcon: isPassword
                  ? IconButton(
                icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                onPressed: toggleObscure,
              )
                  : null,
            ),
          ),
        ),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 6),
            child: Text(errorMessage, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ),
        const SizedBox(height: 20),
      ],
    );
  }
}
