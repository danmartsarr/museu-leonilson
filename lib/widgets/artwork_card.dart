import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/artwork.dart';
import '../theme/app_theme.dart';

class ArtworkCard extends StatefulWidget {
  final Artwork artwork;
  final VoidCallback onTap;

  const ArtworkCard({
    super.key,
    required this.artwork,
    required this.onTap,
  });

  @override
  State<ArtworkCard> createState() => _ArtworkCardState();
}

class _ArtworkCardState extends State<ArtworkCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 1.0, end: 1.055).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onEnter(_) => _ctrl.forward();
  void _onExit(_) => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: _onEnter,
      onExit: _onExit,
      child: GestureDetector(
        onTap: widget.onTap,
        child: ClipRect(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  // ── Imagem que escala suavemente ──
                  Transform.scale(
                    scale: _scale.value,
                    child: Image.asset(
                      widget.artwork.imagePath,
                      fit: BoxFit.cover,
                      cacheWidth: 500,
                      errorBuilder: (_, _, _) => Container(
                        color: AppColors.surfaceElevated,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: AppColors.onSurfaceDisabled,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Overlay gradiente com info ──
                  Opacity(
                    opacity: _fade.value,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.black.withValues(alpha: 0.15),
                            AppColors.black.withValues(alpha: 0.82),
                          ],
                          stops: const [0.35, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // ── Título e ano no rodapé ──
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Opacity(
                      opacity: _fade.value,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.artwork.title,
                              style: GoogleFonts.cormorant(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.white,
                                height: 1.25,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.artwork.year,
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                letterSpacing: 1.5,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Ícone de zoom no canto superior direito ──
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Opacity(
                      opacity: _fade.value,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppColors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.open_in_full,
                          size: 11,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
