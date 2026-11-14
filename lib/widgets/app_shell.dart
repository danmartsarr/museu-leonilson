import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final location = GoRouterState.of(context).uri.toString();
    return _TransitionWrapper(
      location: location,
      child: isWide ? _WebLayout(child: child) : _MobileLayout(child: child),
    );
  }
}

// ─────────────────────────── TELA DE TRANSIÇÃO ───────────────────────────

class _TransitionWrapper extends StatefulWidget {
  final String location;
  final Widget child;
  const _TransitionWrapper({required this.location, required this.child});

  @override
  State<_TransitionWrapper> createState() => _TransitionWrapperState();
}

class _TransitionWrapperState extends State<_TransitionWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _active = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _active = false);
        _ctrl.reset();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_TransitionWrapper old) {
    super.didUpdateWidget(old);
    if (old.location != widget.location) {
      setState(() => _active = true);
      _ctrl.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_active)
          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              final t = _ctrl.value;
              // bg:      opaco imediato, fade-out no final
              // content: fade-in suave → visível → fade-out junto
              // 0.00–0.18 → content fade-in  | bg opaco
              // 0.18–0.78 → tudo visível, progress preenche
              // 0.78–1.00 → tudo fade-out
              final double bgOpacity;
              final double contentOpacity;
              final double progress;
              if (t < 0.18) {
                bgOpacity = 1.0;
                contentOpacity = (t / 0.18).clamp(0.0, 1.0);
                progress = 0.0;
              } else if (t < 0.78) {
                bgOpacity = 1.0;
                contentOpacity = 1.0;
                progress = (t - 0.18) / (0.78 - 0.18);
              } else {
                final f = (1.0 - (t - 0.78) / 0.22).clamp(0.0, 1.0);
                bgOpacity = f;
                contentOpacity = f;
                progress = 1.0;
              }
              return Opacity(
                opacity: bgOpacity,
                child: _TransitionScreen(
                  progress: progress,
                  contentOpacity: contentOpacity,
                ),
              );
            },
          ),
      ],
    );
  }
}

class _TransitionScreen extends StatelessWidget {
  final double progress;
  final double contentOpacity;
  const _TransitionScreen({
    required this.progress,
    this.contentOpacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: Opacity(
        opacity: contentOpacity,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
          children: [
            // Etiqueta superior
            Text(
              'MUSEU DIGITAL',
              style: GoogleFonts.dmSans(
                fontSize: 9,
                letterSpacing: 4,
                fontWeight: FontWeight.w500,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 20),

            // Nome principal
            Text(
              'LEONILSON',
              style: GoogleFonts.dmSans(
                fontSize: 38,
                fontWeight: FontWeight.w300,
                letterSpacing: 10,
                color: AppColors.onBackground,
              ),
            ),        
            const SizedBox(height: 16),

            // Divisor
            Container(width: 24, height: 0.5, color: AppColors.onSurfaceDisabled),
            const SizedBox(height: 16),

            // Datas e local
            Text(
              '1957 - 1993',
              style: GoogleFonts.dmSans(
                fontSize: 10,
                letterSpacing: 2.5,
                color: AppColors.onSurfaceMuted,
              ),
            ),

            // Linha de progresso
            const SizedBox(height: 48),
            SizedBox(
              width: 80,
              height: 1,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 80 * progress,
                  height: 1,
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── MOBILE ───────────────────────────

class _MobileLayout extends StatelessWidget {
  final Widget child;
  const _MobileLayout({required this.child});

  String _location(BuildContext context) =>
      GoRouterState.of(context).uri.toString();

  int _currentIndex(BuildContext context) {
    final loc = _location(context);
    if (loc.startsWith('/acervo')) return 1;
    if (loc.startsWith('/historia')) return 2;
    if (loc.startsWith('/canva')) return 3;
    return 0;
  }

  bool _isHome(BuildContext context) => _location(context) == '/';

  @override
  Widget build(BuildContext context) {
    final idx = _currentIndex(context);
    final isHome = _isHome(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Conteúdo — troca instantânea (a tela de transição cobre a swap) ──
          child,

          // ── Top nav (persiste sobre o conteúdo, oculto na home) ──
          if (!isHome)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _MobileTopNav(currentIndex: idx),
            ),
        ],
      ),
    );
  }
}

class _MobileTopNav extends StatelessWidget {
  final int currentIndex;
  const _MobileTopNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.95),
        border: const Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => context.go('/'),
              child: Text(
                'LEONILSON',
                style: GoogleFonts.cormorant(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 4,
                  color: AppColors.onBackground,
                ),
              ),
            ),
            const Spacer(),
            _MobileNavLink(
              label: 'INÍCIO',
              isActive: currentIndex == 0,
              onTap: () => context.go('/'),
            ),
            const SizedBox(width: 16),
            _MobileNavLink(
              label: 'ACERVO',
              isActive: currentIndex == 1,
              onTap: () => context.go('/acervo'),
            ),
            const SizedBox(width: 16),
            _MobileNavLink(
              label: 'HISTÓRIA',
              isActive: currentIndex == 2,
              onTap: () => context.go('/historia'),
            ),
            const SizedBox(width: 16),
            _MobileNavLink(
              label: 'CANVA',
              isActive: currentIndex == 3,
              onTap: () => context.go('/canva'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileNavLink extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _MobileNavLink({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
              color: isActive
                  ? AppColors.onBackground
                  : AppColors.onSurfaceMuted,
            ),
          ),
          const SizedBox(height: 3),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? 14 : 0,
            height: 1,
            color: AppColors.accent,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── WEB / TABLET ───────────────────────────

class _WebLayout extends StatelessWidget {
  final Widget child;
  const _WebLayout({required this.child});

  String _location(BuildContext context) =>
      GoRouterState.of(context).uri.toString();

  int _currentIndex(BuildContext context) {
    final loc = _location(context);
    if (loc.startsWith('/acervo')) return 1;
    if (loc.startsWith('/historia')) return 2;
    if (loc.startsWith('/canva')) return 3;
    return 0;
  }

  bool _isHome(BuildContext context) => _location(context) == '/';

  @override
  Widget build(BuildContext context) {
    final idx = _currentIndex(context);
    final isHome = _isHome(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Conteúdo — troca instantânea (a tela de transição cobre a swap) ──
          child,

          // ── Top nav (persiste sem animar) ──
          if (!isHome)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _TopNav(currentIndex: idx),
            ),
        ],
      ),
    );
  }
}

class _TopNav extends StatelessWidget {
  final int currentIndex;
  const _TopNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.92),
        border: const Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo / título
            GestureDetector(
              onTap: () => context.go('/'),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'LEONILSON',
                      style: GoogleFonts.cormorant(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 5,
                        color: AppColors.onBackground,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '1957 — 1993',
                      style: GoogleFonts.dmSans(
                        fontSize: 9,
                        letterSpacing: 2,
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            _TopNavLink(
              label: 'INÍCIO',
              isActive: currentIndex == 0,
              onTap: () => context.go('/'),
            ),
            const SizedBox(width: 32),
            _TopNavLink(
              label: 'ACERVO',
              isActive: currentIndex == 1,
              onTap: () => context.go('/acervo'),
            ),
            const SizedBox(width: 32),
            _TopNavLink(
              label: 'HISTÓRIA',
              isActive: currentIndex == 2,
              onTap: () => context.go('/historia'),
            ),
            const SizedBox(width: 32),
            _TopNavLink(
              label: 'CANVA',
              isActive: currentIndex == 3,
              onTap: () => context.go('/canva'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopNavLink extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TopNavLink({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 2.5,
                color: isActive
                    ? AppColors.onBackground
                    : AppColors.onSurfaceMuted,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 20 : 0,
              height: 1,
              color: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }
}
