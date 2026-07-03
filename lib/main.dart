import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'shared/runtime/app_runtime.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final firebaseOptions = DefaultFirebaseOptions.currentPlatform;
  final hasFirebaseConfig =
      !firebaseOptions.apiKey.contains('REPLACE_WITH_FIREBASE');

  if (hasFirebaseConfig) {
    try {
      await Firebase.initializeApp(options: firebaseOptions);
      AppRuntime.firebaseReady = true;
    } catch (_) {
      AppRuntime.firebaseReady = false;
    }
  }

  // Initialize Hive for local storage
  await Hive.initFlutter();
  await Hive.openBox('cart');

  runApp(
    const ProviderScope(
      child: BaeTalkApp(),
    ),
  );
}
