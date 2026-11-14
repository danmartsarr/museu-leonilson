import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/collection_screen.dart';
import 'screens/artwork_detail_screen.dart';
import 'screens/biography_screen.dart';
import 'screens/canvas_screen.dart';
import 'widgets/app_shell.dart';
import 'theme/app_theme.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: '/acervo',
          pageBuilder: (context, state) => NoTransitionPage(child: CollectionScreen()),
        ),
        GoRoute(
          path: '/historia',
          pageBuilder: (context, state) => NoTransitionPage(child: BiographyScreen()),
        ),
        GoRoute(
          path: '/canva',
          pageBuilder: (context, state) => NoTransitionPage(child: CanvasScreen()),
        ),
      ],
    ),
    GoRoute(
      path: '/obra/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final index = int.tryParse(state.uri.queryParameters['index'] ?? '0') ?? 0;
        return ArtworkDetailScreen(artworkId: id, initialIndex: index);
      },
    ),
  ],
);

class LeonilsonApp extends StatelessWidget {
  const LeonilsonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Leonilson',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: _router,
    );
  }
}
