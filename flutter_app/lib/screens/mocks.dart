import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../data.dart';
import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';
import 'mock.dart';

class MocksScreen extends StatelessWidget {
  const MocksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return FutureBuilder(
      future: Future.wait([
        AppData.instance.pyqIndex(),
        AppData.instance.practiceIndex(),
      ]),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Center(child: CircularProgressIndicator(color: c.accent));
        }
        final papers = snap.data![0] as List<PyqMeta>;
        final miniMocks = (snap.data![1] as List<ModuleMeta>)
            .where((m) => m.category == 'mock')
            .toList();

        return ValueListenableBuilder(
          valueListenable: Store.version,
          builder: (context, _, __) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            children: [
              Text('Mocks', style: grotesk(700, size: 24, color: c.ink)),
              const SizedBox(height: 4),
              Text('Timed papers with negative marking, like the real thing',
                  style: inter(480, size: 13, color: c.muted)),
              const SizedBox(height: 18),
              Text('REAL PYQ PAPERS',
                  style: inter(700, size: 11, color: c.muted, ls: 1.4)),
              const SizedBox(height: 10),
              for (final (i, p) in papers.indexed)
                Entrance(
                  delayMs: (i * 30).clamp(0, 240),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PaperCard(meta: p),
                  ),
                ),
              const SizedBox(height: 12),
              Text('MINI MOCKS - 30Q MIXED',
                  style: inter(700, size: 11, color: c.muted, ls: 1.4)),
              const SizedBox(height: 10),
              for (final (i, m) in miniMocks.indexed)
                Entrance(
                  delayMs: (i * 40).clamp(0, 160),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _MiniMockCard(meta: m),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PaperCard extends StatelessWidget {
  final PyqMeta meta;
  const _PaperCard({required this.meta});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final attempts = Store.I.mockAttempts(meta.file);
    final best = attempts.isEmpty
        ? null
        : attempts.map((a) => a.score).reduce((a, b) => a > b ? a : b);
    final secs = ['english', 'quant', 'reasoning']
        .where((s) => (meta.sections[s] ?? 0) > 0)
        .map((s) => '${s[0].toUpperCase()}${meta.sections[s]}')
        .join(' · ');

    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _openModeSheet(context, c),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.line),
          ),
          child: Row(children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.violet.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text('${meta.year}'.substring(2),
                  style: grotesk(700, size: 19, color: c.violet)),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SBI PO Prelims ${meta.year}',
                      style: inter(630, size: 15, color: c.ink)),
                  const SizedBox(height: 3),
                  Text('${meta.total} Q  ·  $secs',
                      style: inter(480, size: 12, color: c.muted)),
                ],
              ),
            ),
            if (best != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: c.good.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text('best ${best.toStringAsFixed(best % 1 == 0 ? 0 : 2)}',
                    style: inter(650, size: 11, color: c.good)),
              )
            else
              Icon(LucideIcons.chevronRight, size: 18, color: c.muted),
          ]),
        ),
      ),
    );
  }

  void _openModeSheet(BuildContext context, AppColors c) {
    showModalBottomSheet(
      context: context,
      builder: (bctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SBI PO Prelims ${meta.year}',
                  style: grotesk(650, size: 19, color: c.ink)),
              const SizedBox(height: 4),
              Text('Marks +1 each  ·  negative 0.25  ·  section order E - Q - R',
                  style: inter(470, size: 12.5, color: c.muted)),
              const SizedBox(height: 18),
              _ModeTile(
                icon: LucideIcons.timer,
                color: c.accent,
                title: 'Sectional timed',
                subtitle: '20 minutes per section, locked - the real format',
                onTap: () => _start(context, bctx, timed: true),
              ),
              const SizedBox(height: 10),
              _ModeTile(
                icon: LucideIcons.coffee,
                color: c.violet,
                title: 'Untimed practice',
                subtitle: 'No clock, move freely between sections',
                onTap: () => _start(context, bctx, timed: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _start(BuildContext context, BuildContext sheetCtx,
      {required bool timed}) async {
    final paper = await AppData.instance.paper(meta.file);
    final order = ['english', 'quant', 'reasoning'];
    final sections = <MockSection>[];
    for (final s in order) {
      final qs = paper.questions.where((q) => q.section == s).map((q) {
        final set = q.setId == null ? null : paper.sets[q.setId];
        return MockQ(
          id: q.id,
          section: s,
          context: set?.context,
          question: q.question,
          options: q.options,
          correct: q.correct,
          explanation: q.explanation,
        );
      }).toList();
      if (qs.isNotEmpty) sections.add(MockSection(sectionLabel(s), qs));
    }
    if (!sheetCtx.mounted) return;
    Navigator.pop(sheetCtx);
    if (!context.mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MockScreen(
        config: MockConfig(
          paperId: meta.file,
          title: 'SBI PO ${meta.year}',
          sections: sections,
          secondsPerSection: timed ? 20 * 60 : null,
        ),
      ),
    ));
  }
}

class _MiniMockCard extends StatelessWidget {
  final ModuleMeta meta;
  const _MiniMockCard({required this.meta});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final attempts = Store.I.mockAttempts(meta.slug);
    final best = attempts.isEmpty
        ? null
        : attempts.map((a) => a.score).reduce((a, b) => a > b ? a : b);

    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _start(context),
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
              child: Icon(LucideIcons.shuffle, size: 19, color: c.warn),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meta.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: inter(620, size: 14.5, color: c.ink)),
                  const SizedBox(height: 2),
                  Text('${meta.count} Q mixed  ·  22 min  ·  skip-discipline training',
                      style: inter(460, size: 12, color: c.muted)),
                ],
              ),
            ),
            if (best != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: c.good.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text('best ${best.toStringAsFixed(best % 1 == 0 ? 0 : 2)}',
                    style: inter(650, size: 11, color: c.good)),
              )
            else
              Icon(LucideIcons.chevronRight, size: 18, color: c.muted),
          ]),
        ),
      ),
    );
  }

  Future<void> _start(BuildContext context) async {
    final m = await AppData.instance.module(meta.slug);
    final qs = m.questions.where((q) => q.isMcq).map((q) => MockQ(
          id: q.id,
          section: q.subject ?? 'mixed',
          context: q.context,
          question: q.question,
          options: q.options!,
          correct: q.correct!,
          explanation: q.solution,
          trick: q.trick,
        )).toList();
    if (!context.mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MockScreen(
        config: MockConfig(
          paperId: meta.slug,
          title: meta.title,
          sections: [MockSection('Mixed', qs)],
          secondsPerSection: 22 * 60,
        ),
      ),
    ));
  }
}

class _ModeTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ModeTile(
      {required this.icon,
      required this.color,
      required this.title,
      required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Material(
      color: c.raised,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.line),
          ),
          child: Row(children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: inter(630, size: 14.5, color: c.ink)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: inter(460, size: 12, color: c.muted)),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 17, color: c.muted),
          ]),
        ),
      ),
    );
  }
}
