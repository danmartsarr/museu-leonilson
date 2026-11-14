import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/artwork.dart';

class AcervoRepository {
  static AcervoRepository? _instance;
  List<Artwork>? _artworks;

  AcervoRepository._();

  static AcervoRepository get instance {
    _instance ??= AcervoRepository._();
    return _instance!;
  }

  Future<List<Artwork>> loadArtworks() async {
    if (_artworks != null) return _artworks!;

    final jsonString = await rootBundle.loadString('assets/acervo.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    _artworks = jsonList
        .map((e) => Artwork.fromJson(e as Map<String, dynamic>))
        .toList();
    return _artworks!;
  }

  List<Artwork> get artworks => _artworks ?? [];

  List<String> get decades {
    final d = artworks.map((a) => a.decade).toSet().toList()..sort();
    return d;
  }

  List<String> get techniques {
    final all = artworks.map((a) => a.technique).toSet().toList()..sort();
    return all;
  }

  List<Artwork> filter({String? decade, String? searchQuery}) {
    var list = artworks;

    if (decade != null && decade != 'Todas') {
      list = list.where((a) => a.decade == decade).toList();
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      list = list
          .where((a) =>
              a.title.toLowerCase().contains(q) ||
              a.technique.toLowerCase().contains(q) ||
              a.year.contains(q))
          .toList();
    }

    return list;
  }
}
