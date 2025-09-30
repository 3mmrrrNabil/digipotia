import 'package:digipotia/core/di/service_locator.config.dart';
import 'package:digipotia/splash/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:device_preview/device_preview.dart'; // <- إضافة مكتبة device_preview
import 'package:timeago/timeago.dart' as timeago;
import 'package:timeago/src/messages/ar_messages.dart';

import 'core/constants/app_values.dart';
import 'core/di/service_locator.dart';
import 'core/routes/route_generator.dart';
import 'core/routes/routes.dart';
import 'core/storage_helper/app_shared_preference_helper.dart';
import 'features/reports/presentation/cubit/feed_cubit.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await serviceLocator.init();
  await SharedPreferencesHelper.init();
  timeago.setLocaleMessages('ar', ArMessages());

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final token = await SharedPreferencesHelper.getString(AppValues.token);
    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return MultiBlocProvider(
      providers: [
        BlocProvider<FeedCubit>(
          create: (_) => serviceLocator<FeedCubit>()..loadFirstPage(),
        ),
      ],
      child: MaterialApp(
        useInheritedMediaQuery: true, // مهم للـ DevicePreview
        debugShowCheckedModeBanner: false,
        onGenerateRoute: RouteGenerator.getRoute,
        initialRoute: Routes.splash,

        // دعم اللغة العربية
        locale: DevicePreview.locale(context) ?? const Locale('ar', 'EG'),
        supportedLocales: const [
          Locale('ar', 'EG'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        builder: (context, child) {
          child = Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
          return DevicePreview.appBuilder(context, child); // مهم للـ DevicePreview
        },
      ),
    );
  }
}
