import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../md.dart';
import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';

/// One question inside a mock.
class MockQ {
  final String id;
  final String section;
  final String? context;
  final String question;
  final List<String> options;
  final int correct;
  final String explanation;
  final String? trick;

  const MockQ({
    required this.id,
    required this.section,
    this.context,
    required this.question,
    required this.options,
    required this.correct,
    required this.explanation,
    this.trick,
  });
}

class MockSection {
  final String name;
  final List<MockQ> qs;
  const MockSection(this.name, this.qs);
}

class MockConfig {
  final String paperId;
  final String title;
  final List<MockSection> sections;
  final int? secondsPerSection; // null = untimed

  const MockConfig({
    required this.paperId,
    required this.title,
    required this.sections,
    this.secondsPerSection,
  });

  bool get timed => secondsPerSection != null;
  int get total => sections.fold(0, (a, s) => a + s.qs.length);
}

/// Exam-mode player: no feedback until submit, per-section countdown,
/// palette navigation, mark-for-review, negative marking.
class MockScreen extends StatefulWidget {
  final MockConfig config;
  const MockScreen({super.key, required this.config});

  @override
  State<MockScreen> createState() => _MockScreenState();
}

class _MockScreenState extends State<MockScreen> {
  final Map<String, int> _answers = {};
  final Set<String> _marked = {};
  int _sec = 0;
  int _pos = 0;
  int _left = 0;
  Timer? _timer;

  MockConfig get cfg => widget.config;
  MockSection get section => cfg.sections[_sec];
  MockQ get q => section.qs[_pos];

  @override
  void initState() {
    super.initState();
    _startSection(0);
  }

  void _startSection(int i) {
    _timer?.cancel();
    setState(() {
      _sec = i;
      _pos = 0;
      _left = cfg.secondsPerSection ?? 0;
    });
    if (cfg.timed) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_left <= 1) {
          _timer?.cancel();
          _sectionDone(auto: true);
        } else {
          setState(() => _left--);
        }
      });
    }
  }

  void _sectionDone({bool auto = false}) {
    if (_sec < cfg.sections.length - 1) {
      final next = cfg.sections[_sec + 1].name;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dctx) {
          final c = dctx.c;
          return AlertDialog(
            backgroundColor: c.surface,
            title: Text(auto ? 'Time up' : 'Section submitted',
                style: inter(650, size: 17, color: c.ink)),
            content: Text('Moving to $next.',
                style: inter(450, size: 14, color: c.muted)),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(dctx);
                  _startSection(_sec + 1);
                },
                child: Text('Start $next'),
              ),
            ],
          );
        },
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    _timer?.cancel();
    // score
    var right = 0, wrong = 0, skip = 0;
    final perSection = <String, List<int>>{};
    for (final s in cfg.sections) {
      var r = 0, w = 0, k = 0;
      for (final mq in s.qs) {
        final a = _answers[mq.id];
        if (a == null) {
          k++;
        } else if (a == mq.correct) {
          r++;
        } else {
          w++;
        }
      }
      right += r;
      wrong += w;
      skip += k;
      perSection[s.name] = [r, w, k];
    }
    final score = right - wrong * 0.25;
    final attempt = MockAttempt(
      ts: DateTime.now(),
      score: score,
      max: cfg.total.toDouble(),
      correct: right,
      wrong: wrong,
      skipped: skip,
      sections: perSection,
    );
    await Store.I.addMockAttempt(cfg.paperId, attempt);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => MockResultScreen(
          config: cfg, answers: Map.of(_answers), attempt: attempt),
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final answered = _answers.containsKey(q.id);
    final globalIndex =
        cfg.sections.take(_sec).fold(0, (a, s) => a + s.qs.length) + _pos + 1;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        showDialog(
          context: context,
          builder: (dctx) => AlertDialog(
            backgroundColor: c.surface,
            title: Text('Quit mock?', style: inter(650, size: 17, color: c.ink)),
            content: Text('This attempt will not be saved.',
                style: inter(450, size: 14, color: c.muted)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(dctx),
                  child: const Text('Keep going')),
              TextButton(
                onPressed: () {
                  Navigator.pop(dctx);
                  Navigator.of(context).pop();
                },
                child: Text('Quit', style: TextStyle(color: c.danger)),
              ),
            ],
          ),
        );
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: c.violet.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(section.name,
                        style: inter(650, size: 11.5, color: c.violet)),
                  ),
                  const SizedBox(width: 8),
                  Text('Q$globalIndex / ${cfg.total}',
                      style: inter(550, size: 12, color: c.muted)),
                  const Spacer(),
                  if (cfg.timed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _left < 120
                            ? c.danger.withValues(alpha: 0.13)
                            : c.raised,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                            color: _left < 120 ? c.danger : c.line),
                      ),
                      child: Row(children: [
                        Icon(LucideIcons.timer,
                            size: 13,
                            color: _left < 120 ? c.danger : c.muted),
                        const SizedBox(width: 5),
                        Text(fmtClock(_left),
                            style: grotesk(650,
                                size: 13,
                                color: _left < 120 ? c.danger : c.ink)),
                      ]),
                    ),
                  IconButton(
                    onPressed: _openPalette,
                    icon:
                        Icon(LucideIcons.layoutGrid, size: 19, color: c.muted),
                  ),
                ]),
              ),

              // question
              Expanded(
                child: SingleChildScrollView(
                  key: ValueKey(q.id),
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (q.context != null &&
                          q.context!.trim().isNotEmpty) ...[
                        ContextCard(q.context!,
                            initiallyOpen: _pos == 0 ||
                                section.qs
                                        .indexWhere((x) =>
                                            x.context == q.context)
                                        .clamp(0, section.qs.length) ==
                                    _pos),
                        const SizedBox(height: 14),
                      ],
                      MdText(q.question,
                          baseStyle:
                              inter(540, size: 16, color: c.ink, height: 1.45)),
                      const SizedBox(height: 16),
                      for (var i = 0; i < q.options.length; i++)
                        OptionTile(
                          letter: String.fromCharCode(65 + i),
                          text: q.options[i],
                          state: _answers[q.id] == i
                              ? OptionState.selected
                              : OptionState.idle,
                          onTap: () => setState(() {
                            if (_answers[q.id] == i) {
                              _answers.remove(q.id); // tap again to clear
                            } else {
                              _answers[q.id] = i;
                            }
                          }),
                        ),
                      if (answered)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                setState(() => _answers.remove(q.id)),
                            child: const Text('Clear choice'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // bottom bar
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                decoration: BoxDecoration(
                  color: c.surface,
                  border: Border(top: BorderSide(color: c.line)),
                ),
                child: Row(children: [
                  OutlinedButton(
                    onPressed:
                        _pos > 0 ? () => setState(() => _pos--) : null,
                    child: const Icon(LucideIcons.chevronLeft, size: 18),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => setState(() {
                      if (_marked.contains(q.id)) {
                        _marked.remove(q.id);
                      } else {
                        _marked.add(q.id);
                      }
                    }),
                    icon: Icon(LucideIcons.flag,
                        size: 19,
                        color:
                            _marked.contains(q.id) ? c.warn : c.muted),
                  ),
                  const Spacer(),
                  if (_pos < section.qs.length - 1)
                    FilledButton(
                      onPressed: () => setState(() => _pos++),
                      child: Row(children: [
                        const Text('Next'),
                        const SizedBox(width: 6),
                        const Icon(LucideIcons.chevronRight, size: 17),
                      ]),
                    )
                  else
                    FilledButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (dctx) => AlertDialog(
                          backgroundColor: c.surface,
                          title: Text(
                              _sec == cfg.sections.length - 1
                                  ? 'Submit mock?'
                                  : 'Submit ${section.name}?',
                              style: inter(650, size: 17, color: c.ink)),
                          content: Text(
                              '${section.qs.where((x) => _answers.containsKey(x.id)).length} of ${section.qs.length} answered in this section.',
                              style: inter(450, size: 14, color: c.muted)),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(dctx),
                                child: const Text('Back')),
                            FilledButton(
                              onPressed: () {
                                Navigator.pop(dctx);
                                _sectionDone();
                              },
                              child: const Text('Submit'),
                            ),
                          ],
                        ),
                      ),
                      child: Text(_sec == cfg.sections.length - 1
                          ? 'Submit mock'
                          : 'Submit section'),
                    ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openPalette() {
    final c = context.c;
    showModalBottomSheet(
      context: context,
      builder: (bctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(section.name.toUpperCase(),
                    style: inter(700, size: 11, color: c.muted, ls: 1.4)),
                const Spacer(),
                _legend(c.good, 'answered'),
                const SizedBox(width: 10),
                _legend(c.warn, 'marked'),
              ]),
              const SizedBox(height: 14),
              Flexible(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var i = 0; i < section.qs.length; i++)
                        () {
                          final mq = section.qs[i];
                          final done = _answers.containsKey(mq.id);
                          final mk = _marked.contains(mq.id);
                          return InkWell(
                            onTap: () {
                              Navigator.pop(bctx);
                              setState(() => _pos = i);
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: done
                                    ? c.good.withValues(alpha: 0.16)
                                    : c.raised,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: i == _pos
                                      ? c.accent
                                      : mk
                                          ? c.warn
                                          : done
                                              ? c.good
                                              : c.line,
                                  width: i == _pos ? 1.8 : 1.2,
                                ),
                              ),
                              child: Text('${i + 1}',
                                  style: inter(600, size: 13, color: c.ink)),
                            ),
                          );
                        }(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legend(Color color, String label) {
    final c = context.c;
    return Row(children: [
      Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: inter(500, size: 10.5, color: c.muted)),
    ]);
  }
}

// ---- results ---------------------------------------------------------------

class MockResultScreen extends StatelessWidget {
  final MockConfig config;
  final Map<String, int> answers;
  final MockAttempt attempt;

  const MockResultScreen(
      {super.key,
      required this.config,
      required this.answers,
      required this.attempt});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final pct = attempt.max == 0 ? 0.0 : (attempt.score / attempt.max).clamp(0.0, 1.0);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          children: [
            Row(children: [
              const Spacer(),
              IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(LucideIcons.x, size: 20, color: c.muted)),
            ]),
            const SizedBox(height: 8),
            Center(
              child: Entrance(
                child: ProgressRing(
                  value: pct,
                  size: 160,
                  stroke: 12,
                  color: pct >= 0.6
                      ? c.good
                      : pct >= 0.4
                          ? c.accent
                          : c.danger,
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          attempt.score
                              .toStringAsFixed(attempt.score % 1 == 0 ? 0 : 2),
                          style: grotesk(700, size: 34, color: c.ink)),
                      Text('of ${attempt.max.round()}',
                          style: inter(500, size: 12, color: c.muted)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Entrance(
                delayMs: 80,
                child: Text(config.title,
                    style: inter(650, size: 16.5, color: c.ink)),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Entrance(
                delayMs: 110,
                child: Text(
                    '${attempt.correct} right  ·  ${attempt.wrong} wrong (-${(attempt.wrong * 0.25).toStringAsFixed(2)})  ·  ${attempt.skipped} skipped',
                    style: inter(480, size: 13, color: c.muted)),
              ),
            ),
            const SizedBox(height: 22),
            Entrance(
              delayMs: 150,
              child: Container(
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: c.line),
                ),
                child: Column(children: [
                  for (final (i, e) in attempt.sections.entries.indexed) ...[
                    if (i > 0) Divider(color: c.line),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(children: [
                        Expanded(
                            child: Text(e.key,
                                style: inter(600, size: 14, color: c.ink))),
                        Text(
                            '${e.value[0]} R   ${e.value[1]} W   ${e.value[2]} S',
                            style: inter(550, size: 13, color: c.muted)),
                        const SizedBox(width: 14),
                        Text(
                            (e.value[0] - e.value[1] * 0.25)
                                .toStringAsFixed(2),
                            style: grotesk(650, size: 15, color: c.accent)),
                      ]),
                    ),
                  ],
                ]),
              ),
            ),
            const SizedBox(height: 22),
            Entrance(
              delayMs: 200,
              child: FilledButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        MockReviewScreen(config: config, answers: answers))),
                child: const Text('Review all answers'),
              ),
            ),
            const SizedBox(height: 10),
            Entrance(
              delayMs: 230,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- review ----------------------------------------------------------------

class MockReviewScreen extends StatefulWidget {
  final MockConfig config;
  final Map<String, int> answers;
  const MockReviewScreen(
      {super.key, required this.config, required this.answers});

  @override
  State<MockReviewScreen> createState() => _MockReviewScreenState();
}

class _MockReviewScreenState extends State<MockReviewScreen> {
  String _filter = 'all'; // all | wrong | skipped

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final items = <(MockSection, MockQ)>[];
    for (final s in widget.config.sections) {
      for (final q in s.qs) {
        final a = widget.answers[q.id];
        final wrong = a != null && a != q.correct;
        final skipped = a == null;
        if (_filter == 'wrong' && !wrong) continue;
        if (_filter == 'skipped' && !skipped) continue;
        items.add((s, q));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review'),
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(LucideIcons.chevronLeft, size: 21)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
            child: Row(children: [
              for (final f in [
                ('all', 'All'),
                ('wrong', 'Wrong'),
                ('skipped', 'Skipped')
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f.$2),
                    selected: _filter == f.$1,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _filter = f.$1),
                  ),
                ),
            ]),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text('Nothing in this filter',
                        style: inter(500, size: 14, color: c.muted)))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final (s, q) = items[i];
                      final a = widget.answers[q.id];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _ReviewCard(section: s.name, q: q, chosen: a),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String section;
  final MockQ q;
  final int? chosen;
  const _ReviewCard({required this.section, required this.q, this.chosen});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final letters = ['A', 'B', 'C', 'D', 'E'];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(section.toUpperCase(),
                style: inter(700, size: 10, color: c.violet, ls: 1.2)),
            const Spacer(),
            if (chosen == null)
              Text('SKIPPED',
                  style: inter(700, size: 10, color: c.muted, ls: 1.2))
            else if (chosen == q.correct)
              Icon(LucideIcons.checkCircle2, size: 16, color: c.good)
            else
              Icon(LucideIcons.xCircle, size: 16, color: c.danger),
          ]),
          const SizedBox(height: 8),
          if (q.context != null && q.context!.trim().isNotEmpty) ...[
            ContextCard(q.context!, initiallyOpen: false),
            const SizedBox(height: 10),
          ],
          MdText(q.question,
              baseStyle: inter(540, size: 14.5, color: c.ink, height: 1.4)),
          const SizedBox(height: 10),
          for (var i = 0; i < q.options.length; i++)
            OptionTile(
              letter: letters[i],
              text: q.options[i],
              state: i == q.correct
                  ? OptionState.correct
                  : i == chosen
                      ? OptionState.wrong
                      : OptionState.dimmed,
            ),
          if (q.explanation.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            MdText(q.explanation,
                baseStyle: inter(450, size: 13, color: c.muted, height: 1.45)),
          ],
          if (q.trick != null && q.trick!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            TrickCard(q.trick!),
          ],
        ],
      ),
    );
  }
}
