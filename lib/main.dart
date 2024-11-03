import 'package:flutter/material.dart';
import 'screens/loading_screen.dart';
import 'screens/auth_selection_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SHCRM',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF767676),
        ).copyWith(
          primary: const Color(0xFFF767676),
          primaryContainer: const Color(0xFFF767676),
          secondary: const Color(0xFFF767676),
          secondaryContainer: const Color(0xFFF767676),
          background: const Color(0xFFF767676),
          surface: const Color(0xFFF767676),
          error: const Color(0xFFF767676),
          onPrimary: const Color(0xFFF767676),
          onSecondary: const Color(0xFFF767676),
          onBackground: const Color(0xFFF767676),
          onSurface: const Color(0xFFF000000),
          onError: const Color(0xFFF767676),
        ),
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ko', ''), // Korean
      ],
      locale: const Locale('ko', ''), // Set the locale to Korean
      initialRoute: '/',
      routes: {
        '/': (context) => LoadingScreen(),
        '/auth-selection': (context) => AuthSelectionScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
