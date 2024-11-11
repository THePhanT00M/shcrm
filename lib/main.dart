import 'package:flutter/material.dart';
import 'screens/loading_screen.dart';
import 'screens/auth_selection_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// timezone 패키지 임포트
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 시간대 데이터 초기화
  tz.initializeTimeZones();
  // 기본 시간대를 Asia/Seoul로 설정
  tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', ''), // 한국어 지원
      ],
      locale: const Locale('ko', ''), // 앱의 기본 로케일을 한국어로 설정
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
