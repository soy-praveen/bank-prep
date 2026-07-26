/// Lightweight markdown renderer for BankPrep's constrained content:
/// headings, pipe tables (horizontally scrollable), lists, blockquotes,
/// **bold**, *italic*, `code`, horizontal rules, preserved line breaks.
library;

import 'package:flutter/material.dart';
import 'theme.dart';

class MdText extends StatelessWidget {
  final String data;
  final TextStyle? baseStyle;
  final double blockGap;

  const MdText(this.data, {super.key, this.baseStyle, this.blockGap = 10});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final base = baseStyle ?? Theme.of(context).textTheme.bodyLarge!;
    final blocks = _parseBlocks(data);
    final children = <Widget>[];

    for (var i = 0; i < blocks.length; i++) {
      final b = blocks[i];
      if (i > 0) children.add(SizedBox(height: blockGap));
      children.add(_renderBlock(context, b, base, c));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  Widget _renderBlock(BuildContext context, _Block b, TextStyle base, AppColors c) {
    switch (b.type) {
      case _BlockType.h1:
      case _BlockType.h2:
      case _BlockType.h3:
        final style = switch (b.type) {
          _BlockType.h1 => grotesk(700, size: 22, color: c.ink, height: 1.2),
          _BlockType.h2 => grotesk(650, size: 18.5, color: c.ink, height: 1.2),
          _ => inter(650, size: 16, color: c.ink, height: 1.25),
        };
        return Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text.rich(_inline(b.text, style, c), style: style),
        );
      case _BlockType.rule:
        return Divider(color: c.line);
      case _BlockType.quote:
        return Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          decoration: BoxDecoration(
            color: c.raised,
            borderRadius: BorderRadius.circular(10),
            border: Border(left: BorderSide(color: c.accent, width: 3)),
          ),
          child: Text.rich(_inline(b.text, base, c), style: base),
        );
      case _BlockType.ul:
      case _BlockType.ol:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < b.items.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 22,
                      child: Text(
                        b.type == _BlockType.ol ? '${i + 1}.' : '•',
                        style: base.copyWith(color: c.accent),
                      ),
                    ),
                    Expanded(
                        child: Text.rich(_inline(b.items[i], base, c),
                            style: base)),
                  ],
                ),
              ),
          ],
        );
      case _BlockType.table:
        return _MdTable(rows: b.rows, base: base);
      case _BlockType.para:
        return Text.rich(_inline(b.text, base, c), style: base);
    }
  }
}

class _MdTable extends StatelessWidget {
  final List<List<String>> rows;
  final TextStyle base;
  const _MdTable({required this.rows, required this.base});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final cellStyle = base.copyWith(fontSize: (base.fontSize ?? 15) - 1);
    final headStyle = inter(650, size: (base.fontSize ?? 15) - 1.5, color: c.ink);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: c.line),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            border: TableBorder(
              horizontalInside: BorderSide(color: c.line),
              verticalInside: BorderSide(color: c.line),
            ),
            children: [
              for (var r = 0; r < rows.length; r++)
                TableRow(
                  decoration:
                      BoxDecoration(color: r == 0 ? c.raised : c.surface),
                  children: [
                    for (final cell in rows[r])
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Text.rich(
                          _inline(cell, r == 0 ? headStyle : cellStyle, c),
                          style: r == 0 ? headStyle : cellStyle,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---- parsing ---------------------------------------------------------------

enum _BlockType { para, h1, h2, h3, ul, ol, quote, table, rule }

class _Block {
  final _BlockType type;
  final String text;
  final List<String> items;
  final List<List<String>> rows;
  _Block(this.type, {this.text = '', this.items = const [], this.rows = const []});
}

List<_Block> _parseBlocks(String src) {
  final lines = src.replaceAll('\r', '').split('\n');
  final blocks = <_Block>[];
  var i = 0;

  bool isTableLine(String l) {
    final t = l.trim();
    return t.startsWith('|') && t.endsWith('|') && t.length > 2;
  }

  bool isSepRow(String l) =>
      RegExp(r'^\|[\s:|-]+\|$').hasMatch(l.trim()) && l.contains('-');

  while (i < lines.length) {
    final line = lines[i];
    final t = line.trim();

    if (t.isEmpty) {
      i++;
      continue;
    }
    if (t == '---' || t == '***' || t == '___') {
      blocks.add(_Block(_BlockType.rule));
      i++;
      continue;
    }
    if (t.startsWith('### ')) {
      blocks.add(_Block(_BlockType.h3, text: t.substring(4)));
      i++;
      continue;
    }
    if (t.startsWith('## ')) {
      blocks.add(_Block(_BlockType.h2, text: t.substring(3)));
      i++;
      continue;
    }
    if (t.startsWith('# ')) {
      blocks.add(_Block(_BlockType.h1, text: t.substring(2)));
      i++;
      continue;
    }
    if (isTableLine(t)) {
      final rows = <List<String>>[];
      while (i < lines.length && isTableLine(lines[i].trim())) {
        final l = lines[i].trim();
        if (!isSepRow(l)) {
          final cells = l
              .substring(1, l.length - 1)
              .split('|')
              .map((s) => s.trim())
              .toList();
          rows.add(cells);
        }
        i++;
      }
      if (rows.isNotEmpty) blocks.add(_Block(_BlockType.table, rows: rows));
      continue;
    }
    if (t.startsWith('- ') || t.startsWith('* ')) {
      final items = <String>[];
      while (i < lines.length &&
          (lines[i].trim().startsWith('- ') || lines[i].trim().startsWith('* '))) {
        items.add(lines[i].trim().substring(2));
        i++;
      }
      blocks.add(_Block(_BlockType.ul, items: items));
      continue;
    }
    final olMatch = RegExp(r'^\d+[.)]\s+').firstMatch(t);
    if (olMatch != null) {
      final items = <String>[];
      while (i < lines.length) {
        final m = RegExp(r'^\d+[.)]\s+').firstMatch(lines[i].trim());
        if (m == null) break;
        items.add(lines[i].trim().substring(m.end));
        i++;
      }
      blocks.add(_Block(_BlockType.ol, items: items));
      continue;
    }
    if (t.startsWith('> ')) {
      final buf = <String>[];
      while (i < lines.length && lines[i].trim().startsWith('>')) {
        buf.add(lines[i].trim().replaceFirst(RegExp(r'^>\s?'), ''));
        i++;
      }
      blocks.add(_Block(_BlockType.quote, text: buf.join('\n')));
      continue;
    }
    // paragraph: consume consecutive plain lines, preserve single newlines
    final buf = <String>[];
    while (i < lines.length) {
      final l = lines[i];
      final lt = l.trim();
      if (lt.isEmpty ||
          lt.startsWith('#') ||
          lt.startsWith('- ') ||
          lt.startsWith('* ') ||
          lt.startsWith('> ') ||
          isTableLine(lt) ||
          lt == '---' ||
          RegExp(r'^\d+[.)]\s+').hasMatch(lt)) {
        break;
      }
      buf.add(lt);
      i++;
    }
    blocks.add(_Block(_BlockType.para, text: buf.join('\n')));
  }
  return blocks;
}

/// Inline formatting: **bold**, *italic*, `code`.
TextSpan _inline(String text, TextStyle base, AppColors c) {
  final spans = <InlineSpan>[];
  final re = RegExp(r'(\*\*[^*]+\*\*|\*[^*\n]+\*|`[^`\n]+`)');
  var idx = 0;
  for (final m in re.allMatches(text)) {
    if (m.start > idx) {
      spans.add(TextSpan(text: text.substring(idx, m.start)));
    }
    final tok = m.group(0)!;
    if (tok.startsWith('**')) {
      spans.add(TextSpan(
          text: tok.substring(2, tok.length - 2),
          style: base.copyWith(
              fontVariations: [const FontVariation('wght', 680)],
              color: c.ink)));
    } else if (tok.startsWith('`')) {
      spans.add(TextSpan(
          text: ' ${tok.substring(1, tok.length - 1)} ',
          style: base.copyWith(
              backgroundColor: c.raised, color: c.accent, fontSize: (base.fontSize ?? 15) - 1)));
    } else {
      spans.add(TextSpan(
          text: tok.substring(1, tok.length - 1),
          style: base.copyWith(fontStyle: FontStyle.italic)));
    }
    idx = m.end;
  }
  if (idx < text.length) spans.add(TextSpan(text: text.substring(idx)));
  return TextSpan(children: spans, style: base);
}
