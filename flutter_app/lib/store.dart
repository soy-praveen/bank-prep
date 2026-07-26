/// Progress persistence on top of SharedPreferences.
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class Store {
  Store._(this._p);
  static Store? _instance;
  final SharedPreferences _p;

  /// Notifies listeners whenever any progress value changes.
  static final ValueNotifier<int> version = ValueNotifier(0);

  static Future<Store> init() async {
    _instance ??= Store._(await SharedPreferences.getInstance());
    return _instance!;
  }

  static Store get I => _instance!;

  static void _bump() => version.value++;

  // ---- practice answers ----------------------------------------------------

  Map<String, AnswerRec> answers(String slug) {
    final raw = _p.getString('ans.$slug');
    if (raw == null) return {};
    final m = jsonDecode(raw) as Map<String, dynamic>;
    return m.map((k, v) => MapEntry(k, AnswerRec.fromJson(v as Map<String, dynamic>)));
  }

  Future<void> setAnswer(String slug, String qid, AnswerRec rec) async {
    final all = answers(slug);
    all[qid] = rec;
    await _p.setString(
        'ans.$slug', jsonEncode(all.map((k, v) => MapEntry(k, v.toJson()))));
    _bump();
  }

  Future<void> resetModule(String slug) async {
    await _p.remove('ans.$slug');
    _bump();
  }

  (int answered, int correct) moduleStats(String slug) {
    final a = answers(slug);
    var c = 0;
    for (final r in a.values) {
      if (r.correct) c++;
    }
    return (a.length, c);
  }

  // ---- mock attempts -------------------------------------------------------

  List<MockAttempt> mockAttempts(String paperId) {
    final raw = _p.getString('mock.$paperId');
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => MockAttempt.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addMockAttempt(String paperId, MockAttempt a) async {
    final list = mockAttempts(paperId)..add(a);
    await _p.setString('mock.$paperId', jsonEncode(list.map((e) => e.toJson()).toList()));
    _bump();
  }

  // ---- speed drill best times ---------------------------------------------

  int? speedBestMs(String slug, String group) => _p.getInt('speed.$slug.$group');

  Future<void> setSpeedBestMs(String slug, String group, int ms) async {
    final cur = speedBestMs(slug, group);
    if (cur == null || ms < cur) {
      await _p.setInt('speed.$slug.$group', ms);
      _bump();
    }
  }

  // ---- misc ----------------------------------------------------------------

  ThemeMode themeMode() => switch (_p.getString('theme')) {
        'dark' => ThemeMode.dark,
        'light' => ThemeMode.light,
        _ => ThemeMode.dark,
      };

  Future<void> setThemeMode(ThemeMode m) async {
    await _p.setString('theme', m.name);
    _bump();
  }

  ({String slug, String title})? lastQuiz() {
    final raw = _p.getString('last.quiz');
    if (raw == null) return null;
    final j = jsonDecode(raw) as Map<String, dynamic>;
    return (slug: j['s'] as String, title: j['t'] as String);
  }

  Future<void> setLastQuiz(String slug, String title) async {
    await _p.setString('last.quiz', jsonEncode({'s': slug, 't': title}));
    _bump();
  }
}
