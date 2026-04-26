import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:syncfusion_flutter_pdf/pdf.dart' as sfpdf;

enum PdfTextExtractionRoute {
  native,
  ocr,
}

class PdfTextExtractionResult {
  final String text;
  final PdfTextExtractionRoute route;
  final double qualityScore;
  final double nativeScore;
  final double? ocrScore;

  const PdfTextExtractionResult({
    required this.text,
    required this.route,
    required this.qualityScore,
    required this.nativeScore,
    required this.ocrScore,
  });
}

class PdfTextExtractorService {
  static const double _minQualityForNative = 0.22;
  static const int _minUsefulChars = 180;

  const PdfTextExtractorService();

  Future<PdfTextExtractionResult> extract(Uint8List bytes) async {
    final nativeText = _extractNative(bytes);
    final nativeScore = _quality(nativeText);

    if (nativeScore >= _minQualityForNative &&
        nativeText.trim().length >= _minUsefulChars) {
      return PdfTextExtractionResult(
        text: nativeText,
        route: PdfTextExtractionRoute.native,
        qualityScore: nativeScore,
        nativeScore: nativeScore,
        ocrScore: null,
      );
    }

    if (!_canRunOcr()) {
      if (nativeText.trim().isEmpty) {
        throw const PdfTextExtractionException(
          'Texto nativo insuficiente e OCR indisponível nesta plataforma',
        );
      }
      return PdfTextExtractionResult(
        text: nativeText,
        route: PdfTextExtractionRoute.native,
        qualityScore: nativeScore,
        nativeScore: nativeScore,
        ocrScore: null,
      );
    }

    final ocrText = await _extractWithOcr(bytes);
    final ocrScore = _quality(ocrText);

    final chooseOcr =
        ocrScore > nativeScore && ocrText.trim().length >= _minUsefulChars;
    final chosenText = chooseOcr ? ocrText : nativeText;
    final chosenRoute =
        chooseOcr ? PdfTextExtractionRoute.ocr : PdfTextExtractionRoute.native;
    final chosenScore = chooseOcr ? ocrScore : nativeScore;

    if (chosenText.trim().isEmpty) {
      throw const PdfTextExtractionException(
        'Falha ao extrair texto utilizável do PDF',
      );
    }

    return PdfTextExtractionResult(
      text: chosenText,
      route: chosenRoute,
      qualityScore: chosenScore,
      nativeScore: nativeScore,
      ocrScore: ocrScore,
    );
  }

  String _extractNative(Uint8List bytes) {
    final document = sfpdf.PdfDocument(inputBytes: bytes);
    try {
      return sfpdf.PdfTextExtractor(document).extractText();
    } finally {
      document.dispose();
    }
  }

  Future<String> _extractWithOcr(Uint8List bytes) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final tempFiles = <File>[];

    try {
      final doc = await pdfx.PdfDocument.openData(bytes);
      final tempDir = await getTemporaryDirectory();
      final out = StringBuffer();

      for (var pageNumber = 1; pageNumber <= doc.pagesCount; pageNumber++) {
        final page = await doc.getPage(pageNumber);
        final render = await page.render(
          width: (page.width * 2).toDouble(),
          height: (page.height * 2).toDouble(),
          format: pdfx.PdfPageImageFormat.png,
        );
        await page.close();

        final bytesPng = render?.bytes;
        if (bytesPng == null || bytesPng.isEmpty) {
          continue;
        }

        final path = '${tempDir.path}/ocr_page_$pageNumber.png';
        final file = File(path);
        await file.writeAsBytes(bytesPng, flush: true);
        tempFiles.add(file);

        final inputImage = InputImage.fromFilePath(path);
        final recognized = await recognizer.processImage(inputImage);
        if (recognized.text.trim().isNotEmpty) {
          out.writeln(recognized.text.trim());
          out.writeln();
        }
      }

      await doc.close();
      return out.toString();
    } finally {
      await recognizer.close();
      for (final file in tempFiles) {
        if (file.existsSync()) {
          await file.delete();
        }
      }
    }
  }

  bool _canRunOcr() {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  double _quality(String text) {
    final clean = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (clean.isEmpty) return 0;

    final alphaNum = RegExp(r'[A-Za-z0-9À-ÿ]').allMatches(clean).length;
    final ratio = clean.isEmpty ? 0 : alphaNum / clean.length;

    final keywordHits = <RegExp>[
      RegExp(r'relat[oó]rio', caseSensitive: false),
      RegExp(r'amostra', caseSensitive: false),
      RegExp(r'talh[aã]o', caseSensitive: false),
      RegExp(r'ph', caseSensitive: false),
      RegExp(r'argila', caseSensitive: false),
    ].where((regex) => regex.hasMatch(clean)).length;

    final lenScore = (clean.length / 3000).clamp(0.0, 1.0);
    final keywordScore = (keywordHits / 5).clamp(0.0, 1.0);
    return ((ratio * 0.35) + (lenScore * 0.45) + (keywordScore * 0.2))
        .clamp(0.0, 1.0);
  }
}

class PdfTextExtractionException implements Exception {
  final String message;

  const PdfTextExtractionException(this.message);

  @override
  String toString() => message;
}
