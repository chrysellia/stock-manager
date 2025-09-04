import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gestion_stock_epicerie/providers/auth_provider.dart';
import 'package:gestion_stock_epicerie/routes.dart';
import 'package:gestion_stock_epicerie/screens/auth/login_screen.dart';
import 'package:gestion_stock_epicerie/screens/dashboard/dashboard_screen.dart';
import 'package:gestion_stock_epicerie/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuration de l'orientation de l'application
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion Stock',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      navigatorKey: AppRoutes.navigatorKey,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', ''),
      ],
      home: const AuthWrapper(),
      onGenerateRoute: (settings) => AppRoutes.generateRoute(settings),
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            final currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          child: child!,
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      final authProvider = context.read<AuthProvider>();
      
      // Add a timeout to prevent hanging
      await authProvider.initialize().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('Auth initialization timed out');
          return null;
        },
      );
    } catch (e) {
      debugPrint('Auth initialization error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only show loading if we're still initializing
    if (_isInitializing) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Handle initial navigation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          
          final currentRoute = ModalRoute.of(context)?.settings.name;
          final isLoginRoute = currentRoute == AppRoutes.login || currentRoute == '/';
          
          if (authProvider.isAuthenticated) {
            if (isLoginRoute) {
              Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
            }
          } else {
            if (!isLoginRoute) {
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            }
          }
        });

        // If we're on the login route, show it immediately
        final currentRoute = ModalRoute.of(context)?.settings.name;
        final isLoginRoute = currentRoute == AppRoutes.login || currentRoute == '/';
        
        if (isLoginRoute) {
          return const LoginScreen();
        }
        
        // If we're authenticated, show the dashboard
        if (authProvider.isAuthenticated) {
          return const DashboardScreen();
        }
        
        // Show loading indicator while we figure out where to go
        return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
