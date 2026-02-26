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
    return div(classes: 'main', [
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
    ...Header.styles,
    ...GeneratorPage.styles,
    ...EmbeddedUpdaterOverlay.styles,
    css('.main', [
      css('&').styles(
        display: Display.flex,
        height: 100.vh,
        overflow: Overflow.hidden,
        flexDirection: FlexDirection.column,
      ),
    ]),
    css('body').styles(
      margin: Margin.zero,
      fontFamily: FontFamily('Inter'),
    ),
  ];
}
