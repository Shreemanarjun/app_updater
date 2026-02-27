import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'components/header.dart';
import 'components/theme_manager.dart';
import 'pages/home.dart';
import 'pages/generator.dart';
import 'components/embedded_updater_overlay.dart';

class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    return div(
      id: 'app-root',
      classes:
          'flex flex-col h-screen overflow-hidden bg-white dark:bg-zinc-950 text-zinc-900 dark:text-zinc-50 font-sans transition-colors duration-300',
      [
        ThemeManager(),
        const Header(),
        div(classes: 'flex-1 overflow-hidden flex flex-col', [
          Router(
            routes: [
              Route(path: '/', title: 'Home', builder: (context, state) => const HomePage()),
              Route(path: '/config', title: 'Generator', builder: (context, state) => const GeneratorPage()),
            ],
          ),
        ]),
      ],
    );
  }

  @css
  static List<StyleRule> get styles => [
    ...EmbeddedUpdaterOverlay.styles,
    ...Header.styles,
    css('body').styles(
      margin: Margin.zero,
      color: Color('#18181b'),
      fontFamily: FontFamily('Plus Jakarta Sans, Inter, sans-serif'),
      backgroundColor: Color('white'),
    ),
    css('.dark body').styles(
      color: Color('#f4f4f5'),
      backgroundColor: Color('#09090b'),
    ),
    css.import(
      'https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono&display=swap',
    ),
    css.import('https://fonts.googleapis.com/icon?family=Material+Icons'),
  ];
}
