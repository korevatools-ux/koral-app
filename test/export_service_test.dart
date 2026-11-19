import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koral/data/export_service.dart';

void main() {
  const exporter = KoralExportService();

  test('creates a valid DOCX package from generated Markdown', () async {
    final bytes = await exporter.createWordDocument(
      title: 'Launch brief',
      content: '## Overview\n\nA real Koral export.\n\n- First point\n- Second point',
    );
    final package = ZipDecoder().decodeBytes(bytes);
    final documentXml = utf8.decode(
      package.files.firstWhere((file) => file.name == 'word/document.xml').content as List<int>,
    );

    expect(bytes.length, greaterThan(500));
    expect(documentXml, contains('Launch brief'));
    expect(documentXml, contains('A real Koral export.'));
    expect(documentXml, contains('First point'));
  });

  test('creates a valid PPTX package from a slide outline', () async {
    final bytes = await exporter.createPowerPoint(
      title: 'Launch plan',
      outline: 'Slide 1: The opportunity\n- Reach new customers\n- Improve retention\n\n'
          'Slide 2: Next steps\n- Validate demand\n- Ship the first release',
    );
    final package = ZipDecoder().decodeBytes(bytes);

    expect(bytes.length, greaterThan(500));
    expect(
      package.files.any((file) => file.name == 'ppt/presentation.xml'),
      isTrue,
    );
  });

  test('creates a PowerPoint when the AI output has no slide headings', () async {
    final bytes = await exporter.createPowerPoint(
      title: 'Quick outline',
      outline: 'First point\nSecond point\nThird point',
    );

    expect(bytes.length, greaterThan(500));
    expect(ZipDecoder().decodeBytes(bytes).files, isNotEmpty);
  });
}
