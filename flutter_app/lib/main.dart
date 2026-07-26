import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'data.dart';
import 'screens/home.dart';
import 'screens/mocks.dart';
import 'screens/notes.dart';
import 'screens/practice.dart';
import 'store.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Store.init();
  runApp(const BankPrepApp());
}

class BankPrepApp extends StatelessWidget {
  const BankPrepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Store.version,
      builder: (context, _, __) => MaterialApp(
        title: 'BankPrep',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: Store.I.themeMode(),
        home: const _Bootstrap(),
      ),
    );
  }
}

/// Loads the data indexes once, with a branded splash.
class _Bootstrap extends StatefulWidget {
  const _Bootstrap();

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  late final Future<void> _load = Future.wait([
    AppData.instance.practiceIndex(),
    AppData.instance.pyqIndex(),
  ]);

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return FutureBuilder(
      future: _load,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return Scaffold(
            body: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (context, v, child) => Opacity(
                  opacity: v,
                  child: Transform.scale(scale: 0.92 + 0.08 * v, child: child),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: c.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: c.accent, width: 1.4),
                      ),
                      child:
                          Icon(LucideIcons.trendingUp, size: 34, color: c.accent),
                    ),
                    const SizedBox(height: 18),
                    Text('BankPrep', style: grotesk(700, size: 26, color: c.ink)),
                    const SizedBox(height: 6),
                    Text('SBI PO Prelims',
                        style: inter(500, size: 13, color: c.muted, ls: 0.5)),
                  ],
                ),
              ),
            ),
          );
        }
        if (snap.hasError) {
          return Scaffold(
              body: Center(
                  child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Failed to load question data:\n${snap.error}',
                textAlign: TextAlign.center,
                style: inter(500, size: 14, color: c.danger)),
          )));
        }
        return const HomeShell();
      },
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onGoToTab: (i) => setState(() => _tab = i)),
      const PracticeScreen(),
      const MocksScreen(),
      const NotesScreen(),
    ];
    return Scaffold(
      body: SafeArea(
        child: PageTransitionSwitcher(
          duration: const Duration(milliseconds: 260),
          transitionBuilder: (child, primary, secondary) => FadeThroughTransition(
            animation: primary,
            secondaryAnimation: secondary,
            fillColor: Colors.transparent,
            child: child,
          ),
          child: KeyedSubtree(key: ValueKey(_tab), child: pages[_tab]),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(LucideIcons.home), label: 'Home'),
          NavigationDestination(
              icon: Icon(LucideIcons.dumbbell), label: 'Practice'),
          NavigationDestination(
              icon: Icon(LucideIcons.timer), label: 'Mocks'),
          NavigationDestination(
              icon: Icon(LucideIcons.bookOpen), label: 'Notes'),
        ],
      ),
    );
  }
}
