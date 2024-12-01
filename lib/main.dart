import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize router
  await AppRouter.initialize();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
