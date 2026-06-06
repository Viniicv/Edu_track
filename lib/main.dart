import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/activity_provider.dart';
import 'providers/subject_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_activity_screen.dart';
import 'screens/add_subject_screen.dart';
import 'screens/activities_list_screen.dart';
import 'utils/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => SubjectProvider()),
      ],
      child: MaterialApp(
        title: 'EduTrack',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/calendar': (context) => const HomeScreen(initialIndex: 1),
          '/subjects': (context) => const HomeScreen(initialIndex: 2),
          '/add_activity': (context) => const AddActivityScreen(),
          '/add_subject': (context) => const AddSubjectScreen(),
          '/activities': (context) => const ActivitiesListScreen(),
        },
      ),
    );
  }
}
