import 'package:digipotia/auth/presentation/view_model/forget_password/forget_password_cubit.dart';
import 'package:digipotia/core/routes/routes.dart';
import 'package:digipotia/features/app_section/app_section.dart';
import 'package:digipotia/home/home_screen.dart';
import 'package:digipotia/onboarding/onboarding.dart';
import 'package:digipotia/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/presentation/view/email_verification_screen.dart';
import '../../auth/presentation/view/forget_password.dart';
import '../../auth/presentation/view/login.dart';
import '../../auth/presentation/view/register.dart';
import '../../auth/presentation/view/reset_password_scree.dart';
import '../../auth/presentation/view_model/login/login_cubit.dart';
import '../di/service_locator.dart';
import '../../features/reports/presentation/pages/feed_page.dart';
import '../../features/reports/presentation/pages/report_details_page.dart';
import '../../features/reports/presentation/pages/create_report_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/authorities/presentation/pages/authorities_page.dart';

class RouteGenerator {
  static Route<dynamic>? getRoute(RouteSettings settings) {
    final arg = settings.arguments;
    switch (settings.name) {
      case Routes.login:
        return MaterialPageRoute(
          builder: (context) => LoginScreen(),

        );

      case Routes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case Routes.forgetPassword:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => serviceLocator<ForgetPasswordCubit>(),
            child: const ForgetPasswordScreen(),
          ),
        );
      case Routes.emailVerification:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: arg as ForgetPasswordCubit,
            child:  EmailVerificationScreen(),
          ),
        );
      case Routes.home:
        return MaterialPageRoute(
          builder: (_) =>  HomeScreen(),

        );

      case Routes.feed:
        return MaterialPageRoute(
          builder: (_) => const FeedPage(),
        );
      // case Routes.reportDetails:
      //   return MaterialPageRoute(
      //     builder: (_) => ReportDetailsPage(id: arg as String),
      //   );
      case Routes.createReport:
        return MaterialPageRoute(
          builder: (_) => const CreateReportWizard(),
        );
      case Routes.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
        );
      case Routes.authorities:
        return MaterialPageRoute(
          builder: (_) => const AuthoritiesPage(),
        );

      case Routes.resetPassword:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: arg as ForgetPasswordCubit,
            child: ResetPasswordScreen(),
          ),
        );
      case Routes.appSection:
        return MaterialPageRoute(
          builder: (_) => const MainPage(),
        );
      case Routes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
      case Routes.onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnBoardingScreen(),
        );



      default:
        return _undefinedRoute();
    }
  }

  static Route<dynamic>? _undefinedRoute() {
    return null;
  }
}
