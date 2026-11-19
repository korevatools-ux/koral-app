import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:dart_pptx/dart_pptx.dart';

/// Builds genuine Office Open XML files from saved Koral generation text.
/// This runs on-device; document content is not sent to another service.
class KoralExportService {
  const KoralExportService();

  Future<Uint8List> createWordDocument({
    required String title,
    required String content,
  }) async {
    final archive = Archive();
    _addTextFile(
      archive,
      '[Content_Types].xml',
      '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
  <Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
</Types>''',
    );
    _addTextFile(
      archive,
      '_rels/.rels',
      '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
</Relationships>''',
    );
    _addTextFile(
      archive,
      'word/_rels/document.xml.rels',
      '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
</Relationships>''',
    );
    _addTextFile(
      archive,
      'word/styles.xml',
      '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:style w:type="paragraph" w:default="1" w:styleId="Normal">
    <w:name w:val="Normal"/>
    <w:rPr><w:rFonts w:ascii="Aptos" w:hAnsi="Aptos"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Title">
    <w:name w:val="Title"/><w:basedOn w:val="Normal"/><w:qFormat/>
    <w:rPr><w:b/><w:sz w:val="40"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading1">
    <w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:qFormat/>
    <w:rPr><w:b/><w:sz w:val="32"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading2">
    <w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:qFormat/>
    <w:rPr><w:b/><w:sz w:val="28"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading3">
    <w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:qFormat/>
    <w:rPr><w:b/><w:sz w:val="24"/></w:rPr>
  </w:style>
</w:styles>''',
    );
    _addTextFile(
      archive,
      'docProps/core.xml',
      '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/">
  <dc:title>${_escapeXml(title)}</dc:title>
  <dc:creator>Koral</dc:creator>
  <cp:lastModifiedBy>Koral</cp:lastModifiedBy>
</cp:coreProperties>''',
    );

    final body = StringBuffer()
      ..write(_paragraph(title, style: 'Title'));
    for (final raw in content.split('\n')) {
      final line = raw.trimRight();
      if (line.trim().isEmpty) {
        body.write('<w:p/>');
        continue;
      }

      final trimmed = line.trimLeft();
      var text = line;
      var style = 'Normal';
      if (trimmed.startsWith('### ')) {
        style = 'Heading3';
        text = trimmed.substring(4);
      } else if (trimmed.startsWith('## ')) {
        style = 'Heading2';
        text = trimmed.substring(3);
      } else if (trimmed.startsWith('# ')) {
        style = 'Heading1';
        text = trimmed.substring(2);
      } else if (trimmed.startsWith('- ') ||
          trimmed.startsWith('* ') ||
          trimmed.startsWith('• ')) {
        text = '• ${trimmed.substring(2)}';
      }
      body.write(_paragraph(text, style: style));
    }

    _addTextFile(
      archive,
      'word/document.xml',
      '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    $body
    <w:sectPr>
      <w:pgSz w:w="12240" w:h="15840"/>
      <w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>
    </w:sectPr>
  </w:body>
</w:document>''',
    );

    final encoded = ZipEncoder().encode(archive);
    if (encoded == null || encoded.isEmpty) {
      throw StateError('Koral could not package the Word document.');
    }
    return Uint8List.fromList(encoded);
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

    final bytes = await presentation.save();
    if (bytes == null || bytes.isEmpty) {
      throw StateError('Koral could not package the PowerPoint presentation.');
    }
    return Uint8List.fromList(bytes);
  }

  void _addTextFile(Archive archive, String path, String text) {
    final bytes = utf8.encode(text);
    archive.addFile(ArchiveFile(path, bytes.length, bytes));
  }

  String _paragraph(String text, {String style = 'Normal'}) {
    final styleTag = style == 'Normal'
        ? ''
        : '<w:pPr><w:pStyle w:val="$style"/></w:pPr>';
    return '<w:p>$styleTag<w:r><w:t xml:space="preserve">${_escapeXml(text)}</w:t></w:r></w:p>';
  }

  String _escapeXml(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');

  List<_SlideDraft> _parseSlides(String outline) {
    final slides = <_SlideDraft>[];
    _SlideDraft? current;

    for (final raw in outline.split('\n')) {
      final line = raw.trim();
      if (line.isEmpty || line.toLowerCase().startsWith('notes:')) continue;

      final title = _extractSlideTitle(line);
      if (title != null) {
        current = _SlideDraft(title);
        slides.add(current);
        continue;
      }

      current ??= _SlideDraft('Key points');
      if (slides.isEmpty) slides.add(current);

      var bullet = line;
      if (bullet.startsWith('-') ||
          bullet.startsWith('*') ||
          bullet.startsWith('•')) {
        bullet = bullet.substring(1).trim();
      } else {
        final period = bullet.indexOf('.');
        if (period > 0 &&
            int.tryParse(bullet.substring(0, period).trim()) != null) {
          bullet = bullet.substring(period + 1).trim();
        }
      }
      if (bullet.isNotEmpty) current.bullets.add(bullet);
    }

    if (slides.isEmpty) {
      final lines = outline
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .take(5)
          .toList();
      slides.add(_SlideDraft('Key points')..bullets.addAll(lines));
    }

    return slides;
  }

  String? _extractSlideTitle(String line) {
    final colon = line.indexOf(':');
    if (colon < 0) return null;
    final prefix = line.substring(0, colon).trim().toLowerCase();
    if (!prefix.startsWith('slide ')) return null;
    final number = prefix.substring(6).trim();
    if (int.tryParse(number) == null) return null;
    return line.substring(colon + 1).trim();
  }
}

class _SlideDraft {
  _SlideDraft(this.title);

  final String title;
  final List<String> bullets = [];
}
