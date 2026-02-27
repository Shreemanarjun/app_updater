import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_flutter_embed/jaspr_flutter_embed.dart';
import 'package:universal_web/web.dart' as web;
import '../models/updater_config.dart';
import '../theme_mode.dart';

@Import.onWeb('../widgets/updater_overlay.dart', show: [#FlutterUpdaterOverlay])
import 'embedded_updater_overlay.imports.dart' deferred as flutter_overlay;

class EmbeddedUpdaterOverlay extends StatelessComponent {
  const EmbeddedUpdaterOverlay({
    required this.config,
    required this.onClose,
    this.onAction,
    this.width = 375,
    this.height = 812,
    super.key,
  });

  final UpdaterOverlayConfig config;
  final VoidCallback onClose;
  final VoidCallback? onAction;
  final double width;
  final double height;

  @override
  Component build(BuildContext context) {
    var themeMode = context.watch(themeProvider);
    bool isDark = switch (themeMode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.auto => kIsWeb ? web.window.matchMedia('(prefers-color-scheme: dark)').matches : true,
    };

    return FlutterEmbedView.deferred(
      classes: 'overlay-view',
      constraints: ViewConstraints(
        minWidth: width,
        minHeight: height,
        maxWidth: width,
        maxHeight: height,
      ),
      loadLibrary: flutter_overlay.loadLibrary(),
      // ── Spinner shown while Flutter initialises — transparent bg so
      // the phone skeleton shows through instead of going black
      loader: div(
        classes: 'absolute inset-0 flex items-center justify-center',
        [
          div(classes: 'flex flex-col items-center gap-3', [
            div(
              classes: 'w-7 h-7 rounded-full border-2 border-zinc-700 border-t-violet-500 animate-spin',
              [],
            ),
            span(
              classes: 'text-zinc-600 text-[10px] font-mono tracking-wider',
              [Component.text('Loading preview…')],
            ),
          ]),
        ],
      ),
      builder: () => flutter_overlay.FlutterUpdaterOverlay(
        config: config,
        onClose: onClose,
        onAction: onAction,
        isDark: isDark,
      ),
    );
  }

  @css
  static List<StyleRule> get styles => [
    // Position overlay to fill phone shell
    css('.overlay-view').styles(
      position: Position.absolute(top: 0.px, left: 0.px),
      zIndex: ZIndex(10),
      width: 100.percent,
      height: 100.percent,
    ),
  ];
}
