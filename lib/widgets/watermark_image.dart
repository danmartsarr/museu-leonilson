import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Exibe uma imagem de obra com marca d'água do Projeto Leonilson sobreposta.
class WatermarkImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;
  final int? cacheWidth;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const WatermarkImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.contain,
    this.cacheWidth,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          imagePath,
          fit: fit,
          cacheWidth: cacheWidth,
          filterQuality: FilterQuality.high,
          errorBuilder: errorBuilder ??
              (context2, e, st) => Container(
                    color: const Color(0xFFF0EBE1),
                    child: const Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: Color(0xFFCCC5BB),
                        size: 32,
                      ),
                    ),
                  ),
        ),
        // ── Marca d'água em grade diagonal (cacheada) ──
        IgnorePointer(
          child: RepaintBoundary(
            child: ClipRect(
              child: CustomPaint(
                painter: _WatermarkPainter(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WatermarkPainter extends CustomPainter {
  // Posições fixas (frações de width, height) — 12 labels, cobertura razoável
  static const _grid = [
    [0.08, 0.12], [0.50, 0.08], [0.82, 0.18],
    [0.20, 0.38], [0.62, 0.32], [0.10, 0.58],
    [0.45, 0.55], [0.80, 0.50], [0.25, 0.75],
    [0.65, 0.72], [0.05, 0.88], [0.50, 0.90],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final tp = TextPainter(textDirection: TextDirection.ltr)
      ..text = const TextSpan(
        text: '© Projeto Leonilson',
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 10,
          letterSpacing: 2,
          color: Color(0x22000000),
          fontWeight: FontWeight.w500,
        ),
      )
      ..layout();

    for (final pos in _grid) {
      canvas.save();
      final cx = size.width * pos[0];
      final cy = size.height * pos[1];
      canvas.translate(cx, cy);
      canvas.rotate(-0.42);
      tp.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_WatermarkPainter old) => false;
}

/// Logo do Projeto Leonilson para rodapés / sobreposições de direito autoral.
class ProjectoLeonilsonLogo extends StatelessWidget {
  final double height;
  final Color? color;

  const ProjectoLeonilsonLogo({
    super.key,
    this.height = 28,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/design/P.leonilson-02.jpg',
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (ctx, e, st) => _TextFallback(color: color),
    );
  }
}

class _TextFallback extends StatelessWidget {
  final Color? color;
  const _TextFallback({this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      'PROJETO LEONILSON',
      style: GoogleFonts.dmSans(
        fontSize: 8,
        letterSpacing: 2.5,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.onSurfaceMuted,
      ),
    );
  }
}

/// Barra de direitos autorais para o rodapé das páginas.
class CopyrightBar extends StatelessWidget {
  const CopyrightBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ProjectoLeonilsonLogo(height: 18),
          const SizedBox(width: 12),
          Text(
            '© Projeto Leonilson — Todos os direitos reservados',
            style: GoogleFonts.dmSans(
              fontSize: 9,
              letterSpacing: 1,
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}
