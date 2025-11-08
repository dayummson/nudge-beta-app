import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'features/test/home_page.dart'; // import the HomePage we built
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // debugPaintSizeEnabled = true;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    // Create color schemes from a seed so light/dark are consistent.
    final lightScheme = ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    );
    final darkScheme = ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'Expense/Income Demo',
      // Use ThemeData.from so colorScheme drives the app colors. Keep the
      // Google font for typography. Pass useMaterial3 directly to avoid
      // deprecated copyWith usage.
      theme: ThemeData.from(
        colorScheme: lightScheme,
        textTheme: GoogleFonts.nunitoTextTheme(),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.from(
        colorScheme: darkScheme,
        textTheme: GoogleFonts.nunitoTextTheme(),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,

      home: const HomePage(), // our home page
      debugShowCheckedModeBanner: false,
    );
  }
}
