import 'dart:typed_data';

import 'package:dart_pptx/dart_pptx.dart';
import 'package:docx_creator/docx_creator.dart';

/// Builds genuine Office Open XML files from saved Koral generation text.
/// This runs on-device; document content is not sent to another service.
class KoralExportService {
  const KoralExportService();

  Future<Uint8List> createWordDocument({
    required String title,
    required String content,
  }) async {
    final markdown = '# $title\n\n${content.trim()}';
    final elements = await MarkdownParser.parse(markdown);
    final document = DocxBuiltDocument(elements: elements);
    final bytes = DocxExporter().exportToBytes(document);
    return Uint8List.fromList(bytes);
  }

  Future<Uint8List> createPowerPoint({
    required String title,
    required String outline,
  }) async {
    final presentation = Powerpoint()
      ..title = title
      ..author = 'Koral'
      ..showSlideNumbers = true
      ..layout = Layout.screenWide();

    presentation.addTitleSlide(
      title: title.toTextValue(),
      author: 'Koral'.toTextValue(),
    );

    final slides = _parseSlides(outline);
    for (final slide in slides) {
      final bullets = slide.bullets.isEmpty
          ? <String>[slide.title]
          : slide.bullets.take(5).toList();
      presentation.addTitleAndBulletsSlide(
        title: slide.title.toTextValue(),
        bullets: bullets.map((line) => line.toTextValue()).toList(),
      );
    }

    return Uint8List.fromList(await presentation.save());
  }

  List<_SlideDraft> _parseSlides(String outline) {
    final header = RegExp(
      r'^\s*Slide\s+\d+\s*:\s*(.+)$',
      caseSensitive: false,
    );
    final slides = <_SlideDraft>[];
    _SlideDraft? current;

    for (final raw in outline.split(RegExp(r'\r?\n'))) {
      final line = raw.trim();
      if (line.isEmpty || line.toLowerCase().startsWith('notes:')) continue;

      final match = header.firstMatch(line);
      if (match != null) {
        current = _SlideDraft(match.group(1)!.trim());
        slides.add(current);
        continue;
      }

      current ??= _SlideDraft('Key points');
      if (slides.isEmpty) slides.add(current);

      final bullet = line.replaceFirst(RegExp(r'^(?:[-*•]|\d+[.)])\s*'), '');
      if (bullet.isNotEmpty) current.bullets.add(bullet);
    }

    if (slides.isEmpty) {
      final lines = outline
          .split(RegExp(r'\r?\n'))
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .take(5)
          .toList();
      slides.add(_SlideDraft('Key points')..bullets.addAll(lines));
    }

    return slides;
  }
}

class _SlideDraft {
  _SlideDraft(this.title);

  final String title;
  final List<String> bullets = [];
}
