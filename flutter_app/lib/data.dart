/// Asset loading + in-memory caching for question data and notes.
library;

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'models.dart';

class AppData {
  AppData._();
  static final AppData instance = AppData._();

  List<ModuleMeta>? _practiceIndex;
  List<PyqMeta>? _pyqIndex;
  final Map<String, PracticeModule> _modules = {};
  final Map<String, PyqPaper> _papers = {};

  Future<List<ModuleMeta>> practiceIndex() async {
    if (_practiceIndex != null) return _practiceIndex!;
    final raw = await rootBundle.loadString('assets/data/practice/index.json');
    final list = (jsonDecode(raw) as List)
        .map((e) => ModuleMeta.fromJson(e as Map<String, dynamic>))
        .toList();
    _practiceIndex = list;
    return list;
  }

  Future<List<PyqMeta>> pyqIndex() async {
    if (_pyqIndex != null) return _pyqIndex!;
    final raw = await rootBundle.loadString('assets/data/pyq/index.json');
    final list = (jsonDecode(raw) as List)
        .map((e) => PyqMeta.fromJson(e as Map<String, dynamic>))
        .toList();
    list.sort((a, b) => b.year.compareTo(a.year));
    _pyqIndex = list;
    return list;
  }

  Future<PracticeModule> module(String slug) async {
    if (_modules.containsKey(slug)) return _modules[slug]!;
    final raw = await rootBundle.loadString('assets/data/practice/$slug.json');
    final m = PracticeModule.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    _modules[slug] = m;
    return m;
  }

  Future<PyqPaper> paper(String file) async {
    if (_papers.containsKey(file)) return _papers[file]!;
    final raw = await rootBundle.loadString('assets/data/pyq/$file');
    final p = PyqPaper.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    _papers[file] = p;
    return p;
  }

  Future<String> note(String file) => rootBundle.loadString('assets/notes/$file');
}

/// The notes shipped with the app, in display order.
const noteFiles = [
  ('reasoning.md', 'Reasoning Toolkit', 'Every method: puzzles, syllogism, inequality, directions'),
  ('quant.md', 'Quant Toolkit', 'Speed engine, DI workflow, all arithmetic formulas'),
  ('english.md', 'English Toolkit', 'Grammar rulebook, RC, jumbles, cloze methods'),
  ('quant-multi-method.md', 'Quant: Pick the Fastest', '20 problems solved 2-3 ways, fastest first'),
  ('reasoning-multi-method.md', 'Reasoning: Pick the Fastest', '15 problems, quickest route per type'),
  ('progress-and-leaks.md', 'Strategy & Leaks', 'Exam-day plan, score targets, your leak list'),
];

/// Human titles for section keys.
String sectionLabel(String s) => switch (s) {
      'quant' => 'Quant',
      'reasoning' => 'Reasoning',
      'english' => 'English',
      'mixed' => 'Mixed',
      _ => s,
    };
