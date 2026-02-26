import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_flutter_embed/jaspr_flutter_embed.dart';
import '../models/updater_config.dart';

@Import.onWeb('../widgets/updater_overlay.dart', show: [#FlutterUpdaterOverlay])
import 'embedded_updater_overlay.imports.dart' deferred as flutter_overlay;

class EmbeddedUpdaterOverlay extends StatelessComponent {
  const EmbeddedUpdaterOverlay({
    required this.config,
    required this.onClose,
    this.onAction,
    super.key,
  });

  final UpdaterOverlayConfig config;
  final VoidCallback onClose;
  final VoidCallback? onAction;

  @override
  Component build(BuildContext context) {
    return FlutterEmbedView.deferred(
      classes: 'overlay-view',
      constraints: ViewConstraints(
        minWidth: 320,
        minHeight: 600,
        maxWidth: double.infinity,
        maxHeight: double.infinity,
      ),
      loadLibrary: flutter_overlay.loadLibrary(),
      builder: () => flutter_overlay.FlutterUpdaterOverlay(
        config: config,
        onClose: onClose,
        onAction: onAction,
      ),
    );
  }

  @css
  static List<StyleRule> get styles => [
    css('.overlay-view', [
      css('&').styles(
        position: Position.absolute(top: 0.px, left: 0.px),
        zIndex: ZIndex(10),
        width: 100.percent,
        height: 100.percent,
      ),
    ]),
  ];
}
