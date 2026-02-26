import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'components/header.dart';
import 'pages/about.dart';
import 'pages/generator.dart';
import 'components/embedded_updater_overlay.dart';

// The main component of your application.
class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'flex flex-col h-screen overflow-hidden bg-zinc-950 text-white font-inter', [
      const Header(),
      Router(
        routes: [
          Route(path: '/', title: 'App Updater Generator', builder: (context, state) => const GeneratorPage()),
          Route(path: '/about', title: 'About', builder: (context, state) => const About()),
        ],
      ),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    ...EmbeddedUpdaterOverlay.styles,
    css('body').styles(
      fontFamily: FontFamily('Inter, sans-serif'),
    ),
  ];
}
