import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import '../theme_mode.dart' as tm;

/// A client-side component that manages the application's theme state.
@client
class ThemeManager extends StatelessComponent {
  const ThemeManager({super.key});

  @override
  Component build(BuildContext context) {
    final themeMode = context.watch(tm.themeProvider);

    if (kIsWeb) {
      final isDark = switch (themeMode) {
        tm.ThemeMode.auto => web.window.matchMedia('(prefers-color-scheme: dark)').matches,
        tm.ThemeMode.dark => true,
        tm.ThemeMode.light => false,
      };

      final html = web.document.documentElement;
      if (html != null) {
        html.classList.toggle('dark', isDark);
        html.setAttribute('data-theme', isDark ? 'dark' : 'light');
      }
    }

    return Component.fragment([]);
  }
}
