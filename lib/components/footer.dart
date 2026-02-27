import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'jaspr_badge.dart';

class Footer extends StatelessComponent {
  const Footer({super.key});

  @override
  Component build(BuildContext context) {
    return footer(
      classes: 'w-full py-12 border-t border-zinc-200 dark:border-white/5 mt-20 bg-white dark:bg-zinc-950',
      [
        div(classes: 'max-w-screen-2xl mx-auto px-4 sm:px-6 lg:px-8', [
          div(classes: 'flex flex-col md:flex-row items-center justify-between gap-6', [
            // Left side: Version and Badge
            div(classes: 'flex flex-col items-center md:items-start gap-4', [
              div(
                classes:
                    'inline-flex items-center gap-2 px-3 py-1 rounded-full bg-blue-500/10 border border-blue-500/20 text-blue-600 dark:text-blue-400 text-xs font-bold tracking-tight',
                [
                  span([Component.text('v1.0.0')]),
                  div(classes: 'w-1 h-1 rounded-full bg-blue-500', []),
                  span([Component.text('Latest Release')]),
                ],
              ),
              div(classes: 'flex items-center gap-2', [
                const BuiltWithJasprBadge.darkTwoTone(),
              ]),
            ]),

            // Center/Right: Copyright and Credits
            div(classes: 'flex flex-col items-center md:items-end gap-2 text-sm text-zinc-500 dark:text-zinc-400', [
              p(classes: 'font-medium', [
                Component.text('© 2026 Shreeman Arjun Sahu. All rights reserved.'),
              ]),
              p(classes: 'flex items-center gap-1.5', [
                Component.text('Made with '),
                span(classes: 'text-red-500 animate-pulse', [Component.text('❤️')]),
                Component.text(' and '),
                a(
                  href: 'https://jaspr.site',
                  classes: 'text-zinc-900 dark:text-white font-semibold hover:text-blue-600 transition-colors',
                  [Component.text('Jaspr')],
                ),
              ]),
            ]),
          ]),
        ]),
      ],
    );
  }
}
