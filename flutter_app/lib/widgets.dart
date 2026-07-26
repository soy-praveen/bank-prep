/// Shared UI components: rings, tiles, option cards, entrance animations.
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'md.dart';
import 'theme.dart';

/// One-shot entrance: fade + rise. Used for staggered list/cards.
class Entrance extends StatefulWidget {
  final Widget child;
  final int delayMs;
  const Entrance({super.key, required this.child, this.delayMs = 0});

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 340));
  late final Animation<double> _a =
      CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _a,
        builder: (context, child) => Opacity(
          opacity: _a.value,
          child: Transform.translate(
              offset: Offset(0, 14 * (1 - _a.value)), child: child),
        ),
        child: widget.child,
      );
}

/// Animated circular progress ring with center content.
class ProgressRing extends StatelessWidget {
  final double value; // 0..1
  final double size;
  final double stroke;
  final Color? color;
  final Widget? center;

  const ProgressRing({
    super.key,
    required this.value,
    this.size = 64,
    this.stroke = 6,
    this.color,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0, 1)),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size.square(size),
              painter: _RingPainter(
                  v, color ?? c.accent, c.line.withValues(alpha: 0.6), stroke),
            ),
            if (center != null) center!,
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double v;
  final Color color;
  final Color track;
  final double stroke;
  _RingPainter(this.v, this.color, this.track, this.stroke);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final r = (size.width - stroke) / 2;
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(center, r, trackPaint);
    if (v > 0) {
      final p = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke;
      canvas.drawArc(Rect.fromCircle(center: center, radius: r), -math.pi / 2,
          2 * math.pi * v, false, p);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.v != v || old.color != color || old.stroke != stroke;
}

/// Small statistic tile.
class StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? tint;
  const StatTile(
      {super.key,
      required this.icon,
      required this.label,
      required this.value,
      this.tint});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: tint ?? c.accent),
          const SizedBox(height: 8),
          Text(value, style: grotesk(700, size: 21, color: c.ink)),
          const SizedBox(height: 2),
          Text(label, style: inter(550, size: 11.5, color: c.muted)),
        ],
      ),
    );
  }
}

/// Colored dot + label for a section.
class SectionBadge extends StatelessWidget {
  final String section;
  const SectionBadge(this.section, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final color = sectionColor(section, c);
    final label = switch (section) {
      'quant' => 'Quant',
      'reasoning' => 'Reasoning',
      'english' => 'English',
      'mixed' => 'Mixed',
      _ => section,
    };
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label, style: inter(600, size: 11.5, color: c.muted, ls: 0.3)),
    ]);
  }
}

Color sectionColor(String section, AppColors c) => switch (section) {
      'quant' => c.accent,
      'reasoning' => c.violet,
      'english' => c.warn,
      _ => c.muted,
    };

IconData sectionIcon(String section) => switch (section) {
      'quant' => LucideIcons.sigma,
      'reasoning' => LucideIcons.brainCircuit,
      'english' => LucideIcons.bookOpen,
      'mixed' => LucideIcons.shuffle,
      _ => LucideIcons.circle,
    };

/// Answer option state for the quiz player.
enum OptionState { idle, selected, correct, wrong, dimmed }

class OptionTile extends StatelessWidget {
  final String letter;
  final String text;
  final OptionState state;
  final VoidCallback? onTap;

  const OptionTile({
    super.key,
    required this.letter,
    required this.text,
    required this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final (bg, border, chipBg, chipFg, fg) = switch (state) {
      OptionState.correct => (
          c.good.withValues(alpha: 0.12),
          c.good,
          c.good,
          Colors.white,
          c.ink
        ),
      OptionState.wrong => (
          c.danger.withValues(alpha: 0.10),
          c.danger,
          c.danger,
          Colors.white,
          c.ink
        ),
      OptionState.selected => (
          c.accent.withValues(alpha: 0.10),
          c.accent,
          c.accent,
          Colors.black,
          c.ink
        ),
      OptionState.dimmed => (
          c.surface,
          c.line,
          c.raised,
          c.muted,
          c.muted
        ),
      _ => (c.surface, c.line, c.raised, c.muted, c.ink),
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: border,
            width: state == OptionState.idle || state == OptionState.dimmed
                ? 1
                : 1.6),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration:
                      BoxDecoration(color: chipBg, shape: BoxShape.circle),
                  child: state == OptionState.correct
                      ? const Icon(LucideIcons.check, size: 15, color: Colors.white)
                      : state == OptionState.wrong
                          ? const Icon(LucideIcons.x, size: 15, color: Colors.white)
                          : Text(letter,
                              style: inter(650, size: 12.5, color: chipFg)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(text,
                        style: inter(480, size: 14.5, color: fg, height: 1.35)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Trick callout with a zap icon and teal accent border.
class TrickCard extends StatelessWidget {
  final String text;
  const TrickCard(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: c.accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: c.accent, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(LucideIcons.zap, size: 14, color: c.accent),
            const SizedBox(width: 6),
            Text('TRICK', style: inter(700, size: 10.5, color: c.accent, ls: 1.2)),
          ]),
          const SizedBox(height: 6),
          MdText(text,
              baseStyle: inter(460, size: 13.5, color: c.ink, height: 1.45)),
        ],
      ),
    );
  }
}

/// Collapsible shared-context card (passage / DI data / puzzle clues).
class ContextCard extends StatefulWidget {
  final String markdown;
  final bool initiallyOpen;
  const ContextCard(this.markdown, {super.key, this.initiallyOpen = true});

  @override
  State<ContextCard> createState() => _ContextCardState();
}

class _ContextCardState extends State<ContextCard> {
  late bool open = widget.initiallyOpen;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      decoration: BoxDecoration(
        color: c.raised,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => open = !open),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 11, 12, 11),
              child: Row(children: [
                Icon(LucideIcons.scrollText, size: 15, color: c.accent),
                const SizedBox(width: 8),
                Text('PASSAGE / DATA',
                    style: inter(700, size: 10.5, color: c.muted, ls: 1.2)),
                const Spacer(),
                AnimatedRotation(
                  turns: open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 220),
                  child: Icon(LucideIcons.chevronDown, size: 17, color: c.muted),
                ),
              ]),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: open
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: MdText(widget.markdown,
                        baseStyle:
                            inter(450, size: 13.5, color: c.ink, height: 1.5)),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

String fmtClock(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

String fmtMs(int ms) {
  final s = ms / 1000;
  return '${s.toStringAsFixed(1)}s';
}
