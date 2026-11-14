import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/acervo_repository.dart';
import '../models/artwork.dart';

class ArtworkDetailScreen extends StatefulWidget {
  final String artworkId;
  final int initialIndex;

  const ArtworkDetailScreen({
    super.key,
    required this.artworkId,
    required this.initialIndex,
  });

  @override
  State<ArtworkDetailScreen> createState() => _ArtworkDetailScreenState();
}

class _ArtworkDetailScreenState extends State<ArtworkDetailScreen> {
  List<Artwork> _artworks = [];
  int _currentIndex = 0;
  bool _loaded = false;
  bool _showInfo = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await AcervoRepository.instance.loadArtworks();
    if (mounted) {
      final artworks = AcervoRepository.instance.artworks;
      final idx = artworks.indexWhere((a) => a.id == widget.artworkId);
      setState(() {
        _artworks = artworks;
        _currentIndex = idx >= 0 ? idx : widget.initialIndex;
        _loaded = true;
      });
    }
  }

  Artwork? get _current =>
      _loaded && _artworks.isNotEmpty ? _artworks[_currentIndex] : null;

  void _prev() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  void _next() {
    if (_currentIndex < _artworks.length - 1) {
      setState(() => _currentIndex++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: AppColors.black,
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
          : isWide
              ? _WebDetail(
                  artwork: _current,
                  currentIndex: _currentIndex,
                  total: _artworks.length,
                  showInfo: _showInfo,
                  onPrev: _prev,
                  onNext: _next,
                  onToggleInfo: () =>
                      setState(() => _showInfo = !_showInfo),
                  onClose: () => context.pop(),
                )
              : _MobileDetail(
                  artwork: _current,
                  currentIndex: _currentIndex,
                  total: _artworks.length,
                  onPrev: _prev,
                  onNext: _next,
                  onClose: () => context.pop(),
                ),
    );
  }
}

// ─────────────────────────── WEB DETAIL ───────────────────────────
class _WebDetail extends StatelessWidget {
  final Artwork? artwork;
  final int currentIndex;
  final int total;
  final bool showInfo;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onToggleInfo;
  final VoidCallback onClose;

  const _WebDetail({
    required this.artwork,
    required this.currentIndex,
    required this.total,
    required this.showInfo,
    required this.onPrev,
    required this.onNext,
    required this.onToggleInfo,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (artwork == null) return const SizedBox.shrink();

    return Row(
      children: [
        // ── Image area ──
        Expanded(
          flex: showInfo ? 3 : 5,
          child: Stack(
            children: [
              // Image
              Positioned.fill(
                child: GestureDetector(
                  onTap: onToggleInfo,
                  child: InteractiveViewer(
                    child: Image.asset(
                      artwork!.imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) =>
                          Container(color: AppColors.surface),
                    ),
                  ),
                ),
              ),
              // Top bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _TopBar(
                  currentIndex: currentIndex,
                  total: total,
                  onClose: onClose,
                  showInfoToggle: true,
                  showInfo: showInfo,
                  onToggleInfo: onToggleInfo,
                ),
              ),
              // Prev / Next arrows
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _NavArrow(
                    icon: Icons.chevron_left,
                    enabled: currentIndex > 0,
                    onTap: onPrev,
                  ),
                ),
              ),
              Positioned(
                right: showInfo ? 16 : 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _NavArrow(
                    icon: Icons.chevron_right,
                    enabled: currentIndex < total - 1,
                    onTap: onNext,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Info panel ──
        if (showInfo) ...[
          const VerticalDivider(width: 0.5, color: AppColors.divider),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 340,
            color: AppColors.surface,
            child: _InfoPanel(artwork: artwork!),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────── MOBILE DETAIL ───────────────────────────
class _MobileDetail extends StatelessWidget {
  final Artwork? artwork;
  final int currentIndex;
  final int total;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onClose;

  const _MobileDetail({
    required this.artwork,
    required this.currentIndex,
    required this.total,
    required this.onPrev,
    required this.onNext,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (artwork == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Image with nav
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  child: Image.asset(
                    artwork!.imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) =>
                        Container(color: AppColors.surface),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _TopBar(
                  currentIndex: currentIndex,
                  total: total,
                  onClose: onClose,
                  showInfoToggle: false,
                  showInfo: false,
                  onToggleInfo: () {},
                ),
              ),
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _NavArrow(
                    icon: Icons.chevron_left,
                    enabled: currentIndex > 0,
                    onTap: onPrev,
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _NavArrow(
                    icon: Icons.chevron_right,
                    enabled: currentIndex < total - 1,
                    onTap: onNext,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Info panel at bottom
        Container(
          color: AppColors.surface,
          child: _InfoPanel(artwork: artwork!),
        ),
      ],
    );
  }
}

// ─────────────────────────── SHARED WIDGETS ───────────────────────────
class _TopBar extends StatelessWidget {
  final int currentIndex;
  final int total;
  final VoidCallback onClose;
  final bool showInfoToggle;
  final bool showInfo;
  final VoidCallback onToggleInfo;

  const _TopBar({
    required this.currentIndex,
    required this.total,
    required this.onClose,
    required this.showInfoToggle,
    required this.showInfo,
    required this.onToggleInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.viewPaddingOf(context).top + 8,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.black.withValues(alpha: 0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.onBackground),
            onPressed: onClose,
            splashRadius: 20,
          ),
          const Spacer(),
          Text(
            '${currentIndex + 1} / $total',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              letterSpacing: 2,
              color: AppColors.onSurfaceMuted,
            ),
          ),
          if (showInfoToggle) ...[
            const SizedBox(width: 16),
            IconButton(
              icon: Icon(
                showInfo ? Icons.info : Icons.info_outline,
                color: showInfo ? AppColors.accent : AppColors.onSurface,
              ),
              onPressed: onToggleInfo,
              splashRadius: 20,
            ),
          ],
        ],
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _NavArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.2,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.onBackground, size: 22),
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final Artwork artwork;
  const _InfoPanel({required this.artwork});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 40 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            artwork.title,
            style: AppTextStyles.headlineMedium,
          ),
          const SizedBox(height: 20),
          const Divider(height: 0.5),
          const SizedBox(height: 20),
          _MetaRow(label: 'ANO', value: artwork.year),
          _MetaRow(label: 'TÉCNICA', value: artwork.technique),
          _MetaRow(label: 'DIMENSÕES', value: artwork.size),
          _MetaRow(label: 'COLEÇÃO', value: artwork.info),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelMedium,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}
