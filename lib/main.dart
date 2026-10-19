import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router.dart';
import 'app/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: OriginApp(),
    ),
  );
}

class OriginApp extends StatelessWidget {
  const OriginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ORIGIN — Where Royalty Begins',
      debugShowCheckedModeBanner: false,
      theme: originTheme(),
      routerConfig: originRouter,
    );
  }
}
