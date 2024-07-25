import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapmeal/firebase_options.dart';
import 'package:snapmeal/pages/auth/choose_role_page.dart';
import 'package:snapmeal/pages/auth/login_page.dart';
import 'package:snapmeal/pages/auth/register_page.dart';
import 'package:snapmeal/pages/auth/verify_user_page.dart';
import 'package:snapmeal/pages/cart/cart_page.dart';
import 'package:snapmeal/pages/components/constants.dart';
import 'package:snapmeal/pages/components/main_page.dart';
import 'package:snapmeal/pages/components/splash_screen.dart';
import 'package:snapmeal/pages/manage_category/category_list_page.dart';
import 'package:snapmeal/pages/settings/qr_code_page.dart';
import 'package:snapmeal/pages/settings/restaurant_settings_page.dart';
import 'package:snapmeal/pages/settings/settings_page.dart';
import 'package:snapmeal/providers/cart_provider.dart';
import 'package:snapmeal/providers/category_provider.dart';
import 'package:snapmeal/providers/item_provider.dart';
import 'package:snapmeal/providers/auth_service.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:snapmeal/pages/menu/menu_page.dart';
// import 'package:snapmeal/pages/scan/scan_page.dart';
// import 'package:snapmeal/pages/favorite/favourite_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthService()),
      ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ChangeNotifierProvider(create: (_) => ItemProvider()),
      ChangeNotifierProvider(create: (_) => CartProvider()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        useMaterial3: true,

        // Define the default brightness and colors.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          outline: Colors.blueGrey,
          error: errorColor,
          // primary: primColor,
          primaryContainer: secColor,
          onPrimaryContainer: Colors.white,
          // ···
          brightness: Brightness.light,
        ),

        // Define the default `TextTheme`. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
      //   textTheme: TextTheme(
      //     displayLarge: const TextStyle(
      //       fontSize: 72,
      //       fontWeight: FontWeight.bold,
      //     ),
      //     titleLarge: GoogleFonts.outfit(
      //       fontSize: 24,
      //     ),
      //     bodyMedium: GoogleFonts.outfit(
      //       fontSize: 18,
      //       color: primColor,
      //     ),
      //     bodySmall: GoogleFonts.outfit(
      //       fontSize: 18,
      //       color: primColor,
      //     ),
      //     displaySmall: GoogleFonts.outfit(),
      //   ),
      ),
      home: const AuthChecker(),
      // initialRoute: '/choose_role',
      routes: {
        '/choose_role': (context) => const ChooseRolePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/verify_user': (context) =>  const VerifyUserPage(),
        '/manage_menu': (context) => const CategoryListPage(),
        '/restaurant': (context) => RestaurantSettingsPage(),
        '/settings': (context) => const SettingsPage(),
        '/qr_code': (context) => const QRCodePage(),
        '/main_page': (context) => const MainPage(),
        '/cart': (context) => const CartPage(),
        // '/menu': (context) => const MenuPage(),
        // '/scan': (context) => const ScanPage(),
        // '/favorite': (context) => FavoritePage(),
      },
    ),
  );
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      // Get authentication state of the user
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        } else {
          if (snapshot.hasData) {
            // If the user is authenticated
            Provider.of<AuthService>(context, listen: false)
                                            .getCurrentUserInfo();
            return const MainPage();
          } else {
            // If the user is not authenticated
            return const ChooseRolePage();
          }
        }
      },
    );
  }
}
