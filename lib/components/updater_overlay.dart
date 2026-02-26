import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import '../models/updater_config.dart';

export '../models/updater_config.dart';

class AppUpdaterOverlay extends StatelessComponent {
  const AppUpdaterOverlay({
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
    final isFullscreen = config.type == UpdaterOverlayType.killSwitch || config.type == UpdaterOverlayType.maintenance;

    return div(classes: 'overlay-container', [
      div(
        classes: 'overlay-backdrop',
        events: {'click': (e) => config.isPermanent ? null : onClose()},
        [],
      ),
      div(classes: 'overlay-content-wrapper', [
        if (isFullscreen)
          FullscreenUpdaterOverlay(config: config)
        else
          DialogUpdaterOverlay(
            config: config,
            onClose: onClose,
            onAction: onAction,
          ),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.overlay-container', [
      css('&').styles(
        display: Display.flex,
        position: Position.fixed(top: 0.px, left: 0.px),
        zIndex: ZIndex(9999),
        width: 100.percent,
        height: 100.percent,
        justifyContent: JustifyContent.center,
        alignItems: AlignItems.center,
      ),
    ]),
    css('.overlay-backdrop', [
      css('&').styles(
        position: Position.absolute(top: 0.px, left: 0.px),
        width: 100.percent,
        height: 100.percent,
        backdropFilter: Filter.blur(5.px),
        backgroundColor: Color.rgba(0, 0, 0, 0.3),
      ),
    ]),
    css('.overlay-content-wrapper', [
      css('&').styles(
        display: Display.flex,
        position: Position.relative(),
        zIndex: ZIndex(1),
        width: 100.percent,
        height: 100.percent,
        pointerEvents: PointerEvents.none,
        justifyContent: JustifyContent.center,
        alignItems: AlignItems.center,
      ),
      css('> *').styles(
        pointerEvents: PointerEvents.all,
      ),
    ]),
    ...FullscreenUpdaterOverlay.styles,
    ...DialogUpdaterOverlay.styles,
  ];
}

class FullscreenUpdaterOverlay extends StatelessComponent {
  const FullscreenUpdaterOverlay({required this.config, super.key});

  final UpdaterOverlayConfig config;

  @override
  Component build(BuildContext context) {
    final isKillSwitch = config.type == UpdaterOverlayType.killSwitch;
    final r = isKillSwitch ? 239 : 249;
    final g = isKillSwitch ? 68 : 115;
    final b = isKillSwitch ? 68 : 22;
    final iconText = isKillSwitch ? 'block' : 'construction';

    return div(classes: 'fullscreen-overlay', [
      div(classes: 'icon-circle', styles: Styles(backgroundColor: Color.rgba(r, g, b, 0.1)), [
        i(classes: 'material-icons', styles: Styles(color: Color.rgb(r, g, b)), [Component.text(iconText)]),
      ]),
      h2(styles: Styles(color: Color.rgb(r, g, b)), [Component.text(config.title)]),
      p([Component.text(config.message)]),
      if (config.endTime != null)
        div(
          classes: 'end-time-badge',
          styles: Styles(
            color: Color.rgb(r, g, b),
            backgroundColor: Color.rgba(r, g, b, 0.1),
          ),
          [
            Component.text("Estimated Back By: ${config.endTime}"),
          ],
        ),
    ]);
  }

  static List<StyleRule> get styles => [
    css('.fullscreen-overlay', [
      css('&').styles(
        display: Display.flex,
        width: 100.percent,
        height: 100.percent,
        padding: Padding.all(40.px),
        flexDirection: FlexDirection.column,
        justifyContent: JustifyContent.center,
        alignItems: AlignItems.center,
        textAlign: TextAlign.center,
        backgroundColor: Color.rgb(24, 24, 27),
      ),
      css('.icon-circle', [
        css('&').styles(
          padding: Padding.all(24.px),
          margin: Margin.only(bottom: 32.px),
          radius: BorderRadius.all(Radius.circular(50.percent)),
        ),
        css('i').styles(fontSize: 80.px),
      ]),
      css('h2', [
        css('&').styles(
          margin: Margin.only(bottom: 16.px),
          fontSize: 2.rem,
          fontWeight: FontWeight.bold,
        ),
      ]),
      css('p', [
        css('&').styles(
          fontSize: 1.1.rem,
          color: Color.rgb(161, 161, 170),
          maxWidth: 600.px,
        ),
      ]),
      css('.end-time-badge', [
        css('&').styles(
          margin: Margin.only(top: 24.px),
          padding: Padding.symmetric(horizontal: 16.px, vertical: 8.px),
          radius: BorderRadius.all(Radius.circular(20.px)),
          fontWeight: FontWeight.bold,
          fontSize: 12.px,
        ),
      ]),
    ]),
  ];
}

class DialogUpdaterOverlay extends StatelessComponent {
  const DialogUpdaterOverlay({
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
    int r, g, b;

    switch (config.type) {
      case UpdaterOverlayType.shorebirdPatch:
        if (config.isPermanent) {
          r = 124;
          g = 58;
          b = 237;
        } else {
          r = 79;
          g = 70;
          b = 229;
        }
      case UpdaterOverlayType.forcedUpdate:
      case UpdaterOverlayType.flexibleUpdate:
      default:
        r = 59;
        g = 130;
        b = 246;
    }

    final iconColor = Color.rgb(r, g, b);
    final iconData = config.type == UpdaterOverlayType.shorebirdPatch
        ? (config.isPermanent ? 'bolt' : 'auto_awesome')
        : (config.type == UpdaterOverlayType.forcedUpdate ? 'system_update' : 'update');

    return div(classes: 'dialog-overlay', [
      div(classes: 'dialog-header', [
        div(classes: 'icon-box', styles: Styles(backgroundColor: Color.rgba(r, g, b, 0.1)), [
          i(classes: 'material-icons', styles: Styles(color: iconColor), [Component.text(iconData)]),
        ]),
        div(classes: 'title-column', [
          h3([Component.text(config.title)]),
          if (config.latestVersion != null)
            span(classes: 'version-label', styles: Styles(color: iconColor), [
              Component.text(
                config.type == UpdaterOverlayType.shorebirdPatch
                    ? "Patch #${config.latestVersion}"
                    : "v${config.latestVersion}",
              ),
            ]),
        ]),
      ]),
      p(classes: 'message', [Component.text(config.message)]),
      if (config.currentVersion != null &&
          config.latestVersion != null &&
          config.type != UpdaterOverlayType.shorebirdPatch)
        div(classes: 'version-info', [
          span(classes: 'current', [Component.text(config.currentVersion!)]),
          i(classes: 'material-icons', [Component.text('arrow_forward')]),
          span(classes: 'latest', [Component.text(config.latestVersion!)]),
        ]),
      if (config.releaseNotes?.isNotEmpty ?? false) ...[
        h4([Component.text(config.type == UpdaterOverlayType.shorebirdPatch ? "Changes:" : "What's New:")]),
        div(classes: 'release-notes-box', [
          pre([Component.text(config.releaseNotes!)]),
        ]),
      ],
      div(classes: 'dialog-footer', [
        if (!config.isPermanent) button(classes: 'later-btn', events: {'click': (e) => onClose()}, [Component.text("Later")]),
        div(classes: 'spacer', []),
        button(
          classes: 'action-btn',
          styles: Styles(backgroundColor: iconColor),
          events: {'click': (e) => onAction?.call()},
          [Component.text(config.actionLabel ?? "Update")],
        ),
      ]),
    ]);
  }

  static List<StyleRule> get styles => [
    css('.dialog-overlay', [
      css('&').styles(
        width: 100.percent,
        maxWidth: 400.px,
        backgroundColor: Color.rgb(24, 24, 27),
        radius: BorderRadius.all(Radius.circular(24.px)),
        padding: Padding.all(24.px),
        shadow: BoxShadow(
          offsetX: 0.px,
          offsetY: 10.px,
          blur: 20.px,
          color: Color.rgba(0, 0, 0, 0.4),
        ),
      ),
      css('.dialog-header', [
        css('&').styles(
          display: Display.flex,
          alignItems: AlignItems.center,
          margin: Margin.only(bottom: 20.px),
        ),
        css('.icon-box', [
          css('&').styles(
            display: Display.flex,
            padding: Padding.all(12.px),
            margin: Margin.only(right: 16.px),
            radius: BorderRadius.all(Radius.circular(16.px)),
          ),
          css('i').styles(fontSize: 24.px),
        ]),
        css('.title-column', [
          css('h3').styles(
            margin: Margin.zero,
            fontSize: 18.px,
            fontWeight: FontWeight.bold,
            color: Color.rgba(255, 255, 255, 1.0),
          ),
          css('.version-label').styles(
            fontSize: 12.px,
            fontWeight: FontWeight.w600,
          ),
        ]),
      ]),
      css('.message', [
        css('&').styles(
          color: Color.rgb(161, 161, 170),
          fontSize: 14.px,
          margin: Margin.only(bottom: 20.px),
          lineHeight: Unit.em(1.5),
        ),
      ]),
      css('.version-info', [
        css('&').styles(
          display: Display.inlineFlex,
          alignItems: AlignItems.center,
          backgroundColor: Color.rgba(255, 255, 255, 0.05),
          padding: Padding.symmetric(horizontal: 12.px, vertical: 8.px),
          radius: BorderRadius.all(Radius.circular(12.px)),
          fontSize: 11.px,
          margin: Margin.only(bottom: 20.px),
        ),
        css('.current').styles(color: Color.rgb(113, 113, 122)),
        css('i').styles(
          fontSize: 12.px,
          margin: Margin.symmetric(horizontal: 8.px),
          color: Color.rgb(82, 82, 91),
        ),
        css('.latest').styles(
          color: Color.rgb(59, 130, 246),
          fontWeight: FontWeight.bold,
        ),
      ]),
      css('h4').styles(
        margin: Margin.only(bottom: 8.px),
        fontSize: 14.px,
        fontWeight: FontWeight.bold,
        color: Color.rgba(255, 255, 255, 1.0),
      ),
      css('.release-notes-box', [
        css('&').styles(
          maxHeight: 150.px,
          overflow: Overflow.auto,
          backgroundColor: Color.rgba(255, 255, 255, 0.03),
          padding: Padding.all(12.px),
          radius: BorderRadius.all(Radius.circular(12.px)),
          border: Border.all(color: Color.rgba(255, 255, 255, 0.05)),
          margin: Margin.only(bottom: 32.px),
        ),
        css('pre').styles(
          margin: Margin.zero,
          fontSize: 13.px,
          color: Color.rgb(113, 113, 122),
          whiteSpace: WhiteSpace.preWrap,
          fontFamily: FontFamilies.sansSerif,
          lineHeight: Unit.em(1.5),
        ),
      ]),
      css('.dialog-footer', [
        css('&').styles(
          display: Display.flex,
          alignItems: AlignItems.center,
          justifyContent: JustifyContent.spaceBetween,
        ),
        css('.spacer').styles(flex: Flex(grow: 1)),
        css('.later-btn', [
          css('&').styles(
            backgroundColor: Color.rgba(0, 0, 0, 0),
            border: Border.none,
            color: Color.rgb(113, 113, 122),
            padding: Padding.symmetric(horizontal: 16.px, vertical: 8.px),
            cursor: Cursor.pointer,
            fontSize: 14.px,
          ),
        ]),
        css('.action-btn', [
          css('&').styles(
            border: Border.none,
            color: Color.rgba(255, 255, 255, 1.0),
            padding: Padding.symmetric(horizontal: 24.px, vertical: 12.px),
            radius: BorderRadius.all(Radius.circular(12.px)),
            cursor: Cursor.pointer,
            fontWeight: FontWeight.bold,
            fontSize: 14.px,
            shadow: BoxShadow(
              offsetX: 0.px,
              offsetY: 2.px,
              blur: 4.px,
              color: Color.rgba(0, 0, 0, 0.2),
            ),
          ),
        ]),
      ]),
    ]),
  ];
}
