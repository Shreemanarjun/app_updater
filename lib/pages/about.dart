import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

@client
class About extends StatelessComponent {
  const About({super.key});

  @override
  Component build(BuildContext context) {
    return section(
      classes: 'flex flex-col items-center justify-center flex-1 px-6 py-16 bg-zinc-950 min-h-0 overflow-auto',
      [
        div(classes: 'max-w-lg w-full', [
          h1(classes: 'text-2xl font-bold text-white mb-8 text-center', [.text('Getting Started')]),
          ol(classes: 'flex flex-col gap-6 list-none p-0 m-0', [
            _card(
              emoji: '📖',
              title: 'Documentation',
              body: [
                .text("Jaspr's "),
                a(
                  href: 'https://docs.jaspr.site',
                  classes: 'text-blue-400 hover:text-blue-300 underline underline-offset-2 transition-colors',
                  [.text('official documentation')],
                ),
                .text(' provides you with all information you need to get started.'),
              ],
            ),
            _card(
              emoji: '💬',
              title: 'Community',
              body: [
                .text('Got stuck? Ask your question on the official '),
                a(
                  href: 'https://discord.gg/XGXrGEk4c6',
                  classes: 'text-indigo-400 hover:text-indigo-300 underline underline-offset-2 transition-colors',
                  [.text('Discord server')],
                ),
                .text(' for the Jaspr community.'),
              ],
            ),
            _card(
              emoji: '📦',
              title: 'Ecosystem',
              body: [
                .text(
                  'Get official packages and integrations like jaspr_router, jaspr_tailwind or jaspr_riverpod. Find packages on pub.dev using the ',
                ),
                a(
                  href: 'https://pub.dev/packages?q=topic%3Ajaspr',
                  classes: 'text-emerald-400 hover:text-emerald-300 underline underline-offset-2 transition-colors',
                  [.text('#jaspr')],
                ),
                .text(' topic, or publish your own.'),
              ],
            ),
            _card(
              emoji: '💙',
              title: 'Support Jaspr',
              body: [
                .text('If you like Jaspr, star us on '),
                a(
                  href: 'https://github.com/schultek/jaspr',
                  classes: 'text-pink-400 hover:text-pink-300 underline underline-offset-2 transition-colors',
                  [.text('GitHub')],
                ),
                .text(' and tell your friends!'),
              ],
            ),
          ]),
        ]),
      ],
    );
  }

  static Component _card({
    required String emoji,
    required String title,
    required List<Component> body,
  }) {
    return li(classes: 'bg-zinc-900 border border-white/5 rounded-2xl p-5 hover:border-white/10 transition-colors', [
      div(classes: 'flex items-center gap-3 mb-2', [
        span(classes: 'text-xl', [.text(emoji)]),
        h3(classes: 'text-white font-semibold text-base m-0', [.text(title)]),
      ]),
      p(classes: 'text-zinc-400 text-sm leading-relaxed m-0', body),
    ]);
  }

  @css
  static List<StyleRule> get styles => [];
}
