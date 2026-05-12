import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_mongo/services/route/router.dart';
import 'package:todo_mongo/themes/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp( const ProviderScope(child: MainApp(),)    );
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
