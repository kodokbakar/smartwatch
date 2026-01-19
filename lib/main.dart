import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Firebase (GA4)
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

// File ini dibuat otomatis oleh FlutterFire CLI: `flutterfire configure`
import 'firebase_options.dart';

import 'app/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load env agar URL & anonKey Supabase tidak hardcode di source code.
  await dotenv.load(fileName: ".env");

  // Inisialisasi Supabase (backend utama aplikasi: auth, database, storage).
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Inisialisasi Firebase Core.
  // Di project ini Firebase dipakai untuk GA4 (analytics) saja, bukan untuk backend.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Instance GA4 + observer untuk mencatat perpindahan halaman (screen_view) via Navigator.
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final FirebaseAnalyticsObserver analyticsObserver =
      FirebaseAnalyticsObserver(analytics: analytics);

  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,

      // GA4: membantu tracking screen_view saat navigasi terjadi.
      navigatorObservers: [analyticsObserver],
    ),
  );
}
