import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data.dart';
import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';

/// Speed drill: pick a group, then rapid-fire flashcards against the clock.
class SpeedScreen extends StatelessWidget {
  final ModuleMeta meta;
  const SpeedScreen({super.key, required this.meta});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speed Drills'),
        leading: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(LucideIcons.chevronLeft, size: 21)),
      ),
      body: FutureBuilder<PracticeModule>(
        future: AppData.instance.module(meta.slug),
        builder: (context, snap) {
          if (!snap.hasData) {
            return Center(child: CircularProgressIndicator(color: c.accent));
          }
          final m = snap.data!;
          // groups in first-seen order
          final groups = <String, List<PQuestion>>{};
          for (final q in m.questions) {
            groups.putIfAbsent(q.group ?? 'Drills', () => []).add(q);
          }
          return ValueListenableBuilder(
            valueListenable: Store.version,
            builder: (context, _, __) => ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              children: [
                Text('Tap to reveal, self-mark, beat the clock.',
                    style: inter(480, size: 13, color: c.muted)),
                const SizedBox(height: 14),
                for (final (i, e) in groups.entries.indexed)
                  Entrance(
                    delayMs: i * 40,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _GroupCard(
                        slug: meta.slug,
                        name: e.key,
                        items: e.value,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final String slug;
  final String name;
  final List<PQuestion> items;
  const _GroupCard(
      {required this.slug, required this.name, required this.items});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final best = Store.I.speedBestMs(slug, name);
    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) =>
                _SpeedSession(slug: slug, group: name, items: items))),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.line),
          ),
          child: Row(children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: c.warn.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(LucideIcons.gauge, size: 19, color: c.warn),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: inter(620, size: 14, color: c.ink)),
                  const SizedBox(height: 2),
                  Text('${items.length} calcs  ·  target under 60s',
                      style: inter(460, size: 12, color: c.muted)),
                ],
              ),
            ),
            if (best != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: c.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text('best ${fmtMs(best)}',
                    style: inter(650, size: 11, color: c.accent)),
              )
            else
              Icon(LucideIcons.chevronRight, size: 18, color: c.muted),
          ]),
        ),
      ),
    );
  }
}

class _SpeedSession extends StatefulWidget {
  final String slug;
  final String group;
  final List<PQuestion> items;
  const _SpeedSession(
      {required this.slug, required this.group, required this.items});

  @override
  State<_SpeedSession> createState() => _SpeedSessionState();
}

class _SpeedSessionState extends State<_SpeedSession> {
  final Stopwatch _watch = Stopwatch();
  Timer? _tick;
  int _idx = 0;
  bool _revealed = false;
  int _right = 0;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _watch.start();
    _tick = Timer.periodic(
        const Duration(milliseconds: 200), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  void _mark(bool ok) {
    if (ok) _right++;
    if (_idx < widget.items.length - 1) {
      setState(() {
        _idx++;
        _revealed = false;
      });
    } else {
      _watch.stop();
      _tick?.cancel();
      Store.I.setSpeedBestMs(
          widget.slug, widget.group, _watch.elapsedMilliseconds);
      setState(() => _done = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    if (_done) {
      final acc = _right / widget.items.length;
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const Spacer(),
              Entrance(
                child: Text(fmtMs(_watch.elapsedMilliseconds),
                    style: grotesk(700, size: 52, color: c.accent)),
              ),
              const SizedBox(height: 8),
              Entrance(
                delayMs: 60,
                child: Text('$_right of ${widget.items.length} correct',
                    style: inter(600, size: 16, color: c.ink)),
              ),
              const SizedBox(height: 6),
              Entrance(
                delayMs: 100,
                child: Text(
                  _watch.elapsedMilliseconds <= 60000 && acc >= 0.9
                      ? 'Exam-grade speed. Keep it warm daily.'
                      : _watch.elapsedMilliseconds <= 90000
                          ? 'Close. A few more runs and this is automatic.'
                          : 'Reps build the reflex - run it again.',
                  textAlign: TextAlign.center,
                  style: inter(480, size: 13.5, color: c.muted),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (_) => _SpeedSession(
                              slug: widget.slug,
                              group: widget.group,
                              items: widget.items))),
                  child: const Text('Run again'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ),
            ]),
          ),
        ),
      );
    }

    final q = widget.items[_idx];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            Row(children: [
              IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: Icon(LucideIcons.x, size: 20, color: c.muted)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: c.raised,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: c.line),
                ),
                child: Row(children: [
                  Icon(LucideIcons.timer, size: 13, color: c.accent),
                  const SizedBox(width: 6),
                  Text(fmtMs(_watch.elapsedMilliseconds),
                      style: grotesk(650, size: 13.5, color: c.ink)),
                ]),
              ),
            ]),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: (_idx + 1) / widget.items.length,
                minHeight: 4,
                backgroundColor: c.raised,
                color: c.warn,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GestureDetector(
                onTap: _revealed
                    ? null
                    : () => setState(() => _revealed = true),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                        color: _revealed ? c.accent : c.line,
                        width: _revealed ? 1.4 : 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${_idx + 1} / ${widget.items.length}',
                          style: inter(600, size: 12, color: c.muted)),
                      const Spacer(),
                      Text(q.question,
                          textAlign: TextAlign.center,
                          style: grotesk(650, size: 27, color: c.ink)),
                      const SizedBox(height: 18),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: _revealed
                            ? Column(
                                key: const ValueKey('a'),
                                children: [
                                  Text(q.answerText ?? '',
                                      style: grotesk(700,
                                          size: 32, color: c.accent)),
                                  if (q.solution.trim().isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Text(q.solution,
                                        textAlign: TextAlign.center,
                                        style: inter(460,
                                            size: 13,
                                            color: c.muted,
                                            height: 1.4)),
                                  ],
                                ],
                              )
                            : Text('tap to reveal',
                                key: const ValueKey('t'),
                                style:
                                    inter(500, size: 13, color: c.muted)),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_revealed)
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _mark(false),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: c.danger,
                        side: BorderSide(
                            color: c.danger.withValues(alpha: 0.6)),
                        padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Icon(LucideIcons.x, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _mark(true),
                    style: FilledButton.styleFrom(
                        backgroundColor: c.good,
                        padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Icon(LucideIcons.check,
                        size: 20, color: Colors.white),
                  ),
                ),
              ])
            else
              SizedBox(
                height: 52,
                child: Center(
                  child: Text('solve it in your head first',
                      style: inter(500, size: 12.5, color: c.muted)),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}
