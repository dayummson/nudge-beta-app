import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/home/presentation/pages/home_page.dart'
    as home; // Use alias to avoid conflicts
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // debugPaintSizeEnabled = true;
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Create color schemes from a seed so light/dark are consistent.
    final lightScheme = ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    );

    // Friendly dark theme with softer, warmer colors
    final darkScheme = ColorScheme.dark(
      primary: const Color(0xFF8AB4F8), // Soft blue
      secondary: const Color(0xFFB4C5E4), // Light blue-grey
      surface: const Color(0xFF1E1E1E), // Softer dark background
      background: const Color(0xFF121212), // Slightly lighter than pure black
      error: const Color(0xFFCF6679),
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: const Color(0xFFE1E1E1), // Soft white for text
      onBackground: const Color(0xFFE1E1E1),
      onError: Colors.black,
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
        textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme)
            .apply(
              bodyColor: const Color(0xFFE1E1E1),
              displayColor: const Color(0xFFE1E1E1),
            ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,

      home:
          const home.HomePage(), // Use aliased import to ensure correct HomePage
      debugShowCheckedModeBanner: false,
    );
  }
}
