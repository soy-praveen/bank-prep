// Data integrity harness: every bundled JSON asset must parse into the
// app models and satisfy the invariants the UI relies on.
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bankprep/models.dart';

final _astralEmoji = RegExp(r'[\u{1F300}-\u{1FAFF}]', unicode: true);

void expectClean(String s, String where) {
  expect(_astralEmoji.hasMatch(s), isFalse, reason: 'emoji found in $where');
}

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('practice index + every module parses with valid invariants', () async {
    final idxRaw =
        await rootBundle.loadString('assets/data/practice/index.json');
    final metas = (jsonDecode(idxRaw) as List)
        .map((e) => ModuleMeta.fromJson(e as Map<String, dynamic>))
        .toList();
    expect(metas.length, greaterThanOrEqualTo(25));

    var total = 0;
    for (final meta in metas) {
      final raw = await rootBundle
          .loadString('assets/data/practice/${meta.slug}.json');
      final m = PracticeModule.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      expect(m.questions, isNotEmpty, reason: meta.slug);
      expect(m.questions.length, meta.count,
          reason: 'count mismatch in ${meta.slug}');
      total += m.questions.length;

      final ids = <String>{};
      for (final q in m.questions) {
        expect(ids.add(q.id), isTrue, reason: 'dup id ${q.id} in ${meta.slug}');
        expect(q.question.trim(), isNotEmpty, reason: '${q.id} empty question');
        if (q.options != null) {
          expect(q.options!.length, 5, reason: '${q.id} needs 5 options');
          expect(q.correct, isNotNull, reason: '${q.id} missing correct');
          expect(q.correct! >= 0 && q.correct! < 5, isTrue,
              reason: '${q.id} correct out of range');
        } else {
          expect(q.answerText != null && q.answerText!.trim().isNotEmpty,
              isTrue,
              reason: '${q.id} non-MCQ needs answerText');
        }
        if (m.kind != 'speed') {
          expect(q.solution.trim(), isNotEmpty,
              reason: '${q.id} empty solution');
        }
        expectClean(q.question, q.id);
        expectClean(q.solution, q.id);
        for (final o in q.options ?? const <String>[]) {
          expectClean(o, q.id);
        }
      }

      // mini-mocks must be fully MCQ (the mock engine requires it)
      if (meta.category == 'mock') {
        expect(m.questions.every((q) => q.isMcq), isTrue,
            reason: '${meta.slug} has non-MCQ items');
      }
    }
    expect(total, greaterThanOrEqualTo(900));
  });

  test('pyq index + every paper parses with valid invariants', () async {
    final idxRaw = await rootBundle.loadString('assets/data/pyq/index.json');
    final metas = (jsonDecode(idxRaw) as List)
        .map((e) => PyqMeta.fromJson(e as Map<String, dynamic>))
        .toList();
    expect(metas.length, 11);

    for (final meta in metas) {
      final raw = await rootBundle.loadString('assets/data/pyq/${meta.file}');
      final p = PyqPaper.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      expect(p.questions.length, greaterThanOrEqualTo(90),
          reason: meta.file);
      for (final q in p.questions) {
        expect(q.options.length, 5, reason: q.id);
        expect(q.correct >= 0 && q.correct < 5, isTrue, reason: q.id);
        if (q.setId != null) {
          expect(p.sets.containsKey(q.setId), isTrue,
              reason: '${q.id} dangling setId');
        }
      }
      // index counts match reality
      final bySec = <String, int>{};
      for (final q in p.questions) {
        bySec[q.section] = (bySec[q.section] ?? 0) + 1;
      }
      for (final e in meta.sections.entries) {
        expect(bySec[e.key], e.value,
            reason: '${meta.file} section count ${e.key}');
      }
    }
  });

  test('notes assets exist', () async {
    for (final f in [
      'reasoning.md',
      'quant.md',
      'english.md',
      'quant-multi-method.md',
      'reasoning-multi-method.md',
      'progress-and-leaks.md',
    ]) {
      final s = await rootBundle.loadString('assets/notes/$f');
      expect(s.trim(), isNotEmpty, reason: f);
    }
  });
}
