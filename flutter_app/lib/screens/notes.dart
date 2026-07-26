import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data.dart';
import '../md.dart';
import '../theme.dart';
import '../widgets.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  static const _icons = [
    LucideIcons.brainCircuit,
    LucideIcons.sigma,
    LucideIcons.bookOpen,
    LucideIcons.zap,
    LucideIcons.zap,
    LucideIcons.map,
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Text('Notes', style: grotesk(700, size: 24, color: c.ink)),
        const SizedBox(height: 4),
        Text('Every method and trick from the grind sessions',
            style: inter(480, size: 13, color: c.muted)),
        const SizedBox(height: 16),
        for (final (i, n) in noteFiles.indexed)
          Entrance(
            delayMs: i * 40,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: c.surface,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          NoteScreen(title: n.$2, file: n.$1))),
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
                          color: c.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Icon(_icons[i % _icons.length],
                            size: 19, color: c.accent),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n.$2,
                                style: inter(620, size: 14.5, color: c.ink)),
                            const SizedBox(height: 2),
                            Text(n.$3,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: inter(460, size: 12, color: c.muted)),
                          ],
                        ),
                      ),
                      Icon(LucideIcons.chevronRight,
                          size: 18, color: c.muted),
                    ]),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class NoteScreen extends StatelessWidget {
  final String title;
  final String file;
  const NoteScreen({super.key, required this.title, required this.file});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(LucideIcons.chevronLeft, size: 21)),
      ),
      body: FutureBuilder<String>(
        future: AppData.instance.note(file),
        builder: (context, snap) {
          if (!snap.hasData) {
            return Center(child: CircularProgressIndicator(color: c.accent));
          }
          return SelectionArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: MdText(snap.data!,
                  baseStyle:
                      inter(450, size: 14.5, color: c.ink, height: 1.55)),
            ),
          );
        },
      ),
    );
  }
}
