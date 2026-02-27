import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr_router/jaspr_router.dart';
import '../components/footer.dart';

class HomePage extends StatelessComponent {
  const HomePage({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'flex-1 overflow-y-auto px-6 py-12', [
      div(classes: 'max-w-4xl mx-auto flex flex-col items-center text-center gap-8', [
        h1(classes: 'text-5xl font-extrabold tracking-tight', [
          Component.text('Manage App Updates '),
          span(classes: 'text-blue-500', [Component.text('Like a Pro')]),
        ]),
        p(classes: 'text-lg text-zinc-600 dark:text-zinc-400 max-w-2xl', [
          Component.text(
            'A complete remote configuration dashboard to effortlessly manage app versions, Shorebird patches, Kill Switches, and Maintenance Modes across iOS and Android.',
          ),
        ]),
        Link(
          to: '/config',
          child: button(
            classes:
                'px-8 py-4 bg-blue-600 hover:bg-blue-500 text-white font-bold rounded-xl transition-all shadow-lg hover:shadow-blue-500/25 border-0 cursor-pointer text-lg',
            [Component.text('Get Started')],
          ),
        ),

        // Features Grid
        div(classes: 'grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mt-12 w-full text-left', [
          _featureCard('block', 'Kill Switch', 'Instantly block access to deprecated app versions across all devices.'),
          _featureCard(
            'construction',
            'Maintenance Mode',
            'Show a friendly maintenance screen with custom messages and ETAs.',
          ),
          _featureCard(
            'auto_fix_high',
            'Shorebird Patches',
            'Deploy over-the-air hotfixes and link them to specific app builds.',
          ),
          _featureCard(
            'system_update',
            'Forced Updates',
            'Require users to update from the App Store or Play Store instantly.',
          ),
          _featureCard(
            'update',
            'Flexible Updates',
            'Suggest updates while allowing users to dismiss them until a later date.',
          ),
          _featureCard(
            'code',
            'JSON Generator',
            'Export your configuration to a perfectly formatted JSON payload in one click.',
          ),
        ]),
      ]),
      const Footer(),
    ]);
  }

  Component _featureCard(String icon, String title, String desc) {
    return div(
      classes:
          'flex flex-col gap-4 p-6 bg-gray-50 dark:bg-zinc-900 border border-zinc-200 dark:border-white/5 rounded-2xl shadow-sm hover:shadow-md transition-shadow',
      [
        div(classes: 'w-12 h-12 bg-blue-100 dark:bg-blue-900/30 rounded-xl flex items-center justify-center', [
          i(classes: 'material-icons text-blue-600 dark:text-blue-400', [Component.text(icon)]),
        ]),
        h3(classes: 'text-lg font-bold text-zinc-900 dark:text-white m-0', [Component.text(title)]),
        p(classes: 'text-sm text-zinc-600 dark:text-zinc-400 m-0 leading-relaxed', [Component.text(desc)]),
      ],
    );
  }
}
