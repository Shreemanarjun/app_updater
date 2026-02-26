import 'dart:convert';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import '../models/app_updater_model.dart';
import '../models/updater_config.dart';
import '../components/embedded_updater_overlay.dart';

class GeneratorPage extends StatefulComponent {
  const GeneratorPage({super.key});

  @override
  State<GeneratorPage> createState() => _GeneratorPageState();

  @css
  static List<StyleRule> get styles => [
    ...EmbeddedUpdaterOverlay.styles,
    css('.generator-layout', [
      css('&').styles(
        display: Display.flex,
        height: Unit.vh(90),
        backgroundColor: Color.rgb(9, 9, 11),
      ),
    ]),
    css('.editor-pane', [
      css('&').styles(
        display: Display.flex,
        flexDirection: FlexDirection.column,
        flex: Flex(grow: 1),
        backgroundColor: Color.rgb(12, 12, 14),
      ),
    ]),
    css('.preview-pane', [
      css('&').styles(
        display: Display.flex,
        width: 50.percent,
        flexDirection: FlexDirection.column,
      ),
    ]),
    css('.editor-container', [
      css('&').styles(
        display: Display.flex,
        position: Position.relative(),
        flex: Flex(grow: 1),
      ),
      css('textarea', [
        css('&').styles(
          width: 100.percent,
          backgroundColor: Color.rgba(0, 0, 0, 0),
          color: Color.rgb(212, 212, 216),
          padding: Padding.all(20.px),
          fontFamily: FontFamilies.sansSerif,
        ),
        css('&.has-error').styles(
          backgroundColor: Color.rgba(239, 68, 68, 0.1),
        ),
      ]),
    ]),
    css('.phone-mockup', [
      css('&').styles(
        position: Position.relative(),
        width: 320.px,
        height: 600.px,
        radius: BorderRadius.all(Radius.circular(40.px)),
        overflow: Overflow.hidden,
        backgroundColor: Color.rgb(24, 24, 27),
      ),
    ]),
    css('.pane-header', [
      css('&').styles(
        display: Display.flex,
        padding: Padding.all(16.px),
        border: Border.only(bottom: BorderSide(color: Color.rgba(255, 255, 255, 0.05))),
        justifyContent: JustifyContent.spaceBetween,
        alignItems: AlignItems.center,
      ),
      css('h2').styles(
        margin: Margin.zero,
        color: Color.rgba(255, 255, 255, 1.0),
        fontSize: 16.px,
      ),
    ]),
    css('.preview-controls', [
      css('&').styles(
        display: Display.flex,
        gap: Gap.all(10.px),
      ),
    ]),
  ];
}

class _GeneratorPageState extends State<GeneratorPage> {
  String jsonContent = '';
  AppUpdaterModel? model;
  String error = '';
  String activePlatform = 'android';
  int currentBuild = 7;
  String currentVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    jsonContent = const JsonEncoder.withIndent('  ').convert(_defaultJson);
    try {
      final decoded = json.decode(jsonContent);
      model = AppUpdaterModel.fromJson(decoded);
      error = '';
    } catch (e) {
      error = e.toString();
    }
  }

  void _parseJson(String value) {
    try {
      final decoded = json.decode(value);
      setState(() {
        model = AppUpdaterModel.fromJson(decoded);
        error = '';
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  UpdaterOverlayConfig? _calculateOverlay() {
    if (model == null) return null;

    final config = model!;
    final platformConfig = activePlatform == 'android' ? config.android : config.ios;
    const locale = 'en';

    if (config.global.killSwitch) {
      return UpdaterOverlayConfig.killSwitch(
        message: "This application version is no longer supported. Please contact support.",
      );
    }

    if (config.global.maintenance.active) {
      return UpdaterOverlayConfig.maintenance(
        message:
            config.global.maintenance.message[locale] ??
            config.global.maintenance.message['en'] ??
            "We are currently performing scheduled maintenance.",
        endTime: config.global.maintenance.endTime,
      );
    }

    final platformPatch = platformConfig.patch;
    if (currentBuild >= platformPatch.minAppBuild && currentBuild <= platformPatch.maxAppBuild) {
      return UpdaterOverlayConfig.shorebird(
        patchNotes: platformPatch.notes,
        isHotfix: platformPatch.hotfix,
        patchNumber: platformPatch.number,
      );
    } else if (currentBuild < platformConfig.update.forceBelowBuild) {
      return UpdaterOverlayConfig.update(
        isForced: true,
        storeUrl: platformConfig.storeUrl,
        releaseNotes: config.global.releaseNotes[locale] ?? config.global.releaseNotes['en'] ?? "",
        currentVersion: currentVersion,
        latestVersion: platformConfig.version.latest.semver,
      );
    } else if (currentBuild < platformConfig.update.flexibleBelowBuild) {
      return UpdaterOverlayConfig.update(
        isForced: false,
        storeUrl: platformConfig.storeUrl,
        releaseNotes: config.global.releaseNotes[locale] ?? config.global.releaseNotes['en'] ?? "",
        currentVersion: currentVersion,
        latestVersion: platformConfig.version.latest.semver,
      );
    }

    return null;
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'generator-layout', [
      div(classes: 'editor-pane', [
        div(classes: 'pane-header', [
          h2([Component.text('Configuration JSON')]),
          button(
            classes: 'icon-btn',
            events: {
              'click': (e) {
                try {
                  final decoded = json.decode(jsonContent);
                  setState(() {
                    jsonContent = const JsonEncoder.withIndent('  ').convert(decoded);
                  });
                } catch (_) {}
              },
            },
            [
              i(classes: 'material-icons', [Component.text('format_indent_increase')]),
              Component.text('Format'),
            ],
          ),
        ]),
        div(classes: 'editor-container', [
          textarea(
            classes: error.isEmpty ? '' : 'has-error',
            events: {
              'input': (e) {
                final value = (e.target as dynamic).value;
                setState(() => jsonContent = value);
                _parseJson(value);
              },
            },
            [Component.text(jsonContent)],
          ),
          if (error.isNotEmpty) div(classes: 'error-banner', [Component.text('JSON Error: $error')]),
        ]),
      ]),
      div(classes: 'preview-pane', [
        div(classes: 'pane-header', [
          h2([Component.text('Device Preview')]),
          div(classes: 'preview-controls', [
            div(classes: 'segmented-control', [
              button(
                classes: activePlatform == 'android' ? 'active' : '',
                events: {'click': (e) => setState(() => activePlatform = 'android')},
                [Component.text('Android')],
              ),
              button(
                classes: activePlatform == 'ios' ? 'active' : '',
                events: {'click': (e) => setState(() => activePlatform = 'ios')},
                [Component.text('iOS')],
              ),
            ]),
            div(classes: 'input-group', [
              label([Component.text('Build:')]),
              input(
                type: InputType.number,
                value: '$currentBuild',
                events: {
                  'input': (e) {
                    setState(() => currentBuild = int.parse((e.target as dynamic).value));
                  },
                },
              ),
            ]),
          ]),
        ]),
        div(classes: 'preview-container', [
          div(classes: 'phone-mockup', [
            div(classes: 'app-content', [
              div(classes: 'mock-app-shell', [
                div(classes: 'mock-app-header', [
                  h1([Component.text('Panha App')]),
                ]),
                div(classes: 'mock-app-body', [
                  div(classes: 'card', []),
                  div(classes: 'card', []),
                ]),
              ]),
              if (_calculateOverlay() != null)
                EmbeddedUpdaterOverlay(
                  key: ValueKey('${activePlatform}_$currentBuild'),
                  config: _calculateOverlay()!,
                  onClose: () {},
                ),
            ]),
          ]),
        ]),
      ]),
    ]);
  }
}

const _defaultJson = {
  "android": {
    "version": {
      "min": {"semver": "1.0.0", "build": 7},
      "recommended": {"semver": "1.7.0", "build": 7},
      "latest": {"semver": "1.7.0", "build": 7},
    },
    "patch": {
      "number": 4,
      "min_app_build": 7,
      "max_app_build": 7,
      "hotfix": false,
      "notes": "Critical bug fix for login issues.",
    },
    "update": {"force_below_build": 6, "flexible_below_build": 250},
    "store_url": "https://play.google.com/store/apps/details?id=app.example",
  },
  "ios": {
    "version": {
      "min": {"semver": "1.0.0", "build": 7},
      "recommended": {"semver": "1.0.0", "build": 7},
      "latest": {"semver": "1.0.0", "build": 7},
    },
    "patch": {
      "number": 1,
      "min_app_build": 7,
      "max_app_build": 7,
      "hotfix": false,
      "notes": "Performance optimizations.",
    },
    "update": {"force_below_build": 6, "flexible_below_build": 7},
    "store_url": "https://apps.apple.com/app/id000000000",
  },
  "global": {
    "kill_switch": false,
    "maintenance": {
      "active": false,
      "message": {"en": "Under maintenance, try again later.", "es": "En mantenimiento, inténtalo más tarde."},
      "end_time": "12:00 PM",
    },
    "release_notes": {
      "en": "- Performance improvements\n- Bug fixes\n- New UI features",
      "es": "- Mejoras de rendimiento\n- Corrección de errores",
    },
  },
};
