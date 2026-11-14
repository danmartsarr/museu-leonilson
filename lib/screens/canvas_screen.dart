import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/acervo_repository.dart';
import '../models/artwork.dart';
import '../widgets/watermark_image.dart';

class CanvasScreen extends StatefulWidget {
  const CanvasScreen({super.key});

  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen>
    with TickerProviderStateMixin {
  List<String> _selected = [];
  bool _loaded = false;

  // ── ZOOM ──
  late final AnimationController _zoomCtrl;
  late final Animation<double> _zoomAnim;
  double _zoomTarget = 1.0;

  static const double _zoomMin = 1.0;
  static const double _zoomMax = 3.0;

  // ── FOCO COM SUAVIZAÇÃO ──
  // _focusTarget: posição crua do mouse (atualizada em onHover, sem setState)
  // _focusValue:  posição suavizada (lerp por frame) usada como anchor do zoom
  // _focusCtrl: controller que dispara o lerp continuamente até o foco alcançar o alvo
  late final AnimationController _focusCtrl;
  Offset _focusTarget = const Offset(0.5, 0.5);
  Offset _focusValue = const Offset(0.5, 0.5);

  Size _screenSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _zoomCtrl = AnimationController(vsync: this);
    _zoomAnim = _zoomCtrl.drive(Tween<double>(begin: _zoomMin, end: _zoomMax));

    _focusCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_smoothFocus);

    _loadImages();
  }

  @override
  void dispose() {
    _zoomCtrl.dispose();
    _focusCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadImages() async {
    await AcervoRepository.instance.loadArtworks();
    final aquarelas = AcervoRepository.instance.artworks
        .where((a) => a.technique.toLowerCase().contains('aquarela'))
        .toList();
    if (!mounted || aquarelas.isEmpty) return;
    final rng = Random();
    final shuffled = List<Artwork>.from(aquarelas)..shuffle(rng);
    setState(() {
      _selected = shuffled.take(4).map((a) => a.imagePath).toList();
      _loaded = true;
    });
    _springTo(0.0);
    _zoomTarget = _zoomMin;
  }

  // Filtro passa-baixa: a cada frame o foco se aproxima do alvo em k%.
  // k=0.12 → ~280ms para chegar a 95% do alvo. Suave, sem saltos.
  void _smoothFocus() {
    const k = 0.12;
    final dx = _focusValue.dx + (_focusTarget.dx - _focusValue.dx) * k;
    final dy = _focusValue.dy + (_focusTarget.dy - _focusValue.dy) * k;
    _focusValue = Offset(dx, dy);

    // Para o controller quando a distância é desprezível — economiza CPU.
    if ((_focusTarget - _focusValue).distance < 0.0008) {
      _focusValue = _focusTarget;
      _focusCtrl.stop();
    }
  }

  void _updateMouseTarget(Offset newPos) {
    if ((newPos - _focusTarget).distance < 0.0005) return;
    _focusTarget = newPos;
    if (!_focusCtrl.isAnimating) _focusCtrl.repeat();
  }

  void _onSceneScroll(double dy) {
    final delta = -dy * 0.0013;
    _zoomTarget = (_zoomTarget + delta).clamp(_zoomMin, _zoomMax);
    _springTo((_zoomTarget - _zoomMin) / (_zoomMax - _zoomMin));
  }

  void _resetZoom() {
    _zoomTarget = _zoomMin;
    _springTo(0.0, stiffness: 130);
  }

  void _springTo(double target, {double stiffness = 90}) {
    final spring = SpringDescription.withDampingRatio(
      mass: 1.0,
      stiffness: stiffness,
      ratio: 1.1,
    );
    _zoomCtrl.animateWith(
      SpringSimulation(spring, _zoomCtrl.value, target, 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    _screenSize = size;
    final isWide = size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFD4C5A9),
      body: !_loaded
          ? const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 1,
                  color: AppColors.accent,
                ),
              ),
            )
          // MouseRegion: atualiza alvo do foco a cada movimento; o suavizador
          // (_focusCtrl) interpola para chegar lá com peso, sem saltos.
          : MouseRegion(
              onHover: (event) {
                if (_screenSize == Size.zero) return;
                _updateMouseTarget(Offset(
                  (event.localPosition.dx / _screenSize.width).clamp(0.0, 1.0),
                  (event.localPosition.dy / _screenSize.height)
                      .clamp(0.0, 1.0),
                ));
              },
              child: Listener(
                onPointerSignal: (event) {
                  if (event is PointerScrollEvent) {
                    _onSceneScroll(event.scrollDelta.dy);
                  }
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // ── Cena com zoom de câmera ──
                    // Listenable.merge: rebuilds a cada tick de zoom OU de foco
                    AnimatedBuilder(
                      animation: Listenable.merge([_zoomAnim, _focusCtrl]),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _TableBackground(),
                          if (isWide)
                            Positioned(
                              top: 72,
                              left: 0,
                              right: 0,
                              child: IgnorePointer(
                                child: Center(
                                  child: Text(
                                    'AQUARELAS',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 10,
                                      letterSpacing: 4,
                                      color: Colors.black
                                          .withValues(alpha: 0.28),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          _PaintingsLayout(
                            paths: _selected,
                            topOffset: isWide ? 56.0 : 52.0,
                          ),
                        ],
                      ),
                      builder: (context, sceneChild) {
                        final zoom = _zoomAnim.value;
                        final isZoomed = zoom > 1.05;
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            // Zoom ancorado no foco suavizado — sem saltos
                            Transform.scale(
                              scale: zoom,
                              alignment: Alignment(
                                _focusValue.dx * 2 - 1,
                                _focusValue.dy * 2 - 1,
                              ),
                              child: sceneChild,
                            ),

                            // Botão reset
                            Positioned(
                              top: 20,
                              left: 20,
                              child: IgnorePointer(
                                ignoring: !isZoomed,
                                child: Opacity(
                                  opacity: isZoomed ? 1.0 : 0.0,
                                  child: GestureDetector(
                                    onTap: _resetZoom,
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: Colors.black
                                              .withValues(alpha: 0.38),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white
                                                .withValues(alpha: 0.18),
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.zoom_out_rounded,
                                          color: Colors.white
                                              .withValues(alpha: 0.85),
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Hint
                            Positioned(
                              bottom: isWide ? 32 : 80,
                              left: 0,
                              right: 0,
                              child: IgnorePointer(
                                child: Center(
                                  child: Text(
                                    isZoomed
                                        ? 'Continue scrollando  ·  Clique na obra para abrir'
                                        : 'Scroll sobre uma obra para se aproximar',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 10,
                                      letterSpacing: 1.5,
                                      color:
                                          Colors.black.withValues(alpha: 0.28),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    // Logo Projeto Leonilson
                    Positioned(
                      bottom: 32,
                      left: 24,
                      child: Opacity(
                        opacity: 0.55,
                        child: ProjectoLeonilsonLogo(
                          height: isWide ? 28 : 22,
                        ),
                      ),
                    ),

                    // Shuffle — fora do AnimatedBuilder
                    Positioned(
                      bottom: isWide ? 32 : 80,
                      right: 32,
                      child: _ShuffleButton(onTap: _loadImages),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// ─────────────────────────── FUNDO ───────────────────────────
class _TableBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Image.asset(
        'assets/design/canva3.png',
        fit: BoxFit.cover, // cobre toda a tela sem bordas
        alignment: Alignment.center,
        errorBuilder: (_, _, _) =>
            Container(color: const Color(0xFFD4C5A9)),
      ),
    );
  }
}

// ─────────────────────────── LAYOUT DAS PINTURAS ───────────────────────────

// Folha branca no canva3.png (tela ref: 1717 × 916 px, topOffset ≈ 56):
//   left=0.248  right=0.772  top=0.045  bottom=0.877
//
// 4 imagens — uma em cada canto da folha branca.
//   sizeFactor = 0.150  →  largura = 0.150 × 1717 ≈ 258 px
//   canto direito: left = 0.772 - 0.150 = 0.622
const List<_PaintingPos> _positions = [
  _PaintingPos(left: 0.248, top: 0.04, rotation: 0.0, sizeFactor: 0.150),
  _PaintingPos(left: 0.622, top: 0.04, rotation: 0.0, sizeFactor: 0.150),
  _PaintingPos(left: 0.248, top: 0.44, rotation: 0.0, sizeFactor: 0.150),
  _PaintingPos(left: 0.622, top: 0.44, rotation: 0.0, sizeFactor: 0.150),
];

class _PaintingPos {
  final double left;
  final double top;
  final double rotation;
  final double sizeFactor;

  const _PaintingPos({
    required this.left,
    required this.top,
    required this.rotation,
    required this.sizeFactor,
  });
}

class _PaintingsLayout extends StatelessWidget {
  final List<String> paths;
  final double topOffset;

  const _PaintingsLayout({
    required this.paths,
    this.topOffset = 0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final count = min(paths.length, _positions.length);

        return Stack(
          children: List.generate(count, (i) {
            final pos = _positions[i];
            final imgW = w * pos.sizeFactor;
            final left = w * pos.left;
            final top = topOffset + (h - topOffset) * pos.top;

            return Positioned(
              left: left,
              top: top,
              child: _PaintingCard(
                path: paths[i],
                width: imgW,
                rotation: pos.rotation,
              ),
            );
          }),
        );
      },
    );
  }
}

// ─────────────────────────── PINTURA — "colada na folha" ───────────────────────────
// StatelessWidget: sem hover animation, sem container branco.
// Sombra mínima de papel para dar profundidade sem quebrar a ilusão de colagem.
class _PaintingCard extends StatelessWidget {
  final String path;
  final double width;
  final double rotation;

  const _PaintingCard({
    required this.path,
    required this.width,
    required this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _openZoom(context),
        child: Transform(
          alignment: Alignment.center,
          filterQuality: FilterQuality.high,
          transform: Matrix4.rotationZ(rotation * pi / 180),
          child: SizedBox(
            width: width,
            // ColorFiltered eleva pixels ≥228 para branco puro (escala 1.12).
            // Na folha branca, branco sobre branco = borda invisível.
            child: Image.asset(
              path,
              fit: BoxFit.contain,
              cacheWidth: 800,
              filterQuality: FilterQuality.high,
              color: const Color(0xFFF0F3F8),
              colorBlendMode: BlendMode.multiply,
              errorBuilder: (_, _, _) => SizedBox(
                width: width,
                height: width * 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openZoom(BuildContext context) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'close',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 240),
      transitionBuilder: (context, animation, secondary, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
      pageBuilder: (context, animation, secondary) {
        return Material(
          type: MaterialType.transparency,
          child: _ZoomDialog(path: path),
        );
      },
    );
  }
}

// ─────────────────────────── ZOOM DIALOG ───────────────────────────
class _ZoomDialog extends StatelessWidget {
  final String path;
  const _ZoomDialog({required this.path});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () {},
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: 0.78,
                  heightFactor: 0.84,
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 6.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.30),
                            blurRadius: 40,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Image.asset(
                        path,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (_, _, _) => Container(
                          width: 300,
                          height: 300,
                          color: const Color(0xFFEEEBE4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 0.8,
                      ),
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white.withValues(alpha: 0.75),
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Scroll ou pinça para ampliar  ·  Clique fora para fechar',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    letterSpacing: 1.5,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── BOTÃO REEMBARALHAR ───────────────────────────
class _ShuffleButton extends StatefulWidget {
  final VoidCallback onTap;
  const _ShuffleButton({required this.onTap});

  @override
  State<_ShuffleButton> createState() => _ShuffleButtonState();
}

class _ShuffleButtonState extends State<_ShuffleButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: _hovered
                ? Colors.black.withValues(alpha: 0.70)
                : Colors.black.withValues(alpha: 0.40),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shuffle_rounded,
                color: Colors.white.withValues(alpha: 0.9),
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(
                'OUTRAS OBRAS',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  letterSpacing: 2,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
