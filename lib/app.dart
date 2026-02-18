import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/transaction_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/i_storage_repository.dart';
import 'repositories/i_totp_repository.dart';
import 'repositories/storage_repository.dart';
import 'repositories/totp_repository.dart';
import 'repositories/transaction_repository.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/totp_verification_screen.dart';
import 'screens/home/dashboard_screen.dart';
import 'services/i_image_picker_service.dart';
import 'services/image_picker_service.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final totpRepository = TotpRepository();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            repository: AuthRepository(),
            totpRepository: totpRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              TransactionProvider(repository: TransactionRepository()),
        ),
        Provider<IStorageRepository>(create: (_) => StorageRepository()),
        Provider<IImagePickerService>(create: (_) => ImagePickerServiceImpl()),
        Provider<ITotpRepository>(create: (_) => totpRepository),
      ],
      child: MaterialApp(
        title: 'Finance App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.pendingTotpVerification) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    if (!(authProvider.user?.emailVerified ?? false)) {
      return const EmailVerificationScreen();
    }

    if (authProvider.pendingTotpVerification) {
      return const TotpVerificationScreen();
    }

    return const DashboardScreen();
  }
}
