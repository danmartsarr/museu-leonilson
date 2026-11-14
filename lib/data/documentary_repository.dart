import 'package:flutter/services.dart';

/// Carrega imagens dos anos 80 para o canvas.
Future<List<String>> loadDocumentaryPaths() async {
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  final paths = manifest
      .listAssets()
      .where((k) => k.startsWith('assets/imagens_obras/DEC.80/'))
      .toList()
    ..sort();
  return paths;
}
