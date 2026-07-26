import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../data.dart';
import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';
import 'quiz.dart';
import 'speed.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return FutureBuilder<List<ModuleMeta>>(
      future: AppData.instance.practiceIndex(),
      builder: (context, snap) {
        final all = (snap.data ?? const <ModuleMeta>[])
            .where((m) => m.category != 'mock')
            .toList();
        final filtered = all.where((m) {
          if (_filter == 'all') return true;
          if (_filter == 'strategy') return m.category == 'strategy';
          return m.section == _filter;
        }).toList();

        final categories = ['core', 'volume', 'strategy'];
        final catLabel = {
          'core': 'CORE SETS',
          'volume': 'MORE VOLUME',
          'strategy': 'STRATEGY & TRAPS',
        };

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            Text('Practice', style: grotesk(700, size: 24, color: c.ink)),
            const SizedBox(height: 4),
            Text('${all.fold(0, (a, m) => a + m.count)} questions with solutions and tricks',
                style: inter(480, size: 13, color: c.muted)),
            const SizedBox(height: 14),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final f in [
                    ('all', 'All'),
                    ('quant', 'Quant'),
                    ('reasoning', 'Reasoning'),
                    ('english', 'English'),
                    ('strategy', 'Strategy'),
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
                ],
              ),
            ),
            const SizedBox(height: 16),
            for (final cat in categories) ...[
              if (filtered.any((m) => m.category == cat)) ...[
                Text(catLabel[cat]!,
                    style: inter(700, size: 11, color: c.muted, ls: 1.4)),
                const SizedBox(height: 10),
                for (final (i, m)
                    in filtered.where((m) => m.category == cat).indexed)
                  Entrance(
                    delayMs: (i * 30).clamp(0, 240),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ModuleCard(meta: m),
                    ),
                  ),
                const SizedBox(height: 14),
              ],
            ],
          ],
        );
      },
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final ModuleMeta meta;
  const _ModuleCard({required this.meta});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return ValueListenableBuilder(
      valueListenable: Store.version,
      builder: (context, _, __) {
        final (answered, correct) = Store.I.moduleStats(meta.slug);
        final progress = meta.count == 0 ? 0.0 : answered / meta.count;
        final done = answered >= meta.count && meta.count > 0;

        return OpenContainer(
          transitionDuration: const Duration(milliseconds: 340),
          transitionType: ContainerTransitionType.fadeThrough,
          closedElevation: 0,
          openElevation: 0,
          closedColor: c.surface,
          openColor: c.bg,
          middleColor: c.bg,
          closedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: c.line),
          ),
          openBuilder: (context, _) => meta.kind == 'speed'
              ? SpeedScreen(meta: meta)
              : QuizScreen(meta: meta),
          closedBuilder: (context, open) => InkWell(
            onTap: open,
            onLongPress: answered == 0
                ? null
                : () => showDialog(
                      context: context,
                      builder: (dctx) => AlertDialog(
                        backgroundColor: c.surface,
                        title: Text('Reset progress?',
                            style: inter(650, size: 17, color: c.ink)),
                        content: Text(
                            'Clears your $answered answers in "${meta.title}".',
                            style: inter(450, size: 14, color: c.muted)),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(dctx),
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () {
                                Store.I.resetModule(meta.slug);
                                Navigator.pop(dctx);
                              },
                              child: Text('Reset',
                                  style: TextStyle(color: c.danger))),
                        ],
                      ),
                    ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: sectionColor(meta.section, c)
                            .withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                          meta.kind == 'speed'
                              ? LucideIcons.gauge
                              : sectionIcon(meta.section),
                          size: 18,
                          color: sectionColor(meta.section, c)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(meta.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: inter(620, size: 14.5, color: c.ink)),
                          const SizedBox(height: 3),
                          Row(children: [
                            SectionBadge(meta.section),
                            Text('  ·  ${meta.count} Q',
                                style: inter(500, size: 11.5, color: c.muted)),
                            if (answered > 0)
                              Text(
                                  '  ·  $correct/$answered right',
                                  style: inter(500,
                                      size: 11.5,
                                      color: done ? c.good : c.muted)),
                          ]),
                        ],
                      ),
                    ),
                    if (done)
                      Icon(LucideIcons.checkCircle2, size: 19, color: c.good)
                    else
                      Icon(LucideIcons.chevronRight,
                          size: 18, color: c.muted),
                  ]),
                  if (answered > 0 && !done) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: progress),
                        duration: const Duration(milliseconds: 500),
                        builder: (context, v, _) => LinearProgressIndicator(
                          value: v,
                          minHeight: 4,
                          backgroundColor: c.raised,
                          color: sectionColor(meta.section, c),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
