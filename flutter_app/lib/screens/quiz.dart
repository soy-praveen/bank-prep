import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../data.dart';
import '../md.dart';
import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';

/// Practice quiz player: instant feedback, solutions, tricks, resume,
/// review-wrong and retry-wrong flows.
class QuizScreen extends StatefulWidget {
  final ModuleMeta meta;
  final List<String>? onlyIds; // subset (retry/review wrong)
  final bool reviewMode;

  const QuizScreen(
      {super.key, required this.meta, this.onlyIds, this.reviewMode = false});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  PracticeModule? _module;
  List<PQuestion> _qs = [];
  int _idx = 0;
  bool _finished = false;
  bool _revealed = false; // for non-MCQ items
  int _navDir = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final m = await AppData.instance.module(widget.meta.slug);
    var qs = m.questions;
    if (widget.onlyIds != null) {
      final set = widget.onlyIds!.toSet();
      qs = qs.where((q) => set.contains(q.id)).toList();
    }
    var start = 0;
    if (!widget.reviewMode) {
      Store.I.setLastQuiz(widget.meta.slug, widget.meta.title);
      final ans = Store.I.answers(widget.meta.slug);
      start = qs.indexWhere((q) => !ans.containsKey(q.id));
      if (start == -1) start = 0;
    }
    setState(() {
      _module = m;
      _qs = qs;
      _idx = start;
    });
  }

  Map<String, AnswerRec> get _answers => Store.I.answers(widget.meta.slug);

  void _select(PQuestion q, int i) {
    if (widget.reviewMode) return;
    if (_answers.containsKey(q.id)) return; // already graded
    Store.I.setAnswer(
        widget.meta.slug, q.id, AnswerRec(i, i == q.correct));
    setState(() {});
  }

  void _selfMark(PQuestion q, bool correct) {
    if (widget.reviewMode) return;
    Store.I.setAnswer(widget.meta.slug, q.id, AnswerRec(-1, correct));
    setState(() => _revealed = false);
    _next();
  }

  void _next() {
    if (_idx < _qs.length - 1) {
      setState(() {
        _navDir = 1;
        _idx++;
        _revealed = false;
      });
    } else {
      setState(() => _finished = true);
    }
  }

  void _prev() {
    if (_idx > 0) {
      setState(() {
        _navDir = -1;
        _idx--;
        _revealed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    if (_module == null) {
      return Scaffold(
          body: Center(child: CircularProgressIndicator(color: c.accent)));
    }
    if (_qs.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.meta.title)),
        body: Center(
            child: Text('Nothing here', style: inter(500, size: 14, color: c.muted))),
      );
    }
    if (_finished) return _endScreen(c);

    final q = _qs[_idx];
    final rec = _answers[q.id];
    final answered = widget.reviewMode || rec != null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
              child: Row(children: [
                IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(LucideIcons.x, size: 20, color: c.muted)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.meta.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: inter(620, size: 13.5, color: c.ink)),
                      const SizedBox(height: 2),
                      Text(
                          '${_idx + 1} of ${_qs.length}${widget.reviewMode ? '  ·  review' : ''}',
                          style: inter(500, size: 11, color: c.muted)),
                    ],
                  ),
                ),
                IconButton(
                    onPressed: () => _openPalette(c),
                    icon: Icon(LucideIcons.layoutGrid,
                        size: 19, color: c.muted)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: (_idx + 1) / _qs.length,
                  minHeight: 4,
                  backgroundColor: c.raised,
                  color: sectionColor(_module!.section, c),
                ),
              ),
            ),

            // question area with shared-axis transition
            Expanded(
              child: PageTransitionSwitcher(
                duration: const Duration(milliseconds: 300),
                reverse: _navDir < 0,
                transitionBuilder: (child, primary, secondary) =>
                    SharedAxisTransition(
                  animation: primary,
                  secondaryAnimation: secondary,
                  transitionType: SharedAxisTransitionType.horizontal,
                  fillColor: Colors.transparent,
                  child: child,
                ),
                child: SingleChildScrollView(
                  key: ValueKey('${q.id}-$_idx'),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: _questionBody(c, q, rec, answered),
                ),
              ),
            ),

            // bottom bar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
              decoration: BoxDecoration(
                color: c.surface,
                border: Border(top: BorderSide(color: c.line)),
              ),
              child: Row(children: [
                OutlinedButton(
                  onPressed: _idx > 0 ? _prev : null,
                  child: const Icon(LucideIcons.chevronLeft, size: 18),
                ),
                const Spacer(),
                if (answered || widget.reviewMode)
                  FilledButton(
                    onPressed: _next,
                    child: Row(children: [
                      Text(_idx == _qs.length - 1 ? 'Finish' : 'Next'),
                      const SizedBox(width: 6),
                      const Icon(LucideIcons.chevronRight, size: 17),
                    ]),
                  )
                else
                  Text('Pick an answer',
                      style: inter(500, size: 12.5, color: c.muted)),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _questionBody(
      AppColors c, PQuestion q, AnswerRec? rec, bool answered) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (q.group != null) ...[
          Text(q.group!.toUpperCase(),
              style: inter(700, size: 10.5, color: c.accent, ls: 1.2)),
          const SizedBox(height: 8),
        ],
        if (q.context != null && q.context!.trim().isNotEmpty) ...[
          ContextCard(q.context!, initiallyOpen: !answered),
          const SizedBox(height: 14),
        ],
        MdText(q.question,
            baseStyle: inter(540, size: 16.5, color: c.ink, height: 1.45)),
        const SizedBox(height: 16),

        if (q.isMcq)
          ..._mcqOptions(c, q, rec)
        else
          ..._revealFlow(c, q, rec),

        // solution
        if (answered || (_revealed && !q.isMcq)) ...[
          const SizedBox(height: 8),
          _SolutionCard(q: q, rec: rec),
        ],
      ],
    );
  }

  List<Widget> _mcqOptions(AppColors c, PQuestion q, AnswerRec? rec) {
    final letters = ['A', 'B', 'C', 'D', 'E'];
    return [
      for (var i = 0; i < q.options!.length; i++)
        OptionTile(
          letter: letters[i],
          text: q.options![i],
          state: () {
            if (rec == null) return OptionState.idle;
            if (i == q.correct) return OptionState.correct;
            if (i == rec.sel && !rec.correct) return OptionState.wrong;
            return OptionState.dimmed;
          }(),
          onTap: rec == null ? () => _select(q, i) : null,
        ),
    ];
  }

  List<Widget> _revealFlow(AppColors c, PQuestion q, AnswerRec? rec) {
    if (rec != null) {
      return [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: (rec.correct ? c.good : c.danger).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: rec.correct ? c.good : c.danger, width: 1.4),
          ),
          child: Row(children: [
            Icon(rec.correct ? LucideIcons.check : LucideIcons.x,
                size: 17, color: rec.correct ? c.good : c.danger),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                  'Answer: ${q.answerText ?? ''}  ·  you marked it ${rec.correct ? 'right' : 'missed'}',
                  style: inter(560, size: 13.5, color: c.ink)),
            ),
          ]),
        ),
      ];
    }
    if (!_revealed) {
      return [
        OutlinedButton(
          onPressed: () => setState(() => _revealed = true),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(LucideIcons.eye, size: 16),
            const SizedBox(width: 8),
            const Text('Reveal answer'),
          ]),
        ),
      ];
    }
    return [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.raised,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.accent, width: 1.2),
        ),
        child: Text(q.answerText ?? '',
            style: grotesk(650, size: 17, color: c.ink)),
      ),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _selfMark(_qs[_idx], false),
            style: OutlinedButton.styleFrom(
                foregroundColor: c.danger,
                side: BorderSide(color: c.danger.withValues(alpha: 0.6))),
            child: const Text('Missed it'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton(
            onPressed: () => _selfMark(_qs[_idx], true),
            style: FilledButton.styleFrom(backgroundColor: c.good),
            child: const Text('Got it'),
          ),
        ),
      ]),
    ];
  }

  void _openPalette(AppColors c) {
    final ans = _answers;
    showModalBottomSheet(
      context: context,
      builder: (bctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('JUMP TO',
                  style: inter(700, size: 11, color: c.muted, ls: 1.4)),
              const SizedBox(height: 14),
              Flexible(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var i = 0; i < _qs.length; i++)
                        () {
                          final r = ans[_qs[i].id];
                          final bg = r == null
                              ? c.raised
                              : r.correct
                                  ? c.good.withValues(alpha: 0.18)
                                  : c.danger.withValues(alpha: 0.15);
                          final bd = r == null
                              ? c.line
                              : r.correct
                                  ? c.good
                                  : c.danger;
                          return InkWell(
                            onTap: () {
                              Navigator.pop(bctx);
                              setState(() {
                                _navDir = i > _idx ? 1 : -1;
                                _idx = i;
                                _revealed = false;
                                _finished = false;
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: bg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: i == _idx ? c.accent : bd,
                                    width: i == _idx ? 1.8 : 1),
                              ),
                              child: Text('${i + 1}',
                                  style:
                                      inter(600, size: 13, color: c.ink)),
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

  Widget _endScreen(AppColors c) {
    final ans = _answers;
    var right = 0, wrong = 0;
    final wrongIds = <String>[];
    for (final q in _qs) {
      final r = ans[q.id];
      if (r == null) continue;
      if (r.correct) {
        right++;
      } else {
        wrong++;
        wrongIds.add(q.id);
      }
    }
    final attempted = right + wrong;
    final acc = attempted == 0 ? 0.0 : right / attempted;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(children: [
                IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(LucideIcons.x, size: 20, color: c.muted)),
              ]),
              const Spacer(),
              Entrance(
                child: ProgressRing(
                  value: acc,
                  size: 148,
                  stroke: 11,
                  color: acc >= 0.8
                      ? c.good
                      : acc >= 0.5
                          ? c.accent
                          : c.danger,
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${(acc * 100).round()}%',
                          style: grotesk(700, size: 32, color: c.ink)),
                      Text('accuracy',
                          style: inter(500, size: 11.5, color: c.muted)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Entrance(
                delayMs: 80,
                child: Text(
                  acc >= 0.85
                      ? 'Locked in. This is exam-ready.'
                      : acc >= 0.6
                          ? 'Solid. Review the misses and re-run them.'
                          : 'Rough set - the review is where the marks are.',
                  textAlign: TextAlign.center,
                  style: inter(600, size: 16.5, color: c.ink),
                ),
              ),
              const SizedBox(height: 10),
              Entrance(
                delayMs: 120,
                child: Text('$right correct  ·  $wrong wrong  ·  ${_qs.length - attempted} unseen',
                    style: inter(480, size: 13.5, color: c.muted)),
              ),
              const Spacer(),
              if (wrongIds.isNotEmpty) ...[
                Entrance(
                  delayMs: 160,
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) => QuizScreen(
                                  meta: widget.meta,
                                  onlyIds: wrongIds,
                                  reviewMode: true))),
                      child: Text('Review ${wrongIds.length} wrong'),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Entrance(
                  delayMs: 190,
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        // clear just the wrong ones, retry
                        final all = Store.I.answers(widget.meta.slug);
                        for (final id in wrongIds) {
                          all.remove(id);
                        }
                        await Store.I.resetModule(widget.meta.slug);
                        for (final e in all.entries) {
                          await Store.I
                              .setAnswer(widget.meta.slug, e.key, e.value);
                        }
                        if (mounted && context.mounted) {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (_) => QuizScreen(
                                      meta: widget.meta,
                                      onlyIds: wrongIds)));
                        }
                      },
                      child: const Text('Retry wrong only'),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Entrance(
                delayMs: 220,
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('Done'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SolutionCard extends StatelessWidget {
  final PQuestion q;
  final AnswerRec? rec;
  const _SolutionCard({required this.q, this.rec});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child:
            Transform.translate(offset: Offset(0, 10 * (1 - v)), child: child),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(LucideIcons.lightbulb, size: 14, color: c.warn),
                  const SizedBox(width: 6),
                  Text('SOLUTION',
                      style: inter(700, size: 10.5, color: c.muted, ls: 1.2)),
                ]),
                const SizedBox(height: 8),
                MdText(q.solution,
                    baseStyle:
                        inter(460, size: 13.5, color: c.ink, height: 1.5)),
              ],
            ),
          ),
          if (q.trick != null && q.trick!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            TrickCard(q.trick!),
          ],
        ],
      ),
    );
  }
}
