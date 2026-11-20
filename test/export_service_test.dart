import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koral/data/export_service.dart';

void main() {
  const exporter = KoralExportService();

  test('creates a complete DOCX package and preserves document text', () async {
    final bytes = await exporter.createWordDocument(
      title: 'Launch & growth',
      content: '## Overview\n\nA real Koral export.\n\n- First point\n- Second <point>',
    );
    final package = ZipDecoder().decodeBytes(bytes);
    final files = package.files.map((file) => file.name).toSet();
    final documentXml = utf8.decode(
      package.files
          .firstWhere((file) => file.name == 'word/document.xml')
          .content as List<int>,
    );

    expect(bytes.length, greaterThan(500));
    expect(files, containsAll([
      '[Content_Types].xml',
      '_rels/.rels',
      'word/document.xml',
      'word/styles.xml',
      'word/_rels/document.xml.rels',
      'docProps/core.xml',
    ]));
    expect(documentXml, contains('Launch &amp; growth'));
    expect(documentXml, contains('A real Koral export.'));
    expect(documentXml, contains('First point'));
    expect(documentXml, contains('Second &lt;point&gt;'));
  });

  test('creates a PowerPoint package containing the requested slides', () async {
    final bytes = await exporter.createPowerPoint(
      title: 'Launch plan',
      outline: 'Slide 1: The opportunity\n- Reach new customers\n- Improve retention\n\n'
          'Slide 2: Next steps\n- Validate demand\n- Ship the first release',
    );
    final package = ZipDecoder().decodeBytes(bytes);
    final names = package.files.map((file) => file.name).toList();
    final slideFiles = package.files
        .where((file) => RegExp(r'^ppt/slides/slide\\d+\\.xml$').hasMatch(file.name))
        .toList();
    final slideXml = slideFiles
        .map((file) => utf8.decode(file.content as List<int>))
        .join('\n');

    expect(bytes.length, greaterThan(500));
    expect(names, contains('ppt/presentation.xml'));
    expect(slideFiles.length, greaterThanOrEqualTo(3));
    expect(slideXml, contains('The opportunity'));
    expect(slideXml, contains('Reach new customers'));
    expect(slideXml, contains('Next steps'));
    expect(slideXml, contains('Ship the first release'));
  });

  test('creates a PowerPoint when the AI output has no slide headings', () async {
    final bytes = await exporter.createPowerPoint(
      title: 'Quick outline',
      outline: 'First point\nSecond point\nThird point',
    );
    final package = ZipDecoder().decodeBytes(bytes);
    final slideFiles = package.files
        .where((file) => RegExp(r'^ppt/slides/slide\\d+\\.xml$').hasMatch(file.name))
        .toList();

    expect(bytes.length, greaterThan(500));
    expect(slideFiles, isNotEmpty);
    expect(
      slideFiles.map((file) => utf8.decode(file.content as List<int>)).join(),
      contains('First point'),
    );
  });
}
