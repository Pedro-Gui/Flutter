import 'package:ble/services/route/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ble/themes/theme.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,
      routerConfig: router,
    );
  }
}
