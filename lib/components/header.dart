import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'theme_toggle.dart';

class Header extends StatelessComponent {
  const Header({super.key});

  @override
  Component build(BuildContext context) {
    var activePath = context.url;

    return header(
      classes:
          'flex justify-between items-center px-4 py-3 bg-white dark:bg-zinc-950 border-b border-zinc-200 dark:border-white/5',
      [
        div(classes: 'w-9', []), // Empty div to keep nav centered or space evenly
        nav(classes: 'flex items-center gap-1 bg-zinc-100 dark:bg-zinc-900 rounded-xl px-2 py-1.5 shadow-inner', [
          for (var route in [
            (label: 'Home', path: '/'),
            (label: 'Generator', path: '/config'),
          ])
            Link(
              to: route.path,
              child: span(
                classes: activePath == route.path
                    ? 'px-4 py-1.5 rounded-lg text-sm font-semibold text-zinc-900 dark:text-white bg-zinc-200 dark:bg-zinc-700 shadow transition-all duration-200'
                    : 'px-4 py-1.5 rounded-lg text-sm font-semibold text-zinc-600 dark:text-zinc-400 hover:text-zinc-900 dark:text-white hover:bg-zinc-100 dark:bg-zinc-800 transition-all duration-200',
                [.text(route.label)],
              ),
            ),
        ]),
        // Right Side actions
        div(classes: 'flex items-center', [
          const EnhancedThemeToggle(),
        ]),
      ],
    );
  }

  @css
  static List<StyleRule> get styles => [
    ...EnhancedThemeToggle.styles,
  ];
}
