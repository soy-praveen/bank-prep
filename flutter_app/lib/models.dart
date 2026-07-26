/// Data models for BankPrep: practice modules, PYQ papers, progress records.
library;

/// One question from a practice module (quiz or speed drill).
class PQuestion {
  final String id;
  final String? group;
  final String? subject; // only for mixed mini-mocks: quant|reasoning|english
  final String? context; // shared passage / DI table / puzzle clues (markdown)
  final String question;
  final List<String>? options; // exactly 5 when MCQ
  final int? correct; // 0-based index into options
  final String? answerText; // for non-MCQ items
  final String solution;
  final String? trick;

  const PQuestion({
    required this.id,
    this.group,
    this.subject,
    this.context,
    required this.question,
    this.options,
    this.correct,
    this.answerText,
    required this.solution,
    this.trick,
  });

  bool get isMcq => options != null && options!.length == 5 && correct != null;

  factory PQuestion.fromJson(Map<String, dynamic> j) => PQuestion(
        id: j['id'] as String,
        group: j['group'] as String?,
        subject: j['subject'] as String?,
        context: j['context'] as String?,
        question: j['question'] as String,
        options: (j['options'] as List?)?.cast<String>(),
        correct: j['correct'] as int?,
        answerText: j['answerText'] as String?,
        solution: (j['solution'] as String?) ?? '',
        trick: j['trick'] as String?,
      );
}

/// A full practice module (one JSON asset).
class PracticeModule {
  final String title;
  final String section; // quant | reasoning | english | mixed
  final String kind; // quiz | speed
  final String source;
  final List<PQuestion> questions;

  const PracticeModule({
    required this.title,
    required this.section,
    required this.kind,
    required this.source,
    required this.questions,
  });

  String get slug => source.endsWith('.md')
      ? source.substring(0, source.length - 3)
      : source;

  factory PracticeModule.fromJson(Map<String, dynamic> j) => PracticeModule(
        title: j['title'] as String,
        section: j['section'] as String,
        kind: (j['kind'] as String?) ?? 'quiz',
        source: j['source'] as String,
        questions: (j['questions'] as List)
            .map((q) => PQuestion.fromJson(q as Map<String, dynamic>))
            .toList(),
      );
}

/// Lightweight entry from the practice index (no questions loaded).
class ModuleMeta {
  final String slug;
  final String title;
  final String section;
  final String kind;
  final String category; // core | volume | strategy | mock
  final int count;

  const ModuleMeta({
    required this.slug,
    required this.title,
    required this.section,
    required this.kind,
    required this.category,
    required this.count,
  });

  factory ModuleMeta.fromJson(Map<String, dynamic> j) => ModuleMeta(
        slug: j['slug'] as String,
        title: j['title'] as String,
        section: j['section'] as String,
        kind: (j['kind'] as String?) ?? 'quiz',
        category: (j['category'] as String?) ?? 'core',
        count: (j['count'] as num).toInt(),
      );
}

/// A set (shared context block) inside a PYQ paper.
class PyqSet {
  final String id;
  final String section;
  final String title;
  final String context;

  const PyqSet({
    required this.id,
    required this.section,
    required this.title,
    required this.context,
  });

  factory PyqSet.fromJson(Map<String, dynamic> j) => PyqSet(
        id: j['id'] as String,
        section: j['section'] as String,
        title: (j['title'] as String?) ?? '',
        context: (j['context'] as String?) ?? '',
      );
}

/// One question inside a PYQ paper.
class PyqQuestion {
  final String id;
  final String section; // english | quant | reasoning
  final String topic;
  final String? setId;
  final String question;
  final List<String> options;
  final int correct;
  final String explanation;
  final int difficulty;

  const PyqQuestion({
    required this.id,
    required this.section,
    required this.topic,
    this.setId,
    required this.question,
    required this.options,
    required this.correct,
    required this.explanation,
    required this.difficulty,
  });

  factory PyqQuestion.fromJson(Map<String, dynamic> j) => PyqQuestion(
        id: j['id'] as String,
        section: j['section'] as String,
        topic: (j['topic'] as String?) ?? '',
        setId: j['setId'] as String?,
        question: j['question'] as String,
        options: (j['options'] as List).cast<String>(),
        correct: (j['correct'] as num).toInt(),
        explanation: (j['explanation'] as String?) ?? '',
        difficulty: (j['difficulty'] as num?)?.toInt() ?? 2,
      );
}

/// A full PYQ paper (one JSON asset).
class PyqPaper {
  final Map<String, PyqSet> sets;
  final List<PyqQuestion> questions;

  const PyqPaper({required this.sets, required this.questions});

  factory PyqPaper.fromJson(Map<String, dynamic> j) {
    final sets = <String, PyqSet>{};
    for (final s in (j['sets'] as List? ?? const [])) {
      final ps = PyqSet.fromJson(s as Map<String, dynamic>);
      sets[ps.id] = ps;
    }
    return PyqPaper(
      sets: sets,
      questions: (j['questions'] as List)
          .map((q) => PyqQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Lightweight entry from the PYQ index.
class PyqMeta {
  final String file;
  final int year;
  final String title;
  final Map<String, int> sections; // section -> question count

  const PyqMeta({
    required this.file,
    required this.year,
    required this.title,
    required this.sections,
  });

  int get total => sections.values.fold(0, (a, b) => a + b);

  factory PyqMeta.fromJson(Map<String, dynamic> j) => PyqMeta(
        file: j['file'] as String,
        year: (j['year'] as num).toInt(),
        title: j['title'] as String,
        sections: (j['sections'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, (v as num).toInt())),
      );
}

/// A recorded answer for one practice question.
class AnswerRec {
  final int sel; // selected option index, or -1 for reveal-style items
  final bool correct;
  const AnswerRec(this.sel, this.correct);

  Map<String, dynamic> toJson() => {'s': sel, 'c': correct};
  factory AnswerRec.fromJson(Map<String, dynamic> j) =>
      AnswerRec((j['s'] as num).toInt(), j['c'] as bool);
}

/// A completed mock attempt.
class MockAttempt {
  final DateTime ts;
  final double score;
  final double max;
  final int correct;
  final int wrong;
  final int skipped;
  final Map<String, List<int>> sections; // section -> [correct, wrong, skipped]

  const MockAttempt({
    required this.ts,
    required this.score,
    required this.max,
    required this.correct,
    required this.wrong,
    required this.skipped,
    required this.sections,
  });

  Map<String, dynamic> toJson() => {
        't': ts.millisecondsSinceEpoch,
        's': score,
        'm': max,
        'c': correct,
        'w': wrong,
        'k': skipped,
        'sec': sections,
      };

  factory MockAttempt.fromJson(Map<String, dynamic> j) => MockAttempt(
        ts: DateTime.fromMillisecondsSinceEpoch((j['t'] as num).toInt()),
        score: (j['s'] as num).toDouble(),
        max: (j['m'] as num).toDouble(),
        correct: (j['c'] as num).toInt(),
        wrong: (j['w'] as num).toInt(),
        skipped: (j['k'] as num).toInt(),
        sections: (j['sec'] as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, (v as List).map((e) => (e as num).toInt()).toList())),
      );
}
