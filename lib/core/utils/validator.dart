import '../constants/app_values.dart';

class Validator {
  Validator._();

  static String? validateEmail(String? val) {
    final RegExp emailRegex = RegExp(
      AppValues.emailRegex,
    );
    if (val == null || val.trim().isEmpty) {
      return "البريد الإلكتروني لا يمكن أن يكون فارغًا";
    } else if (!emailRegex.hasMatch(val)) {
      return "الرجاء إدخال بريد إلكتروني صحيح";
    } else {
      return null;
    }
  }

  static String? validatePassword(String? val) {
    final RegExp passwordRegex = RegExp(AppValues.passwordRegex);
    if (val == null || val.isEmpty) {
      return "كلمة المرور لا يمكن أن تكون فارغة";
    } else if (!passwordRegex.hasMatch(val)) {
      return "الرجاء إدخال كلمة مرور صحيحة";
    } else {
      return null;
    }
  }

  static String? validateConfirmPassword(String? val, String? password) {
    if (val == null || val.isEmpty) {
      return "تأكيد كلمة المرور لا يمكن أن يكون فارغًا";
    } else if (val != password) {
      return "كلمة المرور غير متطابقة";
    } else {
      return null;
    }
  }

  static String? validateName(String? val) {
    if (val == null || val.isEmpty) {
      return "الاسم لا يمكن أن يكون فارغًا";
    } else {
      return null;
    }
  }

  static String? validatePhoneNumber(String? val) {
    if (val == null || val.trim().isEmpty) {
      return "رقم الهاتف لا يمكن أن يكون فارغًا";
    }
    final phone = val.trim();
    final isValid = RegExp(r'^\+?\d+$').hasMatch(phone);
    if (!isValid || phone.length != 13) {
      return "رقم الهاتف غير صحيح";
    }
    return null;
  }

  static String? validateCode(String? val) {
    if (val == null || val.isEmpty) {
      return "الرمز لا يمكن أن يكون فارغًا";
    } else if (val.length < 6) {
      return "يجب أن يكون الرمز 6 أرقام على الأقل";
    } else {
      return null;
    }
  }
}
