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

    return div(classes: 'fixed inset-0 z-[9999] flex items-center justify-center', [
      // Backdrop
      div(
        classes: 'absolute inset-0 bg-black/30 backdrop-blur-sm',
        events: {'click': (e) => config.isPermanent ? null : onClose()},
        [],
      ),
      // Content wrapper
      div(classes: 'relative z-[1] flex items-center justify-center w-full h-full pointer-events-none', [
        div(classes: 'pointer-events-auto', [
          if (isFullscreen)
            FullscreenUpdaterOverlay(config: config)
          else
            DialogUpdaterOverlay(
              config: config,
              onClose: onClose,
              onAction: onAction,
            ),
        ]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
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
    final colorClass = isKillSwitch ? 'text-red-400' : 'text-orange-500';
    final bgClass = isKillSwitch ? 'bg-red-500/10' : 'bg-orange-500/10';
    final iconText = isKillSwitch ? 'block' : 'construction';

    return div(
      classes: 'flex flex-col items-center justify-center text-center w-screen h-screen bg-zinc-900 px-10',
      [
        div(classes: 'p-6 rounded-full mb-8 $bgClass', [
          i(classes: 'material-icons text-[80px] $colorClass', [Component.text(iconText)]),
        ]),
        h2(classes: 'text-3xl font-bold mb-4 $colorClass', [Component.text(config.title)]),
        p(classes: 'text-zinc-400 text-lg max-w-xl leading-relaxed', [Component.text(config.message)]),
        if (config.endTime != null)
          div(
            classes: 'mt-6 px-4 py-2 rounded-full font-semibold text-xs $colorClass $bgClass',
            [Component.text('Estimated Back By: ${config.endTime}')],
          ),
      ],
    );
  }

  static List<StyleRule> get styles => [];
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
    // Color mappings by type
    String iconColor, iconBg, btnBg, versionLatestColor;
    String iconData;

    switch (config.type) {
      case UpdaterOverlayType.shorebirdPatch:
        if (config.isPermanent) {
          iconColor = 'text-violet-400';
          iconBg = 'bg-violet-500/10';
          btnBg = 'bg-violet-600';
          versionLatestColor = 'text-violet-400';
          iconData = 'bolt';
        } else {
          iconColor = 'text-indigo-400';
          iconBg = 'bg-indigo-500/10';
          btnBg = 'bg-indigo-600';
          versionLatestColor = 'text-indigo-400';
          iconData = 'auto_awesome';
        }
      case UpdaterOverlayType.forcedUpdate:
        iconColor = 'text-blue-400';
        iconBg = 'bg-blue-500/10';
        btnBg = 'bg-blue-600';
        versionLatestColor = 'text-blue-400';
        iconData = 'system_update';
      default:
        iconColor = 'text-blue-400';
        iconBg = 'bg-blue-500/10';
        btnBg = 'bg-blue-600';
        versionLatestColor = 'text-blue-400';
        iconData = 'update';
    }

    return div(
      classes: 'w-full max-w-sm bg-zinc-900 rounded-3xl p-6 shadow-2xl shadow-black/50 border border-white/5',
      [
        // Header: icon + title
        div(classes: 'flex items-center mb-5', [
          div(classes: 'p-3 rounded-2xl mr-4 $iconBg', [
            i(classes: 'material-icons text-2xl $iconColor', [Component.text(iconData)]),
          ]),
          div([
            h3(classes: 'text-white font-bold text-lg m-0 leading-tight', [Component.text(config.title)]),
            if (config.latestVersion != null)
              span(
                classes: 'text-xs font-semibold $iconColor',
                [
                  Component.text(
                    config.type == UpdaterOverlayType.shorebirdPatch
                        ? 'Patch #${config.latestVersion}'
                        : 'v${config.latestVersion}',
                  ),
                ],
              ),
          ]),
        ]),
        // Message
        p(classes: 'text-zinc-400 text-sm leading-relaxed mb-5', [Component.text(config.message)]),
        // Version diff row
        if (config.currentVersion != null &&
            config.latestVersion != null &&
            config.type != UpdaterOverlayType.shorebirdPatch)
          div(
            classes: 'inline-flex items-center gap-2 bg-white/5 px-3 py-2 rounded-xl text-xs mb-5',
            [
              span(classes: 'text-zinc-500', [Component.text(config.currentVersion!)]),
              i(classes: 'material-icons text-xs text-zinc-600', [Component.text('arrow_forward')]),
              span(classes: 'font-bold $versionLatestColor', [Component.text(config.latestVersion!)]),
            ],
          ),
        // Release notes
        if (config.releaseNotes?.isNotEmpty ?? false) ...[
          h4(classes: 'text-white font-bold text-sm mb-2', [
            Component.text(config.type == UpdaterOverlayType.shorebirdPatch ? 'Changes:' : "What's New:"),
          ]),
          div(
            classes: 'max-h-[120px] overflow-auto bg-white/[0.03] border border-white/5 rounded-xl p-3 mb-8',
            [
              pre(
                classes: 'text-zinc-500 text-[13px] whitespace-pre-wrap font-sans leading-relaxed m-0',
                [Component.text(config.releaseNotes!)],
              ),
            ],
          ),
        ],
        // Footer buttons
        div(classes: 'flex items-center justify-between mt-2', [
          if (!config.isPermanent)
            button(
              classes:
                  'text-zinc-500 hover:text-zinc-300 px-4 py-2 text-sm bg-transparent border-0 cursor-pointer transition-colors',
              events: {'click': (e) => onClose()},
              [Component.text('Later')],
            ),
          div(classes: 'flex-1', []),
          button(
            classes:
                '$btnBg text-white font-bold text-sm px-6 py-3 rounded-xl border-0 cursor-pointer shadow-lg shadow-black/20 hover:opacity-90 transition-opacity',
            events: {'click': (e) => onAction?.call()},
            [Component.text(config.actionLabel ?? 'Update')],
          ),
        ]),
      ],
    );
  }

  static List<StyleRule> get styles => [];
}
