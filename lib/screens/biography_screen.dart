import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/watermark_image.dart';

class BiographyScreen extends StatelessWidget {
  const BiographyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: isWide ? 56 : 52)),

          _BiographyHeader(isWide: isWide),

          SliverToBoxAdapter(
            child: _FadeSection(
              delay: 0,
              child: _EditorialIntro(isWide: isWide),
            ),
          ),

          SliverToBoxAdapter(
            child: _FadeSection(
              delay: 80,
              child: _TimelineSection(isWide: isWide),
            ),
          ),

          SliverToBoxAdapter(
            child: _FadeSection(
              delay: 120,
              child: _PersonalPhotos(isWide: isWide),
            ),
          ),

          SliverToBoxAdapter(
            child: _FadeSection(
              delay: 160,
              child: _QuoteSection(isWide: isWide),
            ),
          ),

          SliverToBoxAdapter(
            child: _FadeSection(
              delay: 200,
              child: _CollectionCTA(isWide: isWide),
            ),
          ),

          const SliverToBoxAdapter(child: CopyrightBar()),
        ],
      ),
    );
  }
}

// ─────────────────────────── FADE DE ENTRADA ───────────────────────────
class _FadeSection extends StatefulWidget {
  final int delay;
  final Widget child;
  const _FadeSection({required this.delay, required this.child});

  @override
  State<_FadeSection> createState() => _FadeSectionState();
}

class _FadeSectionState extends State<_FadeSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.delay), () {
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
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ─────────────────────────── HEADER ───────────────────────────
class _BiographyHeader extends StatelessWidget {
  final bool isWide;
  const _BiographyHeader({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: isWide ? 520 : 380,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/fotos_familia/pagina_218_img_4.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              cacheWidth: 1200,
              errorBuilder: (_, _, _) => Container(color: AppColors.surface),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.62),
                    Colors.black.withValues(alpha: 0.35),
                    const Color(0xFFFAF8F5),
                  ],
                  stops: const [0.0, 0.30, 0.68, 0.88, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isWide ? 64 : 28,
                  0,
                  isWide ? 64 : 28,
                  isWide ? 48 : 36,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'HISTÓRIA',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        letterSpacing: 3,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'José Leonilson\nBezerra Dias',
                      style: GoogleFonts.cormorant(
                        fontSize: isWide ? 64 : 44,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1,
                        color: AppColors.white,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Fortaleza, 1957  ·  São Paulo, 1993',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        letterSpacing: 2,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── INTRODUÇÃO EDITORIAL ───────────────────────────
class _EditorialIntro extends StatelessWidget {
  final bool isWide;
  const _EditorialIntro({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isWide ? 64 : 28,
        56,
        isWide ? 64 : 28,
        72,
      ),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _IntroBody(isWide: isWide)),
                const SizedBox(width: 80),
                Expanded(flex: 2, child: _IntroCover(isWide: isWide)),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IntroBody(isWide: isWide),
                const SizedBox(height: 48),
                _IntroCover(isWide: isWide),
              ],
            ),
    );
  }
}

class _IntroBody extends StatelessWidget {
  final bool isWide;
  const _IntroBody({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Uma vida\nbordada em\npalavras e figuras',
          style: GoogleFonts.cormorant(
            fontSize: isWide ? 48 : 34,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
            color: const Color(0xFF1A1510),
            height: 1.15,
          ),
        ),
        const SizedBox(height: 32),
        Container(width: 40, height: 1, color: AppColors.accent),
        const SizedBox(height: 32),
        Text(
          'José Leonilson Bezerra Dias foi um dos artistas mais singulares da cena brasileira contemporânea. Pertencente à chamada Geração 80, desenvolveu uma linguagem visual única — íntima, confessional e imensamente humana.',
          style: GoogleFonts.dmSans(
            fontSize: isWide ? 16 : 14,
            height: 1.8,
            color: const Color(0xFF2A2420),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Sua obra combina palavras manuscritas, figuras simbólicas e imagens pessoais em suportes variados — telas, papel e, especialmente, tecido. O bordado, os zíperes e os elementos têxteis tornaram-se extensões naturais de seu vocabulário poético.',
          style: GoogleFonts.dmSans(
            fontSize: isWide ? 15 : 13,
            height: 1.8,
            color: const Color(0xFF4A4540),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Com uma qualidade ao mesmo tempo delicada e urgente, Leonilson criava diálogos entre texto e imagem que tocam diretamente na experiência emocional — uma voz singular que permanece viva décadas após sua morte prematura, aos 36 anos.',
          style: GoogleFonts.dmSans(
            fontSize: isWide ? 15 : 13,
            height: 1.8,
            color: const Color(0xFF4A4540),
          ),
        ),
      ],
    );
  }
}

class _IntroCover extends StatelessWidget {
  final bool isWide;
  const _IntroCover({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 0.75,
          child: Image.asset(
            'assets/fotos_familia/pagina_218_img_1.jpeg',
            fit: BoxFit.cover,
            cacheWidth: 600,
            errorBuilder: (_, _, _) => Container(color: const Color(0xFFE8DFD0)),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Família Bezerra Dias, c. 1961',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            color: const Color(0xFF8A8078),
            letterSpacing: 0.5,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        _DataLine('Fortaleza, CE  ·  1 de março de 1957'),
        _DataLine('São Paulo, SP  ·  28 de maio de 1993'),
        _DataLine('FAAP, São Paulo  ·  1977–1980'),
        _DataLine('Geração 80  ·  Neo-Expressionismo Brasileiro'),
        const SizedBox(height: 12),
        Text(
          'Obras em acervos do MAM-SP, Pinacoteca do\nEstado de São Paulo e coleções internacionais.',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            height: 1.7,
            color: const Color(0xFF8A8078),
          ),
        ),
      ],
    );
  }
}

class _DataLine extends StatelessWidget {
  final String text;
  const _DataLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 2,
            height: 2,
            margin: const EdgeInsets.only(top: 8, right: 10),
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                height: 1.6,
                color: const Color(0xFF4A4540),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── CRONOLOGIA DUAL ───────────────────────────

enum _EventType { personal, professional }

class _TimelineEntry {
  final String year;
  final String title;
  final String text;
  final List<String> images;
  final _EventType type;

  const _TimelineEntry({
    required this.year,
    required this.title,
    required this.text,
    this.images = const [],
    required this.type,
  });
}

// ─── Cores das duas linhas ───
const _kYellow = Color(0xFFCCA020); // vida pessoal
const _kPurple = Color(0xFF7C5CBF); // trajetória artística

// ─────────────────────────── CRONOLOGIA ───────────────────────────
class _TimelineSection extends StatelessWidget {
  final bool isWide;
  const _TimelineSection({required this.isWide});

  // Dados reais extraídos do catálogo oficial publicado pelo Projeto Leonilson.
  // Amarelo = vida pessoal  |  Roxo = trajetória artística (continua após 1993)
  // Regra: amarelo = família, amizades, saúde, viagens como descoberta pessoal;
  //        roxo = exposições, prêmios, publicações, instituições.
  static const _entries = [
    // ── 1957 ──────────────────────────────────────
    _TimelineEntry(
      year: '1957',
      title: 'Nascimento, 1º de março',
      text: 'José Leonilson Bezerra Dias nasce em Fortaleza, Ceará. Quarto dos cinco filhos de Theodorino Torquato Dias e Carmem Bezerra Dias. Família de comerciantes de tecidos — o material que mais tarde invadirá sua obra.',
      images: [],
      type: _EventType.personal,
    ),
    _TimelineEntry(
      year: '1957',
      title: 'Infância — primeiros interesses',
      text: 'Ainda criança, frequenta cursos livres de artes plásticas na Escola Panamericana de Arte. O interesse pela arte surge desde cedo e permeia toda a formação.',
      type: _EventType.professional,
    ),
    // ── 1961 ──────────────────────────────────────
    _TimelineEntry(
      year: '1961',
      title: 'Mudança para São Paulo',
      text: 'Após um ano em Porto Velho, a família se muda definitivamente para São Paulo. Leonilson cursará o fundamental e o ensino médio em colégios religiosos paulistanos.',
      images: [],
      type: _EventType.personal,
    ),
    // ── 1976–1977 ─────────────────────────────────
    _TimelineEntry(
      year: '1976',
      title: 'Bienal de SP e primeira viagem a Madri',
      text: 'Trabalha na 13ª Bienal de São Paulo como intérprete junto à representação espanhola. Viaja a Madri pela primeira vez — o contato com a Europa acende definitivamente sua vocação artística.',
      type: _EventType.personal,
    ),
    _TimelineEntry(
      year: '1977',
      title: 'FAAP — Nelson Leirner, Julio Plaza, Regina Silveira',
      text: 'Ingressa no curso de Licenciatura em Educação Artística da FAAP. Tem como professores Nelson Leirner, Julio Plaza e Regina Silveira. Participa da primeira exposição coletiva: Arte e pensamento ecológico, em Santos.',
      type: _EventType.professional,
    ),
    // ── 1979–1980 ─────────────────────────────────
    _TimelineEntry(
      year: '1979',
      title: 'Ateliê com Luiz Zerbini',
      text: 'Divide um ateliê na Vila Previdência com o amigo e artista Luiz Zerbini. As amizades com artistas da mesma geração formam o núcleo humano de toda a sua obra.',
      images: [],
      type: _EventType.personal,
    ),
    _TimelineEntry(
      year: '1980',
      title: 'Abandona a FAAP — primeira exposição individual',
      text: 'Abandona a FAAP e frequenta a escola Aster, onde tem aulas de aquarela com Dudi Maia Rosa. Realiza Cartas a um amigo, primeira individual, no MAM Bahia (Salvador). Participa do Panorama 80 no MAM-SP.',
      type: _EventType.professional,
    ),
    // ── 1981–1982 ─────────────────────────────────
    _TimelineEntry(
      year: '1981',
      title: 'Europa — encontros que marcam',
      text: 'Viaja por Madri, Paris, Cuenca, Frankfurt, Florença, Milão e Barcelona. Em Milão, conhece o artista Antonio Dias e o crítico Achille Bonito Oliva, mentor da Transvanguarda italiana. Vê trabalhos de Joseph Beuys pela primeira vez.',
      type: _EventType.personal,
    ),
    _TimelineEntry(
      year: '1981',
      title: 'Primeira individual internacional — Madri',
      text: 'Realiza Cartas al hombre na Galeria Casa do Brasil, Madri — sua primeira individual no exterior. Participa da exposição Giovane arte internazionale em Lecco, Itália.',
      type: _EventType.professional,
    ),
    // ── 1982–1983 ─────────────────────────────────
    _TimelineEntry(
      year: '1982',
      title: 'Casa-ateliê na Vila Mariana',
      text: 'Aluga uma casa-ateliê na rua Sud Menucci, Vila Mariana — onde vive e trabalha até 1992. O espaço compartilhado com Ciro Cozzolino e Sergio Romagnolo torna-se centro da sua vida e produção.',
      images: [],
      type: _EventType.personal,
    ),
    _TimelineEntry(
      year: '1982',
      title: 'Art Basel — Thomas Cohn e Luisa Strina',
      text: 'Representado pelo marchand Fernando Pellegrino (Bolonha) na feira Art Basel. Conhece Thomas Cohn (RJ) e Luisa Strina (SP), que adquirem trabalhos e se tornam seus principais galeristas.',
      type: _EventType.professional,
    ),
    _TimelineEntry(
      year: '1983',
      title: 'Individuais simultâneas — SP e RJ',
      text: 'Realiza individuais simultâneas na Galeria Luisa Strina (SP) e na Thomas Cohn Arte Contemporânea (RJ). Expõe também na Galeria Tina Presser (Porto Alegre). Recebe o Prêmio Referência Especial no VII Salão Nacional de Artes Plásticas, MAM-RJ.',
      type: _EventType.professional,
    ),
    // ── 1984–1985 ─────────────────────────────────
    _TimelineEntry(
      year: '1984',
      title: 'Como vai você, Geração 80?',
      text: 'Participa da histórica exposição na Escola de Artes Visuais do Parque Lage, Rio de Janeiro — marco do retorno à pintura no Brasil. A convite da Prefeitura de Fortaleza, cria a obra pública Torre na praia.',
      type: _EventType.professional,
    ),
    _TimelineEntry(
      year: '1985',
      title: 'Novas amizades — Daniel Senise e Albert Hien',
      text: 'Conhece Daniel Senise no circuito das exposições brasileiras. Encontra o artista alemão Albert Hien, que se torna amigo próximo e o apresenta ao marchand holandês Jack Visser. As relações pessoais alimentam e expandem sua obra.',
      images: [],
      type: _EventType.personal,
    ),
    _TimelineEntry(
      year: '1985',
      title: '18ª Bienal de SP — Paris — Buenos Aires',
      text: 'Participa da 18ª Bienal Internacional de São Paulo com obras tridimensionais. Vai a Paris para a XIII Nouvelle Biennale e a Buenos Aires para Nueva pintura brasileña.',
      type: _EventType.professional,
    ),
    // ── 1987–1988 ─────────────────────────────────
    _TimelineEntry(
      year: '1987',
      title: 'Nova York — Munique',
      text: 'Visita Nova York pela primeira vez, onde descobre a exposição Shaker Design — marca profunda em seu vocabulário formal. Residência artística na Villa Waldberta, Munique.',
      images: [],
      type: _EventType.personal,
    ),
    _TimelineEntry(
      year: '1988',
      title: '"O inconformado" — gravura para a Revolução Francesa',
      text: 'Exposição individual O inconformado na Thomas Cohn Arte Contemporânea. O Ministério da Cultura da França encomenda uma gravura comemorativa dos 200 anos da Revolução Francesa. Realiza o álbum Estigmas Curiositas Exvagus em Paris.',
      type: _EventType.professional,
    ),
    // ── 1990–1991 ─────────────────────────────────
    _TimelineEntry(
      year: '1990',
      title: 'Projeto Ulisses — reflexão autobiográfica',
      text: 'Compra um gravador e começa a gravar fitas com ideias para Frescoe Ulisses, um livro autobiográfico. O projeto revela a crescente consciência do próprio percurso — o tempo, a memória e o corpo como suporte.',
      type: _EventType.personal,
    ),
    _TimelineEntry(
      year: '1990',
      title: 'Prêmio Aquisição — primeira obra em museu',
      text: 'Recebe o Prêmio Aquisição no Prêmio Brasília de Artes Plásticas por To my Boat — Where is the Ocean? (1990) — primeira obra sua a ingressar no acervo de um museu brasileiro. Exposições na Pulitzer Art Gallery (Amsterdam) e no CCSP (SP).',
      type: _EventType.professional,
    ),
    // ── 1991–1992 ─────────────────────────────────
    _TimelineEntry(
      year: '1991',
      title: 'Diagnóstico soropositivo',
      text: 'Em agosto, um teste revela que é soropositivo ao vírus HIV. Começa a praticar ioga e shiatsu. De março de 1991 a maio de 1993, ilustra coluna semanal da jornalista Barbara Gancia na Folha de S. Paulo.',
      type: _EventType.personal,
    ),
    _TimelineEntry(
      year: '1992',
      title: 'Pneumonia — nova morada',
      text: 'Contrai pneumonia e faz transfusões de sangue. Em julho, instala-se na casa dos amigos Eduardo Brandão e Jan Fjeld. Transfere o ateliê para Pinheiros. Neste mesmo ano, cura a exposição Um olhar sobre o figurativo na Casa Triângulo.',
      type: _EventType.personal,
    ),
    // ── 1993 ──────────────────────────────────────
    _TimelineEntry(
      year: '1993',
      title: 'Últimas exposições',
      text: 'Em março, realiza duas exposições simultâneas na Galeria São Paulo e na Thomas Cohn. Participa de Cartographies: 14 Artists from Latin America, na Winnipeg Art Gallery — mostra que itinera por dois anos. Cria Instalação sobre duas figuras para a Capela do Morumbi, mas não chega a vê-la montada.',
      type: _EventType.professional,
    ),
    _TimelineEntry(
      year: '1993',
      title: 'Falecimento, 28 de maio',
      text: 'Muda-se para a casa de sua irmã Tilda em Alphaville. Após novas internações, falece em 28 de maio na casa dos pais. Deixa mais de 4.000 obras catalogadas. Em setembro, familiares e amigos fundam o Projeto Leonilson.',
      images: [],
      type: _EventType.personal,
    ),
    // ── Trajetória póstuma — linha roxa continua ──
    _TimelineEntry(
      year: '1995',
      title: '"São tantas as verdades" — MAM-SP',
      text: 'O Museu de Arte Moderna de São Paulo apresenta a primeira grande retrospectiva póstuma, consolidando definitivamente o lugar de Leonilson na arte brasileira contemporânea.',
      type: _EventType.professional,
    ),
    _TimelineEntry(
      year: '2002',
      title: '"Agora é sempre"',
      text: 'Publicação monográfica e exposição itinerante apresentam sua obra a novas gerações, com textos críticos e depoimentos de artistas.',
      type: _EventType.professional,
    ),
    _TimelineEntry(
      year: '2011',
      title: '"Puro, Inquieto, Não"',
      text: 'Retrospectiva exibida no CGAC (Santiago de Compostela) e no MAM-SP leva sua obra ao público europeu de forma abrangente pela primeira vez.',
      type: _EventType.professional,
    ),
    _TimelineEntry(
      year: '2024',
      title: 'Legado em expansão',
      text: 'Obras circulam em exposições institucionais e feiras internacionais, integrando acervos de museus no Brasil e no exterior.',
      type: _EventType.professional,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final lastPersonalIdx =
        _entries.lastIndexWhere((e) => e.type == _EventType.personal);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 64 : 28,
        vertical: 72,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CRONOLOGIA',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.accent,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Linha do tempo',
            style: GoogleFonts.cormorant(
              fontSize: isWide ? 40 : 28,
              fontWeight: FontWeight.w300,
              letterSpacing: 1,
              color: const Color(0xFF1A1510),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _Legend(color: _kYellow, label: 'Vida pessoal'),
              const SizedBox(width: 24),
              _Legend(color: _kPurple, label: 'Trajetória artística'),
            ],
          ),
          const SizedBox(height: 48),
          ...List.generate(_entries.length, (i) {
            final yearInt = int.tryParse(_entries[i].year) ?? 0;
            return _TimelineItem(
              entry: _entries[i],
              isLast: i == _entries.length - 1,
              isLastPersonal: i == lastPersonalIdx,
              isYellowAlive: yearInt <= 1993,
              isWide: isWide,
            );
          }),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 2,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 11,
            color: Colors.black.withValues(alpha: 0.45),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final _TimelineEntry entry;
  final bool isLast;
  final bool isLastPersonal;
  final bool isYellowAlive;
  final bool isWide;

  const _TimelineItem({
    required this.entry,
    required this.isLast,
    required this.isLastPersonal,
    required this.isYellowAlive,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    if (!isWide) return _NarrowItem(entry: entry, isLast: isLast);

    final isPersonal = entry.type == _EventType.personal;

    final content = Column(
      crossAxisAlignment:
          isPersonal ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _EntryText(entry: entry, alignRight: isPersonal),
        if (entry.images.isNotEmpty) ...[
          const SizedBox(height: 16),
          _ImageCluster(paths: entry.images),
        ],
      ],
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Esquerda — vida pessoal (amarelo)
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(right: 24, bottom: 64),
              child: isPersonal
                  ? Align(alignment: Alignment.topRight, child: content)
                  : const SizedBox.shrink(),
            ),
          ),

          // Centro — as duas linhas paralelas
          _DualLine(
            type: entry.type,
            isLast: isLast,
            isLastPersonal: isLastPersonal,
            isYellowAlive: isYellowAlive,
          ),

          // Direita — trajetória artística (roxo)
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 64),
              child: !isPersonal ? content : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── LINHAS DA TIMELINE ───────────────────────────
// Abordagem: duas Column paralelas lado a lado (mesmo padrão do original _DotLine),
// uma para cada cor. Confiável com IntrinsicHeight.

class _DualLine extends StatelessWidget {
  final _EventType type;
  final bool isLast;
  final bool isLastPersonal;
  final bool isYellowAlive;

  const _DualLine({
    required this.type,
    required this.isLast,
    required this.isLastPersonal,
    required this.isYellowAlive,
  });

  @override
  Widget build(BuildContext context) {
    final isPersonal = type == _EventType.personal;
    return SizedBox(
      width: 52,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Linha amarela (vida pessoal) ──
          Expanded(
            child: isYellowAlive
                ? _StrokeLine(
                    color: _kYellow,
                    isActive: isPersonal,
                    hasDot: isPersonal,
                    fadeOut: isLastPersonal,
                    continueAfter: false,
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: 4),
          // ── Linha roxa (trajetória artística) ──
          Expanded(
            child: _StrokeLine(
              color: _kPurple,
              isActive: !isPersonal,
              hasDot: !isPersonal,
              fadeOut: false,
              continueAfter: isLast,
            ),
          ),
        ],
      ),
    );
  }
}

// Uma linha vertical simples com ponto no topo.
// Baseado no padrão Column[dot + Expanded(line)] — comprovadamente funcional.
class _StrokeLine extends StatelessWidget {
  final Color color;
  final bool isActive;  // linha principal do evento atual
  final bool hasDot;    // mostrar ponto nesta linha
  final bool fadeOut;   // desvanecer ao final (linha amarela em 1993)
  final bool continueAfter; // seta de continuidade (última entrada roxa)

  const _StrokeLine({
    required this.color,
    required this.isActive,
    required this.hasDot,
    required this.fadeOut,
    required this.continueAfter,
  });

  @override
  Widget build(BuildContext context) {
    final lineWidth = isActive ? 2.5 : 1.2;
    final lineOpacity = isActive ? 0.85 : 0.20;
    final dotSize = hasDot ? 10.0 : 5.0;
    final dotOpacity = hasDot ? 1.0 : 0.20;

    return Column(
      children: [
        const SizedBox(height: 6),
        // Ponto
        Center(
          child: Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: hasDot ? Colors.white : Colors.transparent,
              border: Border.all(
                color: color.withValues(alpha: dotOpacity),
                width: hasDot ? 2.0 : 1.2,
              ),
            ),
            child: hasDot
                ? Center(
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 4),
        // Linha vertical até o próximo evento
        Expanded(
          child: Center(
            child: fadeOut
                ? ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        color.withValues(alpha: lineOpacity),
                        color.withValues(alpha: 0),
                      ],
                    ).createShader(bounds),
                    child: Container(
                      width: lineWidth,
                      color: Colors.white,
                    ),
                  )
                : Container(
                    width: lineWidth,
                    color: color.withValues(alpha: lineOpacity),
                  ),
          ),
        ),
        // Seta indicando continuidade (última entrada roxo)
        if (continueAfter) ...[
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 14,
            color: color.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _EntryText extends StatelessWidget {
  final _TimelineEntry entry;
  final bool alignRight;
  const _EntryText({required this.entry, this.alignRight = false});

  @override
  Widget build(BuildContext context) {
    final cross = alignRight
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final yearColor = entry.type == _EventType.personal ? _kYellow : _kPurple;

    return Column(
      crossAxisAlignment: cross,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          entry.year,
          style: GoogleFonts.cormorant(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: yearColor,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          entry.title,
          style: GoogleFonts.cormorant(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1A1510),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          entry.text,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            height: 1.7,
            color: const Color(0xFF4A4540),
          ),
        ),
      ],
    );
  }
}

class _ImageCluster extends StatelessWidget {
  final List<String> paths;
  const _ImageCluster({required this.paths});

  @override
  Widget build(BuildContext context) {
    if (paths.isEmpty) return const SizedBox.shrink();

    // Fade de entrada para o cluster inteiro
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < paths.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            _ZoomableImage(
              key: ValueKey(paths[i]),
              path: paths[i],
              rotation: i == 0 ? -1.8 : 2.0,
            ),
          ],
        ],
      ),
    );
  }
}

class _ZoomableImage extends StatefulWidget {
  final String path;
  final double rotation;
  final double width;
  final double? height;
  const _ZoomableImage({
    super.key,
    required this.path,
    required this.rotation,
    this.width = 130,
    this.height,
  });

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _lift;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _lift = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _open(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.88),
      builder: (_) => _BiographyZoomDialog(path: widget.path),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.zoomIn,
      onEnter: (_) => _ctrl.forward(),
      onExit: (_) => _ctrl.reverse(),
      child: GestureDetector(
        onTap: () => _open(context),
        child: AnimatedBuilder(
          animation: _lift,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, -6 * _lift.value),
            child: Transform.rotate(
              angle: widget.rotation * 3.14159 / 180,
              child: child,
            ),
          ),
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: widget.height != null
                    ? MainAxisSize.max
                    : MainAxisSize.min,
                children: [
                  const SizedBox(height: 5),
                  if (widget.height != null)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Image.asset(
                          widget.path,
                          fit: BoxFit.cover,
                          cacheWidth: 400,
                          errorBuilder: (_, _, _) => Container(
                            color: const Color(0xFFEEEBE4),
                          ),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Image.asset(
                        widget.path,
                        fit: BoxFit.contain,
                        cacheWidth: 400,
                        errorBuilder: (_, _, _) => Container(
                          width: 120,
                          height: 110,
                          color: const Color(0xFFEEEBE4),
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BiographyZoomDialog extends StatelessWidget {
  final String path;
  const _BiographyZoomDialog({required this.path});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 6.0,
            child: Image.asset(
              path,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Container(
                width: 300,
                height: 300,
                color: AppColors.surface,
              ),
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Mobile timeline (simples, sem alternância) ──
class _NarrowItem extends StatelessWidget {
  final _TimelineEntry entry;
  final bool isLast;
  const _NarrowItem({required this.entry, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Text(
              entry.year,
              style: GoogleFonts.cormorant(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: entry.type == _EventType.personal
                      ? _kYellow
                      : _kPurple,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(child: Container(width: 0.5, color: const Color(0xFFD0C8BE))),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: GoogleFonts.cormorant(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1A1510),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    entry.text,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      height: 1.7,
                      color: const Color(0xFF4A4540),
                    ),
                  ),
                  if (entry.images.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 108,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.hardEdge,
                        itemCount: entry.images.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, i) => _ZoomableImage(
                          key: ValueKey('${entry.year}_$i'),
                          path: entry.images[i],
                          rotation: i == 0 ? -1.5 : 1.5,
                          width: 88,
                          height: 108,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── ARQUIVO PESSOAL ───────────────────────────
class _PersonalPhotos extends StatelessWidget {
  final bool isWide;
  const _PersonalPhotos({required this.isWide});

  static const _photos = [
    ('assets/fotos_familia/pagina_218_img_2.jpeg', 'Leonilson na infância'),
    ('assets/fotos_familia/pagina_218_img_3.jpeg', 'Leonilson, c. 1964'),
    ('assets/fotos_familia/pagina_219_img_1.jpeg', 'Acervo pessoal'),
    ('assets/fotos_familia/pagina_219_img_2.jpeg', 'Acervo pessoal'),
    ('assets/fotos_familia/pagina_218_img_4.jpeg', 'Leonilson, 1989\nFoto: Mila Petrillo'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.paperLight,
      padding: EdgeInsets.fromLTRB(
        isWide ? 64 : 28,
        64,
        isWide ? 64 : 28,
        72,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('IMAGENS', style: AppTextStyles.labelOnPaper),
          const SizedBox(height: 12),
          Text(
            'Arquivo pessoal',
            style: GoogleFonts.cormorant(
              fontSize: isWide ? 40 : 28,
              fontWeight: FontWeight.w400,
              letterSpacing: 2,
              color: AppColors.paperInk,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 36),
          if (isWide)
            _WidePhotoLayout(photos: _photos)
          else
            _NarrowPhotoLayout(photos: _photos),
        ],
      ),
    );
  }
}

class _WidePhotoLayout extends StatelessWidget {
  final List<(String, String)> photos;
  const _WidePhotoLayout({required this.photos});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 0.82,
                child: Image.asset(
                  photos[0].$1,
                  fit: BoxFit.cover,
                  cacheWidth: 800,
                  errorBuilder: (_, _, _) => Container(color: AppColors.paperMid),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                photos[0].$2,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: AppColors.paperInk.withValues(alpha: 0.6),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          flex: 3,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 0.9,
            ),
            itemCount: photos.length - 1,
            itemBuilder: (context, i) {
              final photo = photos[i + 1];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Image.asset(
                      photo.$1,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      cacheWidth: 500,
                      errorBuilder: (_, _, _) => Container(color: AppColors.paperMid),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    photo.$2,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      color: AppColors.paperInk.withValues(alpha: 0.6),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NarrowPhotoLayout extends StatelessWidget {
  final List<(String, String)> photos;
  const _NarrowPhotoLayout({required this.photos});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 0.85,
      ),
      itemCount: photos.length,
      itemBuilder: (context, i) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              photos[i].$1,
              fit: BoxFit.cover,
              cacheWidth: 500,
              errorBuilder: (_, _, _) => Container(color: AppColors.paperMid),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                color: AppColors.paperInk.withValues(alpha: 0.6),
                child: Text(
                  photos[i].$2,
                  style: GoogleFonts.dmSans(
                    fontSize: 9,
                    color: AppColors.white,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────── CITAÇÃO ───────────────────────────
class _QuoteSection extends StatelessWidget {
  final bool isWide;
  const _QuoteSection({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 120 : 40,
        vertical: isWide ? 80 : 56,
      ),
      child: Column(
        children: [
          Container(width: 1, height: 56, color: const Color(0xFFD0C8BE)),
          const SizedBox(height: 40),
          Text(
            '"Morro pela boca\nvivo pelos olhos"',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorant(
              fontSize: isWide ? 40 : 28,
              fontWeight: FontWeight.w300,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF1A1510),
              height: 1.4,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            '— José Leonilson',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 3,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 40),
          Container(width: 1, height: 56, color: const Color(0xFFD0C8BE)),
        ],
      ),
    );
  }
}

// ─────────────────────────── CTA ───────────────────────────
class _CollectionCTA extends StatelessWidget {
  final bool isWide;
  const _CollectionCTA({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEDE8DF),
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 64 : 28,
        vertical: 72,
      ),
      child: isWide
          ? Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ACERVO DIGITAL',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.accent,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Explore as obras',
                        style: GoogleFonts.cormorant(
                          fontSize: 40,
                          fontWeight: FontWeight.w300,
                          color: const Color(0xFF1A1510),
                        ),
                      ),
                    ],
                  ),
                ),
                _CTAButton(onTap: () => context.go('/acervo')),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACERVO DIGITAL',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.accent,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Explore as obras',
                  style: GoogleFonts.cormorant(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    color: const Color(0xFF1A1510),
                  ),
                ),
                const SizedBox(height: 28),
                _CTAButton(onTap: () => context.go('/acervo')),
              ],
            ),
    );
  }
}

class _CTAButton extends StatefulWidget {
  final VoidCallback onTap;
  const _CTAButton({required this.onTap});

  @override
  State<_CTAButton> createState() => _CTAButtonState();
}

class _CTAButtonState extends State<_CTAButton> {
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
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.accentLight : AppColors.accent,
            border: Border.all(
              color: _hovered ? AppColors.accentLight : AppColors.accent,
            ),
          ),
          child: Text(
            'VER ACERVO →',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.5,
              color: AppColors.black,
            ),
          ),
        ),
      ),
    );
  }
}
