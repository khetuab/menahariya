// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:menahariya/config/environment/env_config.dart';
import 'package:menahariya/config/network/dio_config.dart';
import 'package:menahariya/config/translations/app_translations.dart';
import 'package:menahariya/core/bindings/initial_binding.dart';
import 'package:menahariya/core/constants/app_constants.dart';
import 'package:menahariya/core/routes/app_pages.dart';
import 'package:menahariya/core/services/storage/local_storage.dart';
import 'package:menahariya/core/services/storage/shared_prefs.dart';
import 'package:menahariya/core/theme/light_theme.dart';
import 'package:menahariya/modules/auth/views/login_view.dart';
import 'package:menahariya/modules/common/views/not_found_view.dart';

import 'core/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    // Initialize environment FIRST (before anything else)
    await EnvConfig.initialize(environment: Environment.development);
    print('✅ Environment initialized: ${EnvConfig.instance.environmentName}');
    print('✅ API Base URL: ${EnvConfig.instance.apiBaseUrl}');

    // Initialize Dio with environment config
    DioConfig().init();
    print('✅ Dio initialized');

    // Initialize storage
    await SharedPrefs().init();
    await LocalStorage().init();
    print('✅ Storage initialized');

    // Run app
    runApp(const MenahariyaSmartApp());
  } catch (e, stackTrace) {
    print('❌ Initialization error: $e');
    print(stackTrace);

    // Run app with error widget
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Initialization Failed',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    e.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                    child: const Text('Restart App'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MenahariyaSmartApp extends StatelessWidget {
  const MenahariyaSmartApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // App Info
      title: AppConstants.appName,
      debugShowCheckedModeBanner: EnvConfig.instance.isDevelopment,

      // Theme
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      // Localization
      translations: AppTranslations(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      supportedLocales: AppTranslations.supportedLocales,

      // Routing
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      unknownRoute: GetPage(
        name: '/not-found',
        page: () => const NotFoundView(),
      ),

      // Initial Bindings
      initialBinding: InitialBinding(),

      // Other Configurations
      defaultTransition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),

      // Builder for environment badge in development
      builder: (context, child) {
        return EnvConfig.instance.isDevelopment
            ? _buildEnvironmentBadge(context, child!)
            : child!;
      },
    );
  }

  Widget _buildEnvironmentBadge(BuildContext context, Widget child) {
    return Stack(
      children: [
        child,
        Positioned(
          top: 40,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: EnvConfig.instance.environment.color.withOpacity(0.8),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              EnvConfig.instance.environment.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}