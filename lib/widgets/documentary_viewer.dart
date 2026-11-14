import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Abre o visualizador fullscreen para imagens do documentário.
/// [images] é a lista de (path, título, subtítulo).
/// [initialIndex] é a imagem que abre primeiro.
void showDocumentaryViewer(
  BuildContext context,
  List<(String, String, String)> images,
  int initialIndex,
) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Fechar',
    barrierColor: Colors.black.withValues(alpha: 0.95),
    transitionDuration: const Duration(milliseconds: 220),
    transitionBuilder: (context, anim, secondary, child) => FadeTransition(
      opacity: anim,
      child: child,
    ),
    pageBuilder: (context, anim, secondary) => _DocumentaryViewer(
      images: images,
      initialIndex: initialIndex,
    ),
  );
}

class _DocumentaryViewer extends StatefulWidget {
  final List<(String, String, String)> images;
  final int initialIndex;

  const _DocumentaryViewer({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_DocumentaryViewer> createState() => _DocumentaryViewerState();
}

class _DocumentaryViewerState extends State<_DocumentaryViewer> {
  late int _index;
  late final TransformationController _transformController;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _transformController = TransformationController();
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _goTo(int newIndex) {
    if (newIndex < 0 || newIndex >= widget.images.length) return;
    _transformController.value = Matrix4.identity();
    setState(() => _index = newIndex);
  }

  void _onDragEnd(DragEndDetails details) {
    const threshold = 100.0;
    if (details.primaryVelocity == null) return;
    if (details.primaryVelocity! < -threshold) {
      _goTo(_index + 1);
    } else if (details.primaryVelocity! > threshold) {
      _goTo(_index - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (path, title, subtitle) = widget.images[_index];
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final hasPrev = _index > 0;
    final hasNext = _index < widget.images.length - 1;

    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) _goTo(_index + 1);
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) _goTo(_index - 1);
          if (event.logicalKey == LogicalKeyboardKey.escape) Navigator.pop(context);
        }
      },
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Stack(
            children: [
              // ── Imagem com zoom e swipe ──
              GestureDetector(
                onHorizontalDragEnd: _onDragEnd,
                child: InteractiveViewer(
                  transformationController: _transformController,
                  minScale: 1.0,
                  maxScale: 5.0,
                  child: Center(
                    child: Image.asset(
                      path,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) =>
                          Container(color: AppColors.surface),
                    ),
                  ),
                ),
              ),

              // ── Barra superior ──
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 24 : 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      // Fechar
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: AppColors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Contador
                      Text(
                        '${_index + 1} / ${widget.images.length}',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          letterSpacing: 2,
                          color: AppColors.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Barra inferior com título ──
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    isWide ? 64 : 24,
                    32,
                    isWide ? 64 : 24,
                    isWide ? 32 : 24,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.85),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (title.isNotEmpty)
                              Text(
                                title,
                                style: GoogleFonts.cormorant(
                                  fontSize: isWide ? 22 : 18,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.white,
                                  height: 1.3,
                                ),
                              ),
                            if (subtitle.isNotEmpty) ...[
                              if (title.isNotEmpty) const SizedBox(height: 4),
                              Text(
                                subtitle,
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  color: AppColors.onSurfaceMuted,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Hint de zoom (só na primeira vez)
                      Text(
                        'pinça para ampliar',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          color: AppColors.onSurfaceDisabled,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Seta esquerda ──
              if (hasPrev)
                Positioned(
                  left: isWide ? 16 : 4,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _NavButton(
                      icon: Icons.chevron_left,
                      onTap: () => _goTo(_index - 1),
                    ),
                  ),
                ),

              // ── Seta direita ──
              if (hasNext)
                Positioned(
                  right: isWide ? 16 : 4,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _NavButton(
                      icon: Icons.chevron_right,
                      onTap: () => _goTo(_index + 1),
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

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.onBackground, size: 24),
      ),
    );
  }
}
