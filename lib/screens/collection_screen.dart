import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/acervo_repository.dart';
import '../models/artwork.dart';
import '../widgets/watermark_image.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  List<Artwork> _allArtworks = [];
  List<Artwork> _filtered = [];
  String _selectedPeriod = 'Todas';
  bool _loaded = false;

  final List<String> _periods = [
    'Todas',
    'Anos 70',
    'Anos 80',
    'Anos 90',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await AcervoRepository.instance.loadArtworks();
    if (mounted) {
      setState(() {
        _allArtworks = AcervoRepository.instance.artworks;
        _filtered = _allArtworks;
        _loaded = true;
      });
    }
  }

  void _applyFilter(String period) {
    setState(() {
      _selectedPeriod = period;
      _filtered = AcervoRepository.instance.filter(
        decade: period,
        searchQuery: '',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
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
          : Column(
              children: [
                SizedBox(height: isWide ? 56 : 52),

                // ── Galeria / Mobile ──
                Expanded(
                  child: _filtered.isEmpty
                      ? Center(
                          child: Text(
                            'Nenhuma obra encontrada',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: AppColors.onSurfaceMuted,
                            ),
                          ),
                        )
                      : isWide
                          ? _GalleryCarousel(
                              key: ValueKey(_selectedPeriod),
                              artworks: _filtered,
                            )
                          : _MobileArtworkView(
                              key: ValueKey(_selectedPeriod),
                              artworks: _filtered,
                            ),
                ),

                // ── Filtro de período ──
                _PeriodFilter(
                  periods: _periods,
                  selected: _selectedPeriod,
                  total: _allArtworks.length,
                  filtered: _filtered.length,
                  onChanged: _applyFilter,
                ),
              ],
            ),
    );
  }
}

// ─────────────────────────── VISTA MOBILE ───────────────────────────
class _MobileArtworkView extends StatefulWidget {
  final List<Artwork> artworks;
  const _MobileArtworkView({super.key, required this.artworks});

  @override
  State<_MobileArtworkView> createState() => _MobileArtworkViewState();
}

class _MobileArtworkViewState extends State<_MobileArtworkView> {
  late final PageController _ctrl;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(viewportFraction: 0.90);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _ctrl,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: widget.artworks.length,
            itemBuilder: (context, i) {
              final isCenter = i == _current;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
                margin: EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: isCenter ? 10 : 28,
                ),
                child: _ArtworkFace(artwork: widget.artworks[i]),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            '${_current + 1} / ${widget.artworks.length}',
            style: GoogleFonts.dmSans(
              fontSize: 10,
              letterSpacing: 2,
              color: Colors.black.withValues(alpha: 0.28),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────── GALERIA (DESKTOP) ───────────────────────────
// Fundo: backgroundAcervo.png (parede de galeria com 3 spotlights).
// Os 3 quadros são posicionados sob os pontos de luz, em coordenadas
// proporcionais à imagem original (1672 × 941):
//   Esquerdo:  X=220  Y=330
//   Central:   X=860  Y=330
//   Direito:   X=1450 Y=330
// As setas trocam o "triplete" visível com uma transição que sugere um
// movimento da direita para a esquerda. Clicar numa obra a coloca em
// destaque (overlay) com possibilidade de virar o card.
class _GalleryCarousel extends StatefulWidget {
  final List<Artwork> artworks;
  const _GalleryCarousel({super.key, required this.artworks});

  @override
  State<_GalleryCarousel> createState() => _GalleryCarouselState();
}

class _GalleryCarouselState extends State<_GalleryCarousel>
    with TickerProviderStateMixin {
  // Resolução nativa do PNG do fundo
  static const double _bgW = 1672;
  static const double _bgH = 941;

  // Centros dos pontos de luz no fundo (px no espaço do PNG)
  static const List<double> _spotXs = [220, 860, 1450];
  static const double _spotY = 330;

  // Tamanho dos quadros relativo ao palco (proporcional ao bg)
  static const double _frameWFrac = 0.220;
  static const double _frameHFrac = 0.65;

  // Estado do "triplete" visível: mostra artworks[start..start+2]
  int _viewStart = 0;
  int _prevViewStart = 0;
  int _slideDir = 0; // 1 = next (impressão de mover p/ esquerda); -1 = prev

  // Estado do destaque (índice global da obra focada; -1 = nenhum)
  int _focused = -1;

  late final AnimationController _slideCtrl;
  late final Animation<double> _slideAnim;
  late final AnimationController _flipCtrl;
  late final Animation<double> _flipAnim;
  late final AnimationController _focusCtrl;
  late final Animation<double> _focusAnim;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
    );
    _slideAnim = CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic);

    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _flipAnim = CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut);

    _focusCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _focusAnim = CurvedAnimation(parent: _focusCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _flipCtrl.dispose();
    _focusCtrl.dispose();
    super.dispose();
  }

  bool get _canPrev => _viewStart > 0;
  bool get _canNext => _viewStart + 3 < widget.artworks.length;

  void _slide(int dir) {
    if (_slideCtrl.isAnimating) return;
    if (dir > 0 && !_canNext) return;
    if (dir < 0 && !_canPrev) return;
    if (_focused != -1) {
      _closeFocus();
      return;
    }
    setState(() {
      _slideDir = dir;
      _prevViewStart = _viewStart;
      _viewStart += dir;
    });
    _slideCtrl.forward(from: 0);
  }

  void _focus(int idx) {
    if (_slideCtrl.isAnimating) return;
    if (_focused == idx) return;
    setState(() => _focused = idx);
    _flipCtrl.value = 0;
    _focusCtrl.forward(from: 0);
  }

  Future<void> _closeFocus() async {
    if (_focused == -1) return;
    if (_flipCtrl.value > 0) {
      await _flipCtrl.reverse();
    }
    await _focusCtrl.reverse();
    if (mounted) setState(() => _focused = -1);
  }

  void _toggleFlip() {
    if (_flipCtrl.value > 0.5) {
      _flipCtrl.reverse();
    } else {
      _flipCtrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sw = constraints.maxWidth;
        final sh = constraints.maxHeight;

        final frameW = sw * _frameWFrac;
        final frameH = sh * _frameHFrac;

        return Stack(
          fit: StackFit.expand,
          children: [
            // ── Palco ──
            Stack(
              fit: StackFit.expand,
              children: [
                  // Fundo: parede de galeria
                  Positioned.fill(
                    child: Image.asset(
                      'assets/design/backgroundAcervo.png',
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.high,
                    ),
                  ),

                  // Triplete de saída (durante a animação de slide)
                  AnimatedBuilder(
                    animation: _slideAnim,
                    builder: (_, _) {
                      if (!_slideCtrl.isAnimating) {
                        return const SizedBox.shrink();
                      }
                      final t = _slideAnim.value;
                      // Desliza para o lado oposto à direção de entrada
                      final dx = -_slideDir * frameW * 1.6 * t;
                      return _Triplet(
                        artworks: widget.artworks,
                        start: _prevViewStart,
                        sw: sw,
                        sh: sh,
                        spotXs: _spotXs,
                        spotY: _spotY,
                        bgW: _bgW,
                        bgH: _bgH,
                        frameW: frameW,
                        frameH: frameH,
                        dx: dx,
                        opacity: (1 - t).clamp(0.0, 1.0),
                        interactive: false,
                        onTap: (_) {},
                      );
                    },
                  ),

                  // Triplete atual (entrando ou estável)
                  AnimatedBuilder(
                    animation: _slideAnim,
                    builder: (_, _) {
                      final animating = _slideCtrl.isAnimating;
                      final t = animating ? _slideAnim.value : 1.0;
                      final dx = animating
                          ? (1 - t) * _slideDir * frameW * 1.6
                          : 0.0;
                      return _Triplet(
                        artworks: widget.artworks,
                        start: _viewStart,
                        sw: sw,
                        sh: sh,
                        spotXs: _spotXs,
                        spotY: _spotY,
                        bgW: _bgW,
                        bgH: _bgH,
                        frameW: frameW,
                        frameH: frameH,
                        dx: dx,
                        opacity: animating ? t : 1.0,
                        interactive: !animating && _focused == -1,
                        onTap: _focus,
                      );
                    },
                  ),

                  // Setas
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: sw * 0.10,
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: _focused == -1 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: IgnorePointer(
                          ignoring: _focused != -1,
                          child: _NavArrow(
                            icon: Icons.arrow_back_ios_new_rounded,
                            enabled: _canPrev,
                            onTap: () => _slide(-1),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: sw * 0.10,
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: _focused == -1 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: IgnorePointer(
                          ignoring: _focused != -1,
                          child: _NavArrow(
                            icon: Icons.arrow_forward_ios_rounded,
                            enabled: _canNext,
                            onTap: () => _slide(1),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Contador
                  Positioned(
                    bottom: sh * 0.04,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: _focused == -1 ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            _rangeLabel(),
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              letterSpacing: 2,
                              color: Colors.black.withValues(alpha: 0.34),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            // ── Camada de destaque ──
            if (_focused != -1)
              AnimatedBuilder(
                animation: _focusAnim,
                builder: (_, _) {
                  return _FocusOverlay(
                    artwork: widget.artworks[_focused],
                    flipAnimation: _flipAnim,
                    t: _focusAnim.value,
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    onClose: _closeFocus,
                    onFlip: _toggleFlip,
                  );
                },
              ),
          ],
        );
      },
    );
  }

  String _rangeLabel() {
    final total = widget.artworks.length;
    final from = _viewStart + 1;
    final to = math.min(_viewStart + 3, total);
    return '$from–$to / $total';
  }
}

// ─────────────────────────── TRIPLETE ───────────────────────────
class _Triplet extends StatelessWidget {
  final List<Artwork> artworks;
  final int start;
  final double sw, sh;
  final List<double> spotXs;
  final double spotY;
  final double bgW, bgH;
  final double frameW, frameH;
  final double dx;
  final double opacity;
  final bool interactive;
  final ValueChanged<int> onTap;

  const _Triplet({
    required this.artworks,
    required this.start,
    required this.sw,
    required this.sh,
    required this.spotXs,
    required this.spotY,
    required this.bgW,
    required this.bgH,
    required this.frameW,
    required this.frameH,
    required this.dx,
    required this.opacity,
    required this.interactive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !interactive,
      child: Opacity(
        opacity: opacity,
        child: Stack(
          children: List.generate(3, (slot) {
            final idx = start + slot;
            if (idx < 0 || idx >= artworks.length) {
              return const SizedBox.shrink();
            }
            final spotX = spotXs[slot] / bgW * sw;
            // Quadro centralizado em 54% da altura — bem abaixo dos spotlights
            final frameCenterY = sh * 0.45;
            return Positioned(
              left: spotX - frameW / 2 + dx,
              top: frameCenterY - frameH / 2,
              width: frameW,
              height: frameH,
              child: _GalleryFrame(
                key: ValueKey('frame_${artworks[idx].id}'),
                artwork: artworks[idx],
                onTap: () => onTap(idx),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────── QUADRO NA GALERIA ───────────────────────────
class _GalleryFrame extends StatefulWidget {
  final Artwork artwork;
  final VoidCallback onTap;
  const _GalleryFrame({
    super.key,
    required this.artwork,
    required this.onTap,
  });

  @override
  State<_GalleryFrame> createState() => _GalleryFrameState();
}

class _GalleryFrameState extends State<_GalleryFrame> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hovered ? 1.035 : 1.0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            decoration: BoxDecoration(
              color: const Color(0xFF1F1A14),
              border: Border.all(
                color: const Color(0xFF2A241D),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: _hovered ? 0.42 : 0.32),
                  blurRadius: _hovered ? 28 : 20,
                  offset: const Offset(0, 14),
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(6),
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                widget.artwork.imagePath,
                fit: BoxFit.contain,
                cacheWidth: 480,
                filterQuality: FilterQuality.medium,
                errorBuilder: (ctx, e, st) => Container(
                  color: const Color(0xFFF0EBE1),
                  child: const Center(
                    child: Icon(Icons.image_outlined,
                        color: Color(0xFFCCC5BB), size: 28),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── DESTAQUE (OVERLAY) ───────────────────────────
class _FocusOverlay extends StatelessWidget {
  final Artwork artwork;
  final Animation<double> flipAnimation;
  final double t; // 0 → 1 (entrada/saída do destaque)
  final double width;
  final double height;
  final VoidCallback onClose;
  final VoidCallback onFlip;

  const _FocusOverlay({
    required this.artwork,
    required this.flipAnimation,
    required this.t,
    required this.width,
    required this.height,
    required this.onClose,
    required this.onFlip,
  });

  @override
  Widget build(BuildContext context) {
    final cardW = math.min(440.0, width * 0.45);
    final cardH = math.min(640.0, height * 0.86);

    return Positioned.fill(
      child: Stack(
        children: [
          // Fundo escurecido — captura toques para fechar
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onClose,
              child: Container(
                color: Colors.black.withValues(alpha: 0.60 * t),
              ),
            ),
          ),

          // Card central (acima do fundo, intercepta o toque para virar)
          Center(
            child: Opacity(
              opacity: t,
              child: Transform.scale(
                scale: 0.92 + 0.08 * t,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onFlip,
                  child: SizedBox(
                    width: cardW,
                    height: cardH,
                    child: _FlipCard(
                      artwork: artwork,
                      animation: flipAnimation,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Botão de fechar
          Positioned(
            top: 16,
            right: 16,
            child: Opacity(
              opacity: t,
              child: _CloseButton(onTap: onClose),
            ),
          ),

          // Hint inferior
          Positioned(
            left: 0,
            right: 0,
            bottom: 18,
            child: IgnorePointer(
              child: Opacity(
                opacity: t * 0.85,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app_outlined,
                        size: 12,
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Toque na obra para virar',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          letterSpacing: 1.6,
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CloseButton extends StatefulWidget {
  final VoidCallback onTap;
  const _CloseButton({required this.onTap});

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
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
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: _hovered ? 0.18 : 0.10),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.30),
              width: 0.6,
            ),
          ),
          child: Icon(
            Icons.close_rounded,
            size: 16,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── FLIP CARD ───────────────────────────
class _FlipCard extends StatelessWidget {
  final Artwork artwork;
  final Animation<double> animation;

  const _FlipCard({required this.artwork, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final angle = animation.value * math.pi;
        final isFront = angle < math.pi / 2;
        final renderAngle = isFront ? angle : math.pi - angle;

        return Transform(
          alignment: Alignment.center,
          filterQuality: FilterQuality.high,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(renderAngle),
          child: isFront
              ? _ArtworkFace(artwork: artwork, showWatermark: true)
              : _ArtworkBack(artwork: artwork),
        );
      },
    );
  }
}

// ─────────────────────────── FRENTE DO CARD ───────────────────────────
class _ArtworkFace extends StatelessWidget {
  final Artwork artwork;
  final bool showWatermark;
  const _ArtworkFace({required this.artwork, this.showWatermark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: showWatermark
                  ? WatermarkImage(
                      imagePath: artwork.imagePath,
                      fit: BoxFit.contain,
                      cacheWidth: 900,
                    )
                  : Image.asset(
                      artwork.imagePath,
                      fit: BoxFit.contain,
                      cacheWidth: 600,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (ctx, e, st) => Container(
                        color: const Color(0xFFF0EBE1),
                        child: const Center(
                          child: Icon(Icons.image_outlined,
                              color: Color(0xFFCCC5BB), size: 32),
                        ),
                      ),
                    ),
            ),
          ),
          // Passepartout inferior + título
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artwork.title,
                  style: GoogleFonts.cormorant(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1510),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  artwork.year,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    letterSpacing: 1.5,
                    color: AppColors.accentDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── VERSO DO CARD ───────────────────────────
// Mantém o mesmo formato externo da frente (container branco + sombra).
// Por dentro: textura de canva + etiqueta branca centralizada (estilo
// ficha museal colada atrás de uma obra).
class _ArtworkBack extends StatelessWidget {
  final Artwork artwork;
  const _ArtworkBack({required this.artwork});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/design/canva_back.jpg',
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (_, _, _) =>
                        Container(color: const Color(0xFFE8DFD0)),
                  ),
                  Center(
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 20,
                      ),
                      color: Colors.white,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'LEONILSON',
                            style: GoogleFonts.dmSans(
                              fontSize: 8,
                              letterSpacing: 3,
                              color: const Color(0xFFAA9E93),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            artwork.title,
                            style: GoogleFonts.cormorant(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF1A1510),
                              height: 1.25,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 14),
                          Container(
                            width: 20,
                            height: 0.8,
                            color: const Color(0xFFBFB3A7),
                          ),
                          const SizedBox(height: 14),
                          if (artwork.year.isNotEmpty)
                            Text(
                              artwork.year,
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                letterSpacing: 1.5,
                                color: AppColors.accentDark,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          if (artwork.technique.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              artwork.technique,
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                height: 1.5,
                                color: const Color(0xFF5A5048),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (artwork.size.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              artwork.size,
                              style: GoogleFonts.dmSans(
                                fontSize: 9,
                                color: const Color(0xFF9A8E83),
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  size: 11,
                  color: Colors.black.withValues(alpha: 0.22),
                ),
                const SizedBox(width: 5),
                Text(
                  'Toque para virar',
                  style: GoogleFonts.dmSans(
                    fontSize: 9,
                    letterSpacing: 1,
                    color: Colors.black.withValues(alpha: 0.22),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── SETAS DE NAVEGAÇÃO ───────────────────────────
class _NavArrow extends StatefulWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _NavArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  State<_NavArrow> createState() => _NavArrowState();
}

class _NavArrowState extends State<_NavArrow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.enabled;
    return MouseRegion(
      cursor: active ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: active ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _hovered && active
                ? Colors.white.withValues(alpha: 0.92)
                : Colors.white.withValues(alpha: 0.60),
            shape: BoxShape.circle,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Icon(
            widget.icon,
            size: 18,
            color: Colors.black.withValues(alpha: active ? 0.55 : 0.18),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── FILTRO DE PERÍODO ───────────────────────────
class _PeriodFilter extends StatelessWidget {
  final List<String> periods;
  final String selected;
  final int total;
  final int filtered;
  final ValueChanged<String> onChanged;

  const _PeriodFilter({
    required this.periods,
    required this.selected,
    required this.total,
    required this.filtered,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F5),
        border: Border(
          top: BorderSide(
            color: Colors.black.withValues(alpha: 0.06),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: periods.map((p) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _PeriodChip(
                      label: p,
                      isSelected: p == selected,
                      onTap: () => onChanged(p),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Row(
            children: [
              const ProjectoLeonilsonLogo(height: 18),
              const SizedBox(width: 12),
              Text(
                filtered == total ? '$total obras' : '$filtered de $total',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  letterSpacing: 1,
                  color: Colors.black.withValues(alpha: 0.28),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _PeriodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_PeriodChip> createState() => _PeriodChipState();
}

class _PeriodChipState extends State<_PeriodChip> {
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
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? const Color(0xFF1A1510)
                : (_hovered
                    ? Colors.black.withValues(alpha: 0.05)
                    : Colors.transparent),
            border: Border.all(
              color: widget.isSelected
                  ? const Color(0xFF1A1510)
                  : Colors.black.withValues(alpha: 0.14),
              width: 0.8,
            ),
          ),
          child: Text(
            widget.label.toUpperCase(),
            style: GoogleFonts.dmSans(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: widget.isSelected
                  ? Colors.white
                  : Colors.black.withValues(alpha: 0.42),
            ),
          ),
        ),
      ),
    );
  }
}
