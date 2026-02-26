import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

class Header extends StatelessComponent {
  const Header({super.key});

  @override
  Component build(BuildContext context) {
    var activePath = context.url;

    return header(classes: 'flex justify-center px-4 py-3 bg-zinc-950 border-b border-white/5', [
      nav(classes: 'flex items-center gap-1 bg-zinc-900 rounded-xl px-2 py-1.5 shadow-inner', [
        for (var route in [
          (label: 'Home', path: '/'),
          (label: 'About', path: '/about'),
        ])
          Link(
            to: route.path,
            child: span(
              classes: activePath == route.path
                  ? 'px-4 py-1.5 rounded-lg text-sm font-semibold text-white bg-zinc-700 shadow transition-all duration-200'
                  : 'px-4 py-1.5 rounded-lg text-sm font-semibold text-zinc-400 hover:text-white hover:bg-zinc-800 transition-all duration-200',
              [.text(route.label)],
            ),
          ),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [];
}
