import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/acervo_repository.dart';
import '../models/artwork.dart';
import '../widgets/documentary_viewer.dart';
import '../data/documentary_repository.dart';
import '../widgets/watermark_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Artwork> _artworks = [];
  String? _heroPath;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Carrega acervo e imagens do documentário em paralelo
    final artworkFuture = AcervoRepository.instance.loadArtworks();
    final docFuture = loadDocumentaryPaths();
    await artworkFuture;
    final docPaths = await docFuture;

    if (mounted) {
      setState(() {
        _artworks = AcervoRepository.instance.artworks;
        if (docPaths.isNotEmpty) {
          _heroPath = docPaths[Random().nextInt(docPaths.length)];
        }
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _Hero(heroPath: _heroPath)),
                SliverToBoxAdapter(
                  child: _EditorialIntro(artworks: _artworks),
                ),
                SliverToBoxAdapter(
                  child: _FeaturedStrip(artworks: _artworks),
                ),
                const SliverToBoxAdapter(child: _DocumentarySection()),
                const SliverToBoxAdapter(child: _Footer()),
              ],
            ),
    );
  }
}

// ─────────────────────────── HERO — IMAGEM QUE SE ENQUADRA ───────────────────────────
class _Hero extends StatefulWidget {
  final String? heroPath;
  const _Hero({required this.heroPath});

  @override
  State<_Hero> createState() => _HeroState();
}

class _HeroState extends State<_Hero> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _shrink;  // 0→1: image goes from full-bleed to framed
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    // Imagem começa a encolher depois de 20% e termina em 75%
    _shrink = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.18, 0.72, curve: Curves.easeInOutCubic),
    );

    // Texto aparece depois que o enquadramento começa (55% → 92%)
    _textFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.52, 0.92, curve: Curves.easeOut),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.52, 0.92, curve: Curves.easeOut),
    ));

    // Pequena pausa para a imagem renderizar antes de animar
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= 900;

    return SizedBox(
      height: size.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Fundo preto (aparece como borda quando a imagem encolhe) ──
          const ColoredBox(color: AppColors.background),

          // ── Imagem que se enquadra ──
          AnimatedBuilder(
            animation: _shrink,
            builder: (context, child) {
              final hPad = _shrink.value * size.width * 0.058;
              final vPad = _shrink.value * size.height * 0.065;
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: hPad,
                  vertical: vPad,
                ),
                child: child,
              );
            },
            child: widget.heroPath != null
                ? Image.asset(
                    widget.heroPath!,
                    fit: BoxFit.cover,
                    cacheWidth: 1400,
                    errorBuilder: (_, _, _) =>
                        Container(color: AppColors.surface),
                  )
                : Container(color: AppColors.surface),
          ),

          // ── Gradiente para leitura do texto ──
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x88000000),
                  Color(0x55000000),
                  Color(0xCC000000),
                ],
                stops: [0.0, 0.38, 1.0],
              ),
            ),
          ),

          // ── Texto central (aparece com o enquadramento) ──
          FadeTransition(
            opacity: _textFade,
            child: SlideTransition(
              position: _textSlide,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 80 : 32,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Linha decorativa + label
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 28,
                            height: 0.8,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'GALERIA DIGITAL',
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              letterSpacing: 3.5,
                              color: AppColors.accent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Container(
                            width: 28,
                            height: 0.8,
                            color: AppColors.accent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Nome principal
                      Text(
                        'LEONILSON',
                        style: GoogleFonts.cormorant(
                          fontSize: isWide ? 100 : 62,
                          fontWeight: FontWeight.w200,
                          letterSpacing: isWide ? 22 : 12,
                          color: AppColors.white,
                          height: 0.9,
                          shadows: const [
                            Shadow(
                              color: Color(0xCC000000),
                              blurRadius: 24,
                              offset: Offset(0, 2),
                            ),
                            Shadow(
                              color: Color(0x66000000),
                              blurRadius: 48,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Fortaleza, 1957  ·  São Paulo, 1993',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          letterSpacing: 2,
                          color: AppColors.onSurface,
                          shadows: const [
                            Shadow(
                              color: Color(0xAA000000),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 52),

                      // CTAs
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          _HeroBtn(
                            label: 'VER ACERVO',
                            primary: true,
                            onTap: () => context.go('/acervo'),
                          ),
                          _HeroBtn(
                            label: 'CONHECER MAIS',
                            primary: false,
                            onTap: () => context.go('/historia'),
                          ),
                        ],
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

class _HeroBtn extends StatefulWidget {
  final String label;
  final bool primary;
  final VoidCallback onTap;
  const _HeroBtn({
    required this.label,
    required this.primary,
    required this.onTap,
  });

  @override
  State<_HeroBtn> createState() => _HeroBtnState();
}

class _HeroBtnState extends State<_HeroBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _hovered = true);
        _ctrl.forward();
      },
      onExit: (_) {
        setState(() => _hovered = false);
        _ctrl.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scale,
          builder: (context, child) => Transform.scale(
            scale: _scale.value,
            child: child,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            decoration: BoxDecoration(
              color: widget.primary
                  ? (_hovered
                      ? AppColors.accentLight
                      : AppColors.accent)
                  : (_hovered
                      ? AppColors.onSurface.withValues(alpha: 0.08)
                      : Colors.transparent),
              border: Border.all(
                color: widget.primary
                    ? (_hovered ? AppColors.accentLight : AppColors.accent)
                    : AppColors.onSurface.withValues(alpha: 0.5),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.5,
                    color: widget.primary ? AppColors.black : AppColors.onSurface,
                  ),
                ),
                if (widget.primary) ...[
                  const SizedBox(width: 10),
                  Icon(Icons.arrow_forward, size: 13, color: AppColors.black),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── EDITORIAL INTRO ───────────────────────────
class _EditorialIntro extends StatelessWidget {
  final List<Artwork> artworks;
  const _EditorialIntro({required this.artworks});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 64 : 28,
        vertical: isWide ? 88 : 64,
      ),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 5,
                  child: _EditorialText(isWide: isWide),
                ),
                const SizedBox(width: 56),
                Expanded(
                  flex: 4,
                  child: _EditorialImages(artworks: artworks),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EditorialImages(artworks: artworks),
                const SizedBox(height: 48),
                _EditorialText(isWide: isWide),
              ],
            ),
    );
  }
}

class _EditorialText extends StatelessWidget {
  final bool isWide;
  const _EditorialText({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Container(width: 20, height: 0.8, color: AppColors.accent),
            const SizedBox(width: 10),
            Text(
              'O ARTISTA',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.accent,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Frase do artista
        Text(
          '"Morro pela boca\nvivo pelos olhos"',
          style: GoogleFonts.cormorant(
            fontSize: isWide ? 42 : 30,
            fontWeight: FontWeight.w300,
            fontStyle: FontStyle.italic,
            color: AppColors.onBackground,
            height: 1.25,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          '— José Leonilson · Nanquim sobre papel, c. 1990',
          style: GoogleFonts.dmSans(
            fontSize: 10,
            letterSpacing: 1.5,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 40),

        Container(width: 36, height: 0.5, color: AppColors.dividerLight),
        const SizedBox(height: 40),

        // Bio resumida
        Text(
          'Pintor, bordador e desenhista da Geração 80, Leonilson criou um vocabulário visual único — palavras manuscritas costuradas à tela, figuras delicadas e símbolos íntimos que atravessam o tempo e continuam a comover.',
          style: AppTextStyles.bodyLarge.copyWith(height: 1.8),
        ),
        const SizedBox(height: 16),

        // Estatísticas rápidas
        Row(
          children: [
            _Stat(value: '35', label: 'anos de vida'),
            const SizedBox(width: 36),
            _Stat(value: '4.000+', label: 'obras catalogadas'),
            const SizedBox(width: 36),
            _Stat(value: '1984', label: 'Geração 80'),
          ],
        ),
        const SizedBox(height: 48),

        // CTAs
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _EditorialCTA(
              label: 'VER ACERVO →',
              primary: true,
              onTap: () => context.go('/acervo'),
            ),
            _EditorialCTA(
              label: 'HISTÓRIA →',
              primary: false,
              onTap: () => context.go('/historia'),
            ),
          ],
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.cormorant(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            color: AppColors.accent,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 10,
            color: AppColors.onSurfaceMuted,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _EditorialCTA extends StatefulWidget {
  final String label;
  final bool primary;
  final VoidCallback onTap;
  const _EditorialCTA({
    required this.label,
    required this.primary,
    required this.onTap,
  });

  @override
  State<_EditorialCTA> createState() => _EditorialCTAState();
}

class _EditorialCTAState extends State<_EditorialCTA> {
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: widget.primary
                ? (_hovered ? AppColors.accentLight : AppColors.accent)
                : (_hovered
                    ? AppColors.onSurface.withValues(alpha: 0.06)
                    : Colors.transparent),
            border: Border.all(
              color: widget.primary
                  ? (_hovered ? AppColors.accentLight : AppColors.accent)
                  : (_hovered ? AppColors.onSurfaceMuted : AppColors.dividerLight),
              width: 0.8,
            ),
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: widget.primary
                  ? AppColors.black
                  : (_hovered ? AppColors.onSurface : AppColors.onSurfaceMuted),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditorialImages extends StatelessWidget {
  final List<Artwork> artworks;
  const _EditorialImages({required this.artworks});

  @override
  Widget build(BuildContext context) {
    if (artworks.isEmpty) return const SizedBox.shrink();
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    // Seleciona 4 obras de posições variadas
    final picks = <Artwork>[];
    final indices = [0, 4, 8, 12];
    for (final i in indices) {
      if (i < artworks.length) picks.add(artworks[i]);
    }
    if (picks.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 3,
        crossAxisSpacing: 3,
        childAspectRatio: isWide ? 0.88 : 1.0,
      ),
      itemCount: picks.length,
      itemBuilder: (context, i) => GestureDetector(
        onTap: () =>
            context.push('/obra/${picks[i].id}?index=${indices[i]}'),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Image.asset(
            picks[i].imagePath,
            fit: BoxFit.cover,
            cacheWidth: 500,
            errorBuilder: (_, _, _) =>
                Container(color: AppColors.surfaceElevated),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── FEATURED STRIP ───────────────────────────
class _FeaturedStrip extends StatelessWidget {
  final List<Artwork> artworks;
  const _FeaturedStrip({required this.artworks});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final featured = artworks.length > 10
        ? artworks.sublist(6, 11)
        : artworks.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isWide ? 64 : 28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 20, height: 0.8, color: AppColors.accent),
                  const SizedBox(width: 10),
                  Text(
                    'DESTAQUES DO ACERVO',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.accent,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => context.go('/acervo'),
                child: Text(
                  'VER TUDO →',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    letterSpacing: 2,
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 270,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding:
                EdgeInsets.symmetric(horizontal: isWide ? 64 : 28),
            itemCount: featured.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: 2),
            itemBuilder: (context, i) {
              final art = featured[i];
              return _StripCard(artwork: art);
            },
          ),
        ),
        const SizedBox(height: 72),
      ],
    );
  }
}

class _StripCard extends StatefulWidget {
  final Artwork artwork;
  const _StripCard({required this.artwork});

  @override
  State<_StripCard> createState() => _StripCardState();
}

class _StripCardState extends State<_StripCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.push(
          '/obra/${widget.artwork.id}?index=0',
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 175,
          decoration: BoxDecoration(
            border: Border.all(
              color: _hovered ? AppColors.accent : Colors.transparent,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                widget.artwork.imagePath,
                fit: BoxFit.cover,
                cacheWidth: 400,
                errorBuilder: (_, _, _) =>
                    Container(color: AppColors.surface),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.black
                          .withValues(alpha: _hovered ? 0.92 : 0.72),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
              Positioned(
                bottom: 14,
                left: 14,
                right: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.artwork.title,
                      style: GoogleFonts.cormorant(
                        fontSize: 13,
                        color: AppColors.white,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.artwork.year,
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        color: AppColors.accent,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── DOCUMENTARY SECTION ───────────────────────────
class _DocumentarySection extends StatefulWidget {
  const _DocumentarySection();

  @override
  State<_DocumentarySection> createState() => _DocumentarySectionState();
}

class _DocumentarySectionState extends State<_DocumentarySection> {
  List<(String, String, String)> _images = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final paths = await loadDocumentaryPaths();
    if (mounted) {
      setState(() {
        _images = paths.map((p) => (p, '', '')).toList();
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return Container(
      color: AppColors.paperLight,
      padding: const EdgeInsets.only(top: 56, bottom: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: isWide ? 64 : 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 0.8,
                          color: AppColors.watercolorBlue,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'DO DOCUMENTÁRIO',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            letterSpacing: 2.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.paperInk
                                .withValues(alpha: 0.45),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Obras em alta definição',
                      style: GoogleFonts.cormorant(
                        fontSize: isWide ? 32 : 24,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 2,
                        color: AppColors.paperInk,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
                if (_loaded)
                  Text(
                    '${_images.length} imagens',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      letterSpacing: 2,
                      color: AppColors.paperInk.withValues(alpha: 0.4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          if (!_loaded)
            const SizedBox(
              height: 240,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 1,
                    color: AppColors.accent,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: isWide ? 320 : 240,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 64 : 28),
                itemCount: _images.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: 3),
                itemBuilder: (context, i) {
                  final img = _images[i];
                  return _DocumentaryCard(
                    path: img.$1,
                    title: img.$2,
                    year: img.$3,
                    isWide: isWide,
                    allImages: _images,
                    index: i,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _DocumentaryCard extends StatelessWidget {
  final String path;
  final String title;
  final String year;
  final bool isWide;
  final List<(String, String, String)> allImages;
  final int index;

  const _DocumentaryCard({
    required this.path,
    required this.title,
    required this.year,
    required this.isWide,
    required this.allImages,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDocumentaryViewer(context, allImages, index),
      child: MouseRegion(
        cursor: SystemMouseCursors.zoomIn,
        child: SizedBox(
          width: isWide ? 220.0 : 170.0,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                path,
                fit: BoxFit.cover,
                cacheWidth: 500,
                errorBuilder: (_, _, _) =>
                    Container(color: AppColors.paperMid),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0xDD1A1510),
                    ],
                    stops: [0.45, 1.0],
                  ),
                ),
              ),
              // Ícone de zoom
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.zoom_in,
                    color: AppColors.white,
                    size: 14,
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

// ─────────────────────────── FOOTER ───────────────────────────
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 64 : 28,
        vertical: 40,
      ),
      decoration: const BoxDecoration(
        border: Border(
            top: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'LEONILSON\nMuseu Digital',
            style: GoogleFonts.cormorant(
              fontSize: 13,
              color: AppColors.onSurfaceMuted,
              letterSpacing: 2,
              height: 1.6,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              const ProjectoLeonilsonLogo(height: 24),
              const SizedBox(height: 8),
              Text(
                '© Projeto Leonilson · Família Bezerra Dias',
                textAlign: TextAlign.right,
                style: GoogleFonts.dmSans(
                  fontSize: 9,
                  color: AppColors.onSurfaceDisabled,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
