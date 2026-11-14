class Artwork {
  final String id;
  final String title;
  final String year;
  final String size;
  final String info;
  final String technique;
  final String imagePath;

  const Artwork({
    required this.id,
    required this.title,
    required this.year,
    required this.size,
    required this.info,
    required this.technique,
    required this.imagePath,
  });

  factory Artwork.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] as String? ?? '';
    return Artwork(
      id: rawId,
      title: json['title'] as String? ?? '',
      year: json['year'] as String? ?? '',
      size: json['size'] as String? ?? '',
      info: json['info'] as String? ?? '',
      technique: json['tech'] as String? ?? '',
      imagePath: json['path'] as String? ?? '',
    );
  }

  int get yearInt {
    // Handles "C. 1978", "1985", "C. 1991" etc.
    final cleaned = year.replaceAll(RegExp(r'[Cc]\.\s*'), '').trim();
    return int.tryParse(cleaned) ?? 0;
  }

  String get decade {
    final y = yearInt;
    if (y < 1980) return 'Anos 70';
    if (y < 1990) return 'Anos 80';
    return 'Anos 90';
  }
}
