import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../data.dart';
import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';
import 'quiz.dart';
import 'speed.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int tab) onGoToTab;
  const HomeScreen({super.key, required this.onGoToTab});

  static final DateTime examDay = DateTime(2026, 8, 1);

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return FutureBuilder<List<ModuleMeta>>(
      future: AppData.instance.practiceIndex(),
      builder: (context, snap) {
        final modules = snap.data ?? const <ModuleMeta>[];
        return ValueListenableBuilder(
          valueListenable: Store.version,
          builder: (context, _, __) {
            // aggregate stats
            var attempted = 0, correct = 0, total = 0;
            final bySection = <String, (int answered, int total)>{};
            for (final m in modules) {
              if (m.category == 'mock') continue;
              final (a, cc) = Store.I.moduleStats(m.slug);
              attempted += a;
              correct += cc;
              total += m.count;
              final key = m.section == 'mixed' ? 'quant' : m.section;
              final cur = bySection[key] ?? (0, 0);
              bySection[key] = (cur.$1 + a, cur.$2 + m.count);
            }
            final acc = attempted == 0 ? 0.0 : correct / attempted;
            final now = DateTime.now();
            final daysLeft = examDay.difference(now).inDays;
            final last = Store.I.lastQuiz();

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                // header
                Entrance(
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('BankPrep',
                              style: grotesk(700, size: 27, color: c.ink)),
                          const SizedBox(height: 2),
                          Text('SBI PO Prelims grind',
                              style: inter(500, size: 13, color: c.muted)),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          final cur = Store.I.themeMode();
                          Store.I.setThemeMode(cur == ThemeMode.dark
                              ? ThemeMode.light
                              : ThemeMode.dark);
                        },
                        icon: Icon(
                            Theme.of(context).brightness == Brightness.dark
                                ? LucideIcons.sun
                                : LucideIcons.moon,
                            size: 20,
                            color: c.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // exam countdown
                Entrance(
                  delayMs: 40,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          c.accent.withValues(alpha: 0.14),
                          c.violet.withValues(alpha: 0.10),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: c.accent.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Icon(LucideIcons.calendar,
                                    size: 14, color: c.accent),
                                const SizedBox(width: 6),
                                Text('SBI PO PRELIMS',
                                    style: inter(700,
                                        size: 10.5, color: c.accent, ls: 1.2)),
                              ]),
                              const SizedBox(height: 8),
                              Text(
                                daysLeft > 1
                                    ? '$daysLeft days to go'
                                    : daysLeft == 1
                                        ? 'Tomorrow. Lock in.'
                                        : daysLeft == 0
                                            ? 'Exam day. You got this.'
                                            : 'Exam done - review mode',
                                style: grotesk(700, size: 23, color: c.ink),
                              ),
                              const SizedBox(height: 4),
                              Text('1 August - E20 R20 Q20 sectional timers',
                                  style:
                                      inter(480, size: 12.5, color: c.muted)),
                            ],
                          ),
                        ),
                        if (daysLeft >= 0)
                          ProgressRing(
                            value: attempted == 0 ? 0.02 : acc,
                            size: 62,
                            stroke: 6,
                            center: Text(
                                attempted == 0
                                    ? '-'
                                    : '${(acc * 100).round()}%',
                                style: grotesk(700, size: 15, color: c.ink)),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // stats
                Entrance(
                  delayMs: 80,
                  child: Row(children: [
                    Expanded(
                        child: StatTile(
                            icon: LucideIcons.listChecks,
                            label: 'Attempted',
                            value: '$attempted')),
                    const SizedBox(width: 10),
                    Expanded(
                        child: StatTile(
                            icon: LucideIcons.check,
                            label: 'Correct',
                            value: '$correct',
                            tint: c.good)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: StatTile(
                            icon: LucideIcons.target,
                            label: 'Bank size',
                            value: '$total',
                            tint: c.violet)),
                  ]),
                ),
                const SizedBox(height: 20),

                // continue
                if (last != null) ...[
                  Entrance(
                    delayMs: 120,
                    child: _ActionCard(
                      icon: LucideIcons.play,
                      iconColor: c.accent,
                      title: 'Continue: ${last.title}',
                      subtitle: 'Pick up where you left off',
                      onTap: () async {
                        final idx = await AppData.instance.practiceIndex();
                        final meta =
                            idx.where((m) => m.slug == last.slug).firstOrNull;
                        if (meta != null && context.mounted) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => meta.kind == 'speed'
                                  ? SpeedScreen(meta: meta)
                                  : QuizScreen(meta: meta)));
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // sections
                Entrance(
                  delayMs: 150,
                  child: Text('SECTIONS',
                      style: inter(700, size: 11, color: c.muted, ls: 1.4)),
                ),
                const SizedBox(height: 10),
                for (final (i, sec) in ['english', 'reasoning', 'quant'].indexed)
                  Entrance(
                    delayMs: 180 + i * 40,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _SectionRow(
                        section: sec,
                        answered: bySection[sec]?.$1 ?? 0,
                        total: bySection[sec]?.$2 ?? 0,
                        onTap: () => onGoToTab(1),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),

                // quick actions
                Entrance(
                  delayMs: 300,
                  child: Text('QUICK',
                      style: inter(700, size: 11, color: c.muted, ls: 1.4)),
                ),
                const SizedBox(height: 10),
                Entrance(
                  delayMs: 330,
                  child: _ActionCard(
                    icon: LucideIcons.gauge,
                    iconColor: c.warn,
                    title: 'Speed drill warm-up',
                    subtitle: '20 rapid calcs - target under 60 seconds',
                    onTap: () async {
                      final idx = await AppData.instance.practiceIndex();
                      final meta = idx
                          .where((m) => m.kind == 'speed')
                          .firstOrNull;
                      if (meta != null && context.mounted) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => SpeedScreen(meta: meta)));
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Entrance(
                  delayMs: 360,
                  child: _ActionCard(
                    icon: LucideIcons.timer,
                    iconColor: c.violet,
                    title: 'Take a mock',
                    subtitle: '11 real PYQ papers + 3 mini mocks, timed',
                    onTap: () => onGoToTab(2),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SectionRow extends StatelessWidget {
  final String section;
  final int answered;
  final int total;
  final VoidCallback onTap;
  const _SectionRow(
      {required this.section,
      required this.answered,
      required this.total,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final color = sectionColor(section, c);
    final v = total == 0 ? 0.0 : answered / total;
    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.line),
          ),
          child: Row(children: [
            ProgressRing(
              value: v,
              size: 46,
              stroke: 5,
              color: color,
              center: Icon(sectionIcon(section), size: 17, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sectionLabel(section),
                      style: inter(630, size: 15.5, color: c.ink)),
                  const SizedBox(height: 3),
                  Text('$answered of $total attempted',
                      style: inter(460, size: 12.5, color: c.muted)),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 18, color: c.muted),
          ]),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ActionCard(
      {required this.icon,
      required this.iconColor,
      required this.title,
      required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
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
                color: iconColor.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: inter(620, size: 14.5, color: c.ink)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: inter(460, size: 12, color: c.muted)),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 18, color: c.muted),
          ]),
        ),
      ),
    );
  }
}
