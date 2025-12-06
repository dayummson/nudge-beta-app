import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/home/presentation/pages/home_page.dart'
    as home; // Use alias to avoid conflicts
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/theme_provider.dart';
import 'package:app_links/app_links.dart';
import 'core/db/app_database.dart';
import 'core/settings/room_selection.dart';

// Global theme notifier
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

// Deep link handler
final appLinks = AppLinks();

// Global navigator key for deep linking
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Pending deep link to handle after app initialization
Uri? _pendingDeepLink;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Load saved theme preference
  final themeProvider = ThemeProvider();
  await themeProvider.loadThemePreference();
  themeNotifier.value = themeProvider.themeMode2Flutter;

  // Initialize deep link handling
  _initDeepLinks();

  // debugPaintSizeEnabled = true;
  runApp(const ProviderScope(child: MyApp()));
}

// Handle deep links
void _initDeepLinks() {
  // Handle initial link when app is launched
  appLinks.getInitialLink().then((link) {
    if (link != null) {
      _handleDeepLink(link);
    }
  });

  // Handle links while app is running
  appLinks.uriLinkStream.listen((link) {
    _handleDeepLink(link);
  });
}

// Parse and handle deep links
void _handleDeepLink(Uri uri) {
  debugPrint('🔗 Handling deep link: $uri');

  // Store the deep link to handle after app initialization
  _pendingDeepLink = uri;

  // If navigator is ready, handle immediately
  if (navigatorKey.currentContext != null) {
    _processDeepLink(uri);
  }
}

// Process the deep link with proper context
void _processDeepLink(Uri uri) async {
  final context = navigatorKey.currentContext;
  if (context == null) return;

  // Handle room sharing links
  if (uri.host == 'nudge.app' && uri.path.startsWith('/room/')) {
    final roomId = uri.pathSegments.last;
    await _handleRoomDeepLink(context, roomId);
  } else if (uri.scheme == 'nudge') {
    // Handle custom scheme links
    final path = uri.path;
    if (path.startsWith('/room/')) {
      final roomId = path.substring(6); // Remove '/room/'
      await _handleRoomDeepLink(context, roomId);
    }
  }
}

// Handle room deep link navigation
Future<void> _handleRoomDeepLink(BuildContext context, String roomId) async {
  debugPrint('🏠 Processing room deep link: $roomId');

  try {
    final db = AppDatabase();
    final room = await db.roomsDao.getRoomById(roomId);

    if (room != null) {
      // Room exists, select it
      await RoomSelection.setSelectedRoomId(roomId);
      debugPrint('✅ Room selected: ${room.name}');

      // Show success feedback
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Joined room: ${room.name}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Room doesn't exist, show error
      debugPrint('❌ Room not found: $roomId');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Room not found or access denied'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  } catch (e) {
    debugPrint('❌ Error handling room deep link: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error joining room'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Process any pending deep link after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pendingDeepLink != null) {
        _processDeepLink(_pendingDeepLink!);
        _pendingDeepLink = null; // Clear after processing
      }
    });
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

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, child) {
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
          themeMode: themeMode,

          home:
              const home.HomePage(), // Use aliased import to ensure correct HomePage
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
