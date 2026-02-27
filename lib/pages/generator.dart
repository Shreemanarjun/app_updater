import 'dart:convert';
import 'package:universal_web/web.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import '../models/app_updater_model.dart';
import '../models/updater_config.dart';
import '../components/embedded_updater_overlay.dart';

@client
class GeneratorPage extends StatefulComponent {
  const GeneratorPage({super.key});

  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  // ── UI state
  String _tab = 'global'; // 'global', 'android', 'ios'
  String _platform = 'android'; // Preview platform
  int _build = 7;
  int _patch = 0;

  // ── Preview dimensions (phone shell + Flutter canvas)
  double _previewWidth = 375;
  double _previewHeight = 812;

  // ── JSON paste state
  bool _showJsonModal = false;
  String _jsonDraft = '';
  String _jsonError = '';

  // ── Generate JSON modal state
  bool _showGenerateModal = false;
  bool _copied = false;

  // ── The parsed model (always up to date)
  AppUpdaterModel _model = AppUpdaterModel.fromJson(_kDefaultJson);

  // ── Form field controllers (plain strings/bools updated by events)
  // Global
  bool _killSwitch = false;
  bool _maintenanceActive = false;
  String _maintenanceMsg = 'Under maintenance, try again later.';
  String _maintenanceEndTime = '12:00 PM';
  String _releaseNotes = '- Performance improvements\n- Bug fixes\n- New UI features';

  // Android
  String _andLatestSemver = '1.7.0';
  int _andLatestBuild = 7;
  String _andMinSemver = '1.0.0';
  int _andMinBuild = 7;
  int _andPatchNumber = 4;
  int _andPatchMin = 7;
  int _andPatchMax = 7;
  bool _andPatchHotfix = false;
  String _andPatchNotes = 'Critical bug fix for login issues.';
  bool _andPatchEnabled = true;
  int _andForceBelowBuild = 6;
  int _andFlexibleBelowBuild = 250;
  String _andStoreUrl = 'https://play.google.com/store/apps/details?id=app.example';

  // iOS
  String _iosLatestSemver = '1.0.0';
  int _iosLatestBuild = 7;
  String _iosMinSemver = '1.0.0';
  int _iosMinBuild = 7;
  int _iosPatchNumber = 1;
  int _iosPatchMin = 7;
  int _iosPatchMax = 7;
  bool _iosPatchHotfix = false;
  String _iosPatchNotes = 'Performance optimizations.';
  bool _iosPatchEnabled = true;
  int _iosForceBelowBuild = 6;
  int _iosFlexibleBelowBuild = 7;
  String _iosStoreUrl = 'https://apps.apple.com/app/id000000000';

  @override
  void initState() {
    super.initState();
    _syncModelFromFields();
  }

  // ── Build model from current field state and update _model
  void _syncModelFromFields() {
    _model = AppUpdaterModel(
      android: PlatformConfig(
        version: VersionConfig(
          min: VersionDetail(semver: _andMinSemver, build: _andMinBuild),
          recommended: VersionDetail(semver: _andLatestSemver, build: _andLatestBuild),
          latest: VersionDetail(semver: _andLatestSemver, build: _andLatestBuild),
        ),
        patch: PatchConfig(
          number: _andPatchNumber,
          minAppBuild: _andPatchMin,
          maxAppBuild: _andPatchMax,
          hotfix: _andPatchHotfix,
          notes: _andPatchNotes,
          enabled: _andPatchEnabled,
        ),
        update: UpdateConfig(
          forceBelowBuild: _andForceBelowBuild,
          flexibleBelowBuild: _andFlexibleBelowBuild,
        ),
        storeUrl: _andStoreUrl,
      ),
      ios: PlatformConfig(
        version: VersionConfig(
          min: VersionDetail(semver: _iosMinSemver, build: _iosMinBuild),
          recommended: VersionDetail(semver: _iosLatestSemver, build: _iosLatestBuild),
          latest: VersionDetail(semver: _iosLatestSemver, build: _iosLatestBuild),
        ),
        patch: PatchConfig(
          number: _iosPatchNumber,
          minAppBuild: _iosPatchMin,
          maxAppBuild: _iosPatchMax,
          hotfix: _iosPatchHotfix,
          notes: _iosPatchNotes,
          enabled: _iosPatchEnabled,
        ),
        update: UpdateConfig(
          forceBelowBuild: _iosForceBelowBuild,
          flexibleBelowBuild: _iosFlexibleBelowBuild,
        ),
        storeUrl: _iosStoreUrl,
      ),
      global: GlobalConfig(
        killSwitch: _killSwitch,
        maintenance: MaintenanceConfig(
          active: _maintenanceActive,
          message: {'en': _maintenanceMsg},
          endTime: _maintenanceEndTime,
        ),
        releaseNotes: {'en': _releaseNotes},
      ),
    );
  }

  // ── Load all fields from a raw JSON map
  void _loadFromJson(Map<String, dynamic> j) {
    final m = AppUpdaterModel.fromJson(j);
    final g = m.global;
    final a = m.android;
    final i = m.ios;

    _killSwitch = g.killSwitch;
    _maintenanceActive = g.maintenance.active;
    _maintenanceMsg = g.maintenance.message['en'] ?? '';
    _maintenanceEndTime = g.maintenance.endTime ?? '';
    _releaseNotes = g.releaseNotes['en'] ?? '';

    _andLatestSemver = a.version.latest.semver;
    _andLatestBuild = a.version.latest.build;
    _andMinSemver = a.version.min.semver;
    _andMinBuild = a.version.min.build;
    _andPatchNumber = a.patch.number;
    _andPatchMin = a.patch.minAppBuild;
    _andPatchMax = a.patch.maxAppBuild;
    _andPatchHotfix = a.patch.hotfix;
    _andPatchNotes = a.patch.notes;
    _andPatchEnabled = a.patch.enabled;
    _andForceBelowBuild = a.update.forceBelowBuild;
    _andFlexibleBelowBuild = a.update.flexibleBelowBuild;
    _andStoreUrl = a.storeUrl;

    _iosLatestSemver = i.version.latest.semver;
    _iosLatestBuild = i.version.latest.build;
    _iosMinSemver = i.version.min.semver;
    _iosMinBuild = i.version.min.build;
    _iosPatchNumber = i.patch.number;
    _iosPatchMin = i.patch.minAppBuild;
    _iosPatchMax = i.patch.maxAppBuild;
    _iosPatchHotfix = i.patch.hotfix;
    _iosPatchNotes = i.patch.notes;
    _iosPatchEnabled = i.patch.enabled;
    _iosForceBelowBuild = i.update.forceBelowBuild;
    _iosFlexibleBelowBuild = i.update.flexibleBelowBuild;
    _iosStoreUrl = i.storeUrl;

    _syncModelFromFields();
  }

  // ── Compute overlay for the current preview state
  UpdaterOverlayConfig? _overlay() {
    final platformConfig = _platform == 'android' ? _model.android : _model.ios;
    const locale = 'en';

    // 1. Kill Switch (Top Priority)
    if (_model.global.killSwitch) {
      return UpdaterOverlayConfig.killSwitch(
        message: 'This application version is no longer supported. Please contact support.',
      );
    }

    // 2. Maintenance Mode
    if (_model.global.maintenance.active) {
      return UpdaterOverlayConfig.maintenance(
        message: _model.global.maintenance.message[locale] ?? 'Under maintenance.',
        endTime: _model.global.maintenance.endTime,
      );
    }

    // 3. Forced Update (Binary replacement required)
    if (_build < platformConfig.update.forceBelowBuild) {
      return UpdaterOverlayConfig.update(
        isForced: true,
        storeUrl: platformConfig.storeUrl,
        releaseNotes: _model.global.releaseNotes[locale] ?? '',
        latestVersion: platformConfig.version.latest.semver,
        currentVersion: platformConfig.version.recommended.semver,
        latestBuild: platformConfig.version.latest.build,
        currentBuild: _build,
      );
    }

    // 4. Shorebird Patch (Hotfix or optimization for current binary)
    final patch = platformConfig.patch;
    if (patch.enabled && _build >= patch.minAppBuild && _build <= patch.maxAppBuild && _patch < patch.number) {
      return UpdaterOverlayConfig.shorebird(
        patchNotes: patch.notes,
        isHotfix: patch.hotfix,
        patchNumber: patch.number,
        currentBuild: _build,
        currentPatch: _patch,
      );
    }

    // 5. Flexible Update (Optional binary upgrade)
    if (_build < platformConfig.update.flexibleBelowBuild) {
      return UpdaterOverlayConfig.update(
        isForced: false,
        storeUrl: platformConfig.storeUrl,
        releaseNotes: _model.global.releaseNotes[locale] ?? '',
        latestVersion: platformConfig.version.latest.semver,
        currentVersion: platformConfig.version.recommended.semver,
        latestBuild: platformConfig.version.latest.build,
        currentBuild: _build,
      );
    }
    return null;
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Component _field({
    required String label,
    required String hint,
    required String value,
    InputType type = InputType.text,
    required void Function(String) onChange,
  }) {
    return div(classes: 'flex flex-col gap-1', [
      span(classes: 'text-xs text-zinc-600 dark:text-zinc-400 font-medium', [Component.text(label)]),
      input(
        type: type,
        value: value,
        classes:
            'bg-zinc-100 dark:bg-zinc-800 text-zinc-900 dark:text-white text-sm rounded-lg px-3 py-2 w-full outline-none focus:ring-1 focus:ring-blue-500/50 placeholder-zinc-400 dark:placeholder-zinc-600 border-0',
        events: {
          'input': (e) {
            onChange((e.target as dynamic).value as String);
            setState(_syncModelFromFields);
          },
        },
      ),
    ]);
  }

  Component _toggle({
    required String label,
    required String hint,
    required bool value,
    required void Function(bool) onChange,
  }) {
    return div(classes: 'flex items-center justify-between py-2', [
      div(classes: 'flex flex-col', [
        span(classes: 'text-sm text-zinc-900 dark:text-white font-medium', [Component.text(label)]),
        span(classes: 'text-xs text-zinc-500 dark:text-zinc-400', [Component.text(hint)]),
      ]),
      button(
        classes:
            'w-11 h-6 rounded-full relative transition-colors border-0 cursor-pointer ${value ? "bg-blue-600" : "bg-zinc-200 dark:bg-zinc-700"}',
        events: {
          'click': (e) {
            onChange(!value);
            setState(_syncModelFromFields);
          },
        },
        [
          div(
            classes:
                'absolute top-1/2 -translate-y-1/2 w-4 h-4 rounded-full bg-white transition-all shadow-sm ${value ? "left-[26px]" : "left-1"}',
            [],
          ),
        ],
      ),
    ]);
  }

  Component _section({required String title, required List<Component> children}) {
    return div(classes: 'flex flex-col gap-4 border-b border-zinc-200 dark:border-white/5 pb-6 mb-2', [
      h3(classes: 'text-[11px] font-bold text-zinc-500 uppercase tracking-widest m-0', [Component.text(title)]),
      ...children,
    ]);
  }

  // ─── Forms ────────────────────────────────────────────────────────────────

  Component _globalForm() {
    return div(classes: 'flex flex-col gap-6 pt-4', [
      _section(
        title: 'Kill Switch',
        children: [
          _toggle(
            label: 'Enable Kill Switch',
            hint: 'Blocks all users from accessing the app.',
            value: _killSwitch,
            onChange: (v) => _killSwitch = v,
          ),
        ],
      ),
      _section(
        title: 'Maintenance Mode',
        children: [
          _toggle(
            label: 'Active',
            hint: 'Show the maintenance overlay to all users.',
            value: _maintenanceActive,
            onChange: (v) => _maintenanceActive = v,
          ),
          if (_maintenanceActive) ...[
            _field(
              label: 'Message (EN)',
              hint: '',
              value: _maintenanceMsg,
              onChange: (v) => _maintenanceMsg = v,
            ),
            _field(
              label: 'Estimated End Time',
              hint: '',
              value: _maintenanceEndTime,
              onChange: (v) => _maintenanceEndTime = v,
            ),
          ],
        ],
      ),
      _section(
        title: 'Release Notes',
        children: [
          div(classes: 'flex flex-col gap-1', [
            span(classes: 'text-xs text-zinc-600 dark:text-zinc-400 font-medium', [
              Component.text('Release Notes (EN)'),
            ]),
            textarea(
              classes:
                  'bg-zinc-100 dark:bg-zinc-800 text-zinc-900 dark:text-white text-sm rounded-lg px-3 py-2 w-full outline-none focus:ring-1 focus:ring-blue-500/50 placeholder-zinc-400 dark:placeholder-zinc-600 border-0 h-32 resize-none',
              events: {
                'input': (e) {
                  _releaseNotes = (e.target as dynamic).value as String;
                  setState(_syncModelFromFields);
                },
              },
              [Component.text(_releaseNotes)],
            ),
          ]),
        ],
      ),
    ]);
  }

  Component _platformForm(String os) {
    var latestSemver = os == 'android' ? _andLatestSemver : _iosLatestSemver;
    var latestBuild = os == 'android' ? _andLatestBuild : _iosLatestBuild;
    var minSemver = os == 'android' ? _andMinSemver : _iosMinSemver;
    var minBuild = os == 'android' ? _andMinBuild : _iosMinBuild;

    var patchNumber = os == 'android' ? _andPatchNumber : _iosPatchNumber;
    var patchMin = os == 'android' ? _andPatchMin : _iosPatchMin;
    var patchMax = os == 'android' ? _andPatchMax : _iosPatchMax;
    var patchHotfix = os == 'android' ? _andPatchHotfix : _iosPatchHotfix;
    var patchNotes = os == 'android' ? _andPatchNotes : _iosPatchNotes;
    var patchEnabled = os == 'android' ? _andPatchEnabled : _iosPatchEnabled;

    var forceBelow = os == 'android' ? _andForceBelowBuild : _iosForceBelowBuild;
    var flexibleBelow = os == 'android' ? _andFlexibleBelowBuild : _iosFlexibleBelowBuild;
    var storeUrl = os == 'android' ? _andStoreUrl : _iosStoreUrl;

    return div(classes: 'flex flex-col gap-6 pt-4', [
      _section(
        title: 'Versions',
        children: [
          div(classes: 'grid grid-cols-2 gap-3', [
            _field(
              label: 'Latest SemVer',
              hint: '',
              value: latestSemver,
              onChange: (v) => os == 'android' ? _andLatestSemver = v : _iosLatestSemver = v,
            ),
            _field(
              label: 'Latest Build',
              hint: '',
              type: InputType.number,
              value: latestBuild.toString(),
              onChange: (v) {
                final val = int.tryParse(v) ?? 0;
                if (os == 'android') {
                  _andLatestBuild = val;
                  _andFlexibleBelowBuild = val;
                } else {
                  _iosLatestBuild = val;
                  _iosFlexibleBelowBuild = val;
                }
              },
            ),
            _field(
              label: 'Min SemVer',
              hint: '',
              value: minSemver,
              onChange: (v) => os == 'android' ? _andMinSemver = v : _iosMinSemver = v,
            ),
            _field(
              label: 'Min Build',
              hint: '',
              type: InputType.number,
              value: minBuild.toString(),
              onChange: (v) {
                final val = int.tryParse(v) ?? 0;
                if (os == 'android') {
                  _andMinBuild = val;
                  _andForceBelowBuild = val;
                } else {
                  _iosMinBuild = val;
                  _iosForceBelowBuild = val;
                }
              },
            ),
          ]),
        ],
      ),
      _section(
        title: 'Shorebird Patch',
        children: [
          _toggle(
            label: 'Enabled',
            hint: 'Whether to show the Shorebird patch overlay on this platform.',
            value: patchEnabled,
            onChange: (v) => os == 'android' ? _andPatchEnabled = v : _iosPatchEnabled = v,
          ),
          div(classes: 'grid grid-cols-2 gap-3', [
            _field(
              label: 'Patch Number',
              hint: '',
              type: InputType.number,
              value: patchNumber.toString(),
              onChange: (v) =>
                  os == 'android' ? _andPatchNumber = int.tryParse(v) ?? 0 : _iosPatchNumber = int.tryParse(v) ?? 0,
            ),
            div(classes: 'flex items-end pb-1', [
              _toggle(
                label: 'Is Hotfix',
                hint: '',
                value: patchHotfix,
                onChange: (v) => os == 'android' ? _andPatchHotfix = v : _iosPatchHotfix = v,
              ),
            ]),
            _field(
              label: 'Min App Build',
              hint: '',
              type: InputType.number,
              value: patchMin.toString(),
              onChange: (v) =>
                  os == 'android' ? _andPatchMin = int.tryParse(v) ?? 0 : _iosPatchMin = int.tryParse(v) ?? 0,
            ),
            _field(
              label: 'Max App Build',
              hint: '',
              type: InputType.number,
              value: patchMax.toString(),
              onChange: (v) =>
                  os == 'android' ? _andPatchMax = int.tryParse(v) ?? 0 : _iosPatchMax = int.tryParse(v) ?? 0,
            ),
          ]),
          _field(
            label: 'Patch Notes',
            hint: '',
            value: patchNotes,
            onChange: (v) => os == 'android' ? _andPatchNotes = v : _iosPatchNotes = v,
          ),
        ],
      ),
      _section(
        title: 'App Updates',
        children: [
          div(classes: 'grid grid-cols-2 gap-3', [
            _field(
              label: 'Force Below Build',
              hint: '',
              type: InputType.number,
              value: forceBelow.toString(),
              onChange: (v) => os == 'android'
                  ? _andForceBelowBuild = int.tryParse(v) ?? 0
                  : _iosForceBelowBuild = int.tryParse(v) ?? 0,
            ),
            _field(
              label: 'Flexible Below Build',
              hint: '',
              type: InputType.number,
              value: flexibleBelow.toString(),
              onChange: (v) => os == 'android'
                  ? _andFlexibleBelowBuild = int.tryParse(v) ?? 0
                  : _iosFlexibleBelowBuild = int.tryParse(v) ?? 0,
            ),
          ]),
          _field(
            label: 'Store URL',
            hint: '',
            value: storeUrl,
            onChange: (v) => os == 'android' ? _andStoreUrl = v : _iosStoreUrl = v,
          ),
        ],
      ),
    ]);
  }

  // ─── Generate JSON Modal ──────────────────────────────────────────────────

  Component _generateModal() {
    final prettyJson = const JsonEncoder.withIndent('  ').convert(_model.toJson());
    return div(
      classes: 'fixed inset-0 z-50 flex items-center justify-center',
      [
        // Backdrop
        div(
          classes: 'absolute inset-0 bg-zinc-900/40 dark:bg-slate-800 dark:bg-black/60 backdrop-blur-sm',
          events: {'click': (e) => setState(() => _showGenerateModal = false)},
          [],
        ),
        // Modal card
        div(
          classes:
              'relative z-10 bg-zinc-100 dark:bg-zinc-900 border border-zinc-300 dark:border-zinc-700 dark:border-white/10 rounded-2xl shadow-2xl w-full max-w-2xl mx-4 overflow-hidden',
          [
            // Header
            div(classes: 'flex items-center justify-between px-5 py-4 border-b border-zinc-200 dark:border-white/5', [
              div(classes: 'flex items-center gap-2', [
                i(classes: 'material-icons text-emerald-400 text-[18px]', [Component.text('code')]),
                span(classes: 'text-zinc-900 dark:text-white font-semibold', [Component.text('Generated JSON Config')]),
              ]),
              div(classes: 'flex items-center gap-2', [
                // Copy button
                button(
                  classes: _copied
                      ? 'flex items-center gap-1.5 text-xs font-semibold text-emerald-400 px-3 py-1.5 rounded-lg bg-emerald-500/10 border-0 cursor-pointer transition-all'
                      : 'flex items-center gap-1.5 text-xs font-semibold text-zinc-700 dark:text-zinc-300 hover:text-zinc-900 dark:text-white px-3 py-1.5 rounded-lg bg-zinc-200 dark:bg-white/5 hover:bg-zinc-300 dark:bg-white/10 border-0 cursor-pointer transition-all',
                  events: {
                    'click': (e) async {
                      // Copy to clipboard via JS interop
                      window.navigator.clipboard.writeText(prettyJson);
                      setState(() => _copied = true);
                      await Future.delayed(const Duration(seconds: 2));
                      setState(() => _copied = false);
                    },
                  },
                  [
                    i(
                      classes: 'material-icons text-[14px]',
                      [Component.text(_copied ? 'check_circle' : 'content_copy')],
                    ),
                    Component.text(_copied ? 'Copied!' : 'Copy to Clipboard'),
                  ],
                ),
                // Close
                button(
                  classes: 'text-zinc-500 hover:text-zinc-900 dark:text-white border-0 bg-transparent cursor-pointer',
                  events: {'click': (e) => setState(() => _showGenerateModal = false)},
                  [
                    i(classes: 'material-icons', [Component.text('close')]),
                  ],
                ),
              ]),
            ]),
            // JSON body
            div(classes: 'p-5 flex flex-col gap-4', [
              p(classes: 'text-xs text-zinc-500 dark:text-zinc-400 m-0', [
                Component.text(
                  'This JSON reflects your current configuration. Deploy it as your remote config payload.',
                ),
              ]),
              div(
                classes:
                    'relative rounded-xl overflow-hidden bg-white dark:bg-zinc-950 border border-zinc-200 dark:border-white/5',
                [
                  pre(
                    classes: 'text-zinc-700 dark:text-zinc-300 text-xs font-mono p-4 overflow-auto max-h-[480px] m-0',
                    [Component.text(prettyJson)],
                  ),
                ],
              ),
            ]),
          ],
        ),
      ],
    );
  }

  // ─── JSON Paste Modal ─────────────────────────────────────────────────────

  Component _jsonModal() {
    return div(
      classes: 'fixed inset-0 z-50 flex items-center justify-center',
      [
        // Backdrop
        div(
          classes: 'absolute inset-0 bg-zinc-900/40 dark:bg-slate-800 dark:bg-black/60 backdrop-blur-sm',
          events: {'click': (e) => setState(() => _showJsonModal = false)},
          [],
        ),
        // Modal card
        div(
          classes:
              'relative z-10 bg-zinc-100 dark:bg-zinc-900 border border-zinc-300 dark:border-zinc-700 dark:border-white/10 rounded-2xl shadow-2xl w-full max-w-2xl mx-4 overflow-hidden',
          [
            // Header
            div(classes: 'flex items-center justify-between px-5 py-4 border-b border-zinc-200 dark:border-white/5', [
              div(classes: 'flex items-center gap-2', [
                i(classes: 'material-icons text-blue-400 text-[18px]', [Component.text('data_object')]),
                span(classes: 'text-zinc-900 dark:text-white font-semibold', [Component.text('Paste JSON Config')]),
              ]),
              button(
                classes: 'text-zinc-500 hover:text-zinc-900 dark:text-white border-0 bg-transparent cursor-pointer',
                events: {'click': (e) => setState(() => _showJsonModal = false)},
                [
                  i(classes: 'material-icons', [Component.text('close')]),
                ],
              ),
            ]),
            // Body
            div(classes: 'p-5 flex flex-col gap-4', [
              p(classes: 'text-sm text-zinc-600 dark:text-zinc-400 m-0', [
                Component.text(
                  'Paste your full JSON config below. All form fields will be updated when you click Apply.',
                ),
              ]),
              div(classes: 'relative', [
                textarea(
                  classes: _jsonError.isEmpty
                      ? 'w-full h-64 bg-zinc-100 dark:bg-zinc-800 text-zinc-800 dark:text-zinc-200 text-sm font-mono p-3 rounded-xl border-0 outline-none resize-none'
                      : 'w-full h-64 bg-red-500/5 text-zinc-800 dark:text-zinc-200 text-sm font-mono p-3 rounded-xl border border-red-500/30 outline-none resize-none',
                  events: {
                    'input': (e) => setState(() => _jsonDraft = (e.target as dynamic).value as String),
                  },
                  [Component.text(_jsonDraft)],
                ),
                if (_jsonError.isNotEmpty)
                  div(
                    classes:
                        'absolute bottom-2 left-2 right-2 bg-red-900/80 text-red-300 text-xs px-3 py-1.5 rounded-lg',
                    [
                      Component.text(_jsonError),
                    ],
                  ),
              ]),
              div(classes: 'flex justify-end gap-2', [
                button(
                  classes:
                      'px-4 py-2 text-sm text-zinc-600 dark:text-zinc-400 hover:text-zinc-900 dark:text-white bg-transparent border-0 cursor-pointer',
                  events: {'click': (e) => setState(() => _showJsonModal = false)},
                  [Component.text('Cancel')],
                ),
                button(
                  classes:
                      'px-5 py-2 text-sm font-semibold text-zinc-900 dark:text-white bg-blue-600 hover:bg-blue-500 rounded-xl border-0 cursor-pointer transition-colors',
                  events: {
                    'click': (e) {
                      try {
                        final decoded = json.decode(_jsonDraft) as Map<String, dynamic>;
                        setState(() {
                          _loadFromJson(decoded);
                          _jsonError = '';
                          _showJsonModal = false;
                          _jsonDraft = '';
                        });
                      } catch (err) {
                        setState(() => _jsonError = err.toString());
                      }
                    },
                  },
                  [Component.text('Apply JSON')],
                ),
              ]),
            ]),
          ],
        ),
      ],
    );
  }

  // ─── Main Build ───────────────────────────────────────────────────────────

  @override
  Component build(BuildContext context) {
    final overlay = _overlay();

    return div(classes: 'flex flex-1 min-h-0 bg-transparent text-inherit font-sans relative', [
      // ══════════════════════════════════════
      // LEFT — Config Form Panel
      // ══════════════════════════════════════
      div(
        classes:
            'flex flex-col w-[420px] flex-shrink-0 bg-gray-50 dark:bg-[#0c0c0e] border-r border-zinc-200 dark:border-white/5',
        [
          // ─── Panel header
          div(
            classes:
                'flex items-center justify-between px-4 py-3 border-b border-zinc-200 dark:border-white/5 flex-shrink-0',
            [
              span(classes: 'text-zinc-900 dark:text-white font-semibold text-sm', [Component.text('Configuration')]),
              div(classes: 'flex items-center gap-2', [
                // Generate JSON button
                button(
                  classes:
                      'flex items-center gap-1.5 text-xs text-emerald-400 hover:text-emerald-300 px-3 py-1.5 rounded-lg bg-emerald-500/10 hover:bg-emerald-500/15 border-0 cursor-pointer transition-colors',
                  events: {
                    'click': (e) => setState(() {
                      _showGenerateModal = true;
                      _copied = false;
                    }),
                  },
                  [
                    i(classes: 'material-icons text-[13px]', [Component.text('download')]),
                    Component.text('Generate JSON'),
                  ],
                ),
                // Paste JSON button
                button(
                  classes:
                      'flex items-center gap-1.5 text-xs text-zinc-600 dark:text-zinc-400 hover:text-zinc-900 dark:text-white px-3 py-1.5 rounded-lg bg-zinc-200 dark:bg-white/5 hover:bg-zinc-300 dark:bg-white/10 border-0 cursor-pointer transition-colors',
                  events: {
                    'click': (e) => setState(() {
                      _showJsonModal = true;
                      _jsonDraft = const JsonEncoder.withIndent('  ').convert(_model.toJson());
                      _jsonError = '';
                    }),
                  },
                  [
                    i(classes: 'material-icons text-[13px]', [Component.text('data_object')]),
                    Component.text('Paste JSON'),
                  ],
                ),
              ]),
            ],
          ),

          // ─── Tab bar
          div(classes: 'flex p-2 flex-shrink-0', [
            div(
              classes:
                  'flex p-1 bg-zinc-200 dark:bg-white/5 rounded-xl w-full border border-zinc-200 dark:border-white/5',
              [
                button(
                  classes:
                      'flex-1 flex items-center justify-center gap-2 py-1.5 px-3 rounded-lg text-xs font-semibold transition-all border-0 cursor-pointer ${_tab == 'global' ? "bg-zinc-300 dark:bg-white/10 text-zinc-900 dark:text-white shadow-sm" : "bg-transparent text-zinc-500 hover:text-zinc-700 dark:text-zinc-300"}',
                  events: {'click': (e) => setState(() => _tab = 'global')},
                  [
                    i(classes: 'material-icons text-[14px]', [Component.text('public')]),
                    Component.text('Global'),
                  ],
                ),
                button(
                  classes:
                      'flex-1 flex items-center justify-center gap-2 py-1.5 px-3 rounded-lg text-xs font-semibold transition-all border-0 cursor-pointer ${_tab == 'android' ? "bg-zinc-300 dark:bg-white/10 text-zinc-900 dark:text-white shadow-sm" : "bg-transparent text-zinc-500 hover:text-zinc-700 dark:text-zinc-300"}',
                  events: {'click': (e) => setState(() => _tab = 'android')},
                  [
                    i(classes: 'material-icons text-[14px]', [Component.text('android')]),
                    Component.text('Android'),
                  ],
                ),
                button(
                  classes:
                      'flex-1 flex items-center justify-center gap-2 py-1.5 px-3 rounded-lg text-xs font-semibold transition-all border-0 cursor-pointer ${_tab == 'ios' ? "bg-zinc-300 dark:bg-white/10 text-zinc-900 dark:text-white shadow-sm" : "bg-transparent text-zinc-500 hover:text-zinc-700 dark:text-zinc-300"}',
                  events: {'click': (e) => setState(() => _tab = 'ios')},
                  [
                    i(classes: 'material-icons text-[14px]', [Component.text('phone_iphone')]),
                    Component.text('iOS'),
                  ],
                ),
              ],
            ),
          ]),

          // ─── Tab Content (scrollable)
          div(classes: 'flex-1 overflow-y-auto px-6 pb-20 custom-scrollbar', [
            if (_tab == 'global') _globalForm(),
            if (_tab == 'android') _platformForm('android'),
            if (_tab == 'ios') _platformForm('ios'),
          ]),
        ],
      ),

      // ══════════════════════════════════════
      // RIGHT — Device Preview
      // ══════════════════════════════════════
      div(classes: 'flex-1 flex flex-col min-w-0 bg-white dark:bg-zinc-950 overflow-hidden', [
        // ─── Preview Header
        div(
          classes:
              'flex items-center justify-between px-6 py-4 border-b border-zinc-200 dark:border-white/5 flex-shrink-0',
          [
            span(classes: 'text-zinc-900 dark:text-white font-semibold', [Component.text('Device Preview')]),

            // Preview controls row
            div(classes: 'flex items-center gap-4', [
              // ── Size presets
              div(classes: 'flex gap-1 bg-zinc-100 dark:bg-zinc-900 rounded-lg p-1', [
                for (final preset in [
                  (label: 'S', w: 320.0, h: 693.0),
                  (label: 'M', w: 375.0, h: 812.0),
                  (label: 'L', w: 430.0, h: 932.0),
                ])
                  button(
                    classes: _previewWidth == preset.w && _previewHeight == preset.h
                        ? 'px-3 py-1 text-xs font-semibold text-zinc-900 dark:text-white bg-zinc-200 dark:bg-zinc-200 dark:bg-zinc-700/80 rounded-md border-0 cursor-pointer'
                        : 'px-3 py-1 text-xs font-semibold text-zinc-500 hover:text-zinc-700 dark:text-zinc-300 bg-transparent rounded-md border-0 cursor-pointer',
                    events: {
                      'click': (e) => setState(() {
                        _previewWidth = preset.w;
                        _previewHeight = preset.h;
                      }),
                    },
                    [Component.text(preset.label)],
                  ),
              ]),

              // ── Custom dimensions (W x H)
              div(classes: 'flex items-center gap-2', [
                // Width control
                div(classes: 'flex items-center bg-zinc-100 dark:bg-zinc-900 rounded-lg overflow-hidden', [
                  button(
                    classes:
                        'w-7 flex items-center justify-center text-zinc-500 hover:text-zinc-900 dark:text-white bg-transparent border-0 cursor-pointer hover:bg-zinc-200 dark:bg-white/5 text-[14px]',
                    events: {'click': (e) => setState(() => _previewWidth = (_previewWidth - 10).clamp(280.0, 800.0))},
                    [
                      i(classes: 'material-icons text-[14px]', [Component.text('remove')]),
                    ],
                  ),
                  div(
                    classes:
                        'w-16 flex items-center justify-center gap-1.5 border-x border-zinc-200 dark:border-white/5 py-1 text-xs text-zinc-700 dark:text-zinc-300 font-mono',
                    [
                      i(classes: 'material-icons text-[12px] text-zinc-500', [Component.text('swap_horiz')]),
                      Component.text(_previewWidth.toInt().toString()),
                    ],
                  ),
                  button(
                    classes:
                        'w-7 flex items-center justify-center text-zinc-500 hover:text-zinc-900 dark:text-white bg-transparent border-0 cursor-pointer hover:bg-zinc-200 dark:bg-white/5 text-[14px]',
                    events: {'click': (e) => setState(() => _previewWidth = (_previewWidth + 10).clamp(280.0, 800.0))},
                    [
                      i(classes: 'material-icons text-[14px]', [Component.text('add')]),
                    ],
                  ),
                ]),
                // Height control
                div(classes: 'flex items-center bg-zinc-100 dark:bg-zinc-900 rounded-lg overflow-hidden', [
                  button(
                    classes:
                        'w-7 flex items-center justify-center text-zinc-500 hover:text-zinc-900 dark:text-white bg-transparent border-0 cursor-pointer hover:bg-zinc-200 dark:bg-white/5 text-[14px]',
                    events: {
                      'click': (e) => setState(() => _previewHeight = (_previewHeight - 10).clamp(400.0, 1200.0)),
                    },
                    [
                      i(classes: 'material-icons text-[14px]', [Component.text('remove')]),
                    ],
                  ),
                  div(
                    classes:
                        'w-16 flex items-center justify-center gap-1.5 border-x border-zinc-200 dark:border-white/5 py-1 text-xs text-zinc-700 dark:text-zinc-300 font-mono',
                    [
                      i(classes: 'material-icons text-[12px] text-zinc-500', [Component.text('swap_vert')]),
                      Component.text(_previewHeight.toInt().toString()),
                    ],
                  ),
                  button(
                    classes:
                        'w-7 flex items-center justify-center text-zinc-500 hover:text-zinc-900 dark:text-white bg-transparent border-0 cursor-pointer hover:bg-zinc-200 dark:bg-white/5 text-[14px]',
                    events: {
                      'click': (e) => setState(() => _previewHeight = (_previewHeight + 10).clamp(400.0, 1200.0)),
                    },
                    [
                      i(classes: 'material-icons text-[14px]', [Component.text('add')]),
                    ],
                  ),
                ]),
              ]),

              // ── Platform toggle
              div(classes: 'flex p-1 bg-zinc-100 dark:bg-zinc-900 rounded-lg', [
                button(
                  classes:
                      'px-4 py-1 text-xs font-semibold rounded-md border-0 cursor-pointer transition-colors ${_platform == "android" ? "bg-zinc-300 dark:bg-white/10 text-zinc-900 dark:text-white" : "bg-transparent text-zinc-500 hover:text-zinc-700 dark:text-zinc-300"}',
                  events: {'click': (e) => setState(() => _platform = 'android')},
                  [Component.text('Android')],
                ),
                button(
                  classes:
                      'px-4 py-1 text-xs font-semibold rounded-md border-0 cursor-pointer transition-colors ${_platform == "ios" ? "bg-zinc-300 dark:bg-white/10 text-zinc-900 dark:text-white" : "bg-transparent text-zinc-500 hover:text-zinc-700 dark:text-zinc-300"}',
                  events: {'click': (e) => setState(() => _platform = 'ios')},
                  [Component.text('iOS')],
                ),
              ]),

              // ── Build control
              div(classes: 'flex items-center gap-2 bg-zinc-100 dark:bg-zinc-900 pl-3 pr-1 py-1 rounded-lg', [
                span(classes: 'text-xs text-zinc-500 dark:text-zinc-400', [Component.text('Build:')]),
                button(
                  classes:
                      'w-6 h-6 flex items-center justify-center text-zinc-900 dark:text-white bg-zinc-200 dark:bg-white/5 hover:bg-zinc-300 dark:bg-white/10 rounded border-0 cursor-pointer',
                  events: {'click': (e) => setState(() => _build = (_build - 1).clamp(0, 999))},
                  [
                    i(classes: 'material-icons text-[14px]', [Component.text('remove')]),
                  ],
                ),
                span(classes: 'text-xs text-zinc-900 dark:text-white font-mono w-6 text-center', [
                  Component.text('$_build'),
                ]),
                button(
                  classes:
                      'w-6 h-6 flex items-center justify-center text-zinc-900 dark:text-white bg-zinc-200 dark:bg-white/5 hover:bg-zinc-300 dark:bg-white/10 rounded border-0 cursor-pointer',
                  events: {'click': (e) => setState(() => _build = (_build + 1).clamp(0, 999))},
                  [
                    i(classes: 'material-icons text-[14px]', [Component.text('add')]),
                  ],
                ),
              ]),

              // ── Patch control
              div(classes: 'flex items-center gap-2 bg-zinc-100 dark:bg-zinc-900 pl-3 pr-1 py-1 rounded-lg', [
                span(classes: 'text-xs text-zinc-500 dark:text-zinc-400', [Component.text('Patch:')]),
                button(
                  classes:
                      'w-6 h-6 flex items-center justify-center text-zinc-900 dark:text-white bg-zinc-200 dark:bg-white/5 hover:bg-zinc-300 dark:bg-white/10 rounded border-0 cursor-pointer',
                  events: {'click': (e) => setState(() => _patch = (_patch - 1).clamp(0, 999))},
                  [
                    i(classes: 'material-icons text-[14px]', [Component.text('remove')]),
                  ],
                ),
                span(classes: 'text-xs text-zinc-900 dark:text-white font-mono w-6 text-center', [
                  Component.text('$_patch'),
                ]),
                button(
                  classes:
                      'w-6 h-6 flex items-center justify-center text-zinc-900 dark:text-white bg-zinc-200 dark:bg-white/5 hover:bg-zinc-300 dark:bg-white/10 rounded border-0 cursor-pointer',
                  events: {'click': (e) => setState(() => _patch = (_patch + 1).clamp(0, 999))},
                  [
                    i(classes: 'material-icons text-[14px]', [Component.text('add')]),
                  ],
                ),
              ]),
            ]),
          ],
        ),

        // ─── Preview Canvas
        div(classes: 'flex-1 overflow-auto flex items-center justify-center p-8', [
          div(classes: 'relative drop-shadow-[0_0_100px_rgba(255,255,255,0.02)]', [
            // Status Badges (absolute positioned around phone)
            if (overlay != null) ...[
              div(classes: 'absolute -top-12 left-0 right-0 flex justify-center', [
                div(
                  classes: _overlayBadgeClass(overlay.type),
                  [
                    i(classes: 'material-icons text-[14px]', [Component.text(_overlayBadgeIcon(overlay.type))]),
                    Component.text(overlay.type.name.toUpperCase()),
                  ],
                ),
              ]),
            ],

            // Phone shell — dimensions driven by _previewWidth/_previewHeight
            div(
              attributes: {
                'style':
                    'position:relative;'
                    'width:${_previewWidth.toInt()}px;'
                    'height:${_previewHeight.toInt()}px;'
                    'border-radius:44px;'
                    'overflow:hidden;'
                    'box-shadow:0 25px 60px rgba(0,0,0,0.7);'
                    'outline:1px solid rgba(255,255,255,0.08);'
                    'transition:width 0.25s ease,height 0.25s ease;',
              },
              [
                // Notch
                div(classes: 'absolute top-0 left-0 right-0 z-10 flex justify-center pt-3', [
                  div(classes: 'w-24 h-6 bg-slate-800 dark:bg-black rounded-b-2xl', []),
                ]),
                // Background behind overlay
                div(classes: 'absolute inset-0 bg-white dark:bg-zinc-950 flex flex-col', [
                  // Fake app skeleton
                  div(classes: 'h-14 border-b border-zinc-200 dark:border-white/5 flex items-end px-4 pb-3', [
                    span(classes: 'text-zinc-900 dark:text-white font-semibold', [Component.text('My App')]),
                  ]),
                  div(classes: 'flex flex-col gap-3 p-4 flex-1', [
                    div(classes: 'h-4 w-32 rounded bg-zinc-300 dark:bg-white/10', []),
                    div(classes: 'h-20 rounded-xl bg-zinc-200 dark:bg-white/5', []),
                    div(classes: 'h-4 w-20 rounded bg-zinc-300 dark:bg-white/10', []),
                    div(classes: 'h-14 rounded-xl bg-zinc-200 dark:bg-white/5', []),
                    div(classes: 'h-14 rounded-xl bg-white/[0.03]', []),
                    div(classes: 'h-4 w-24 rounded bg-zinc-300 dark:bg-white/10', []),
                    div(classes: 'h-12 rounded-xl bg-white/[0.03]', []),
                  ]),
                ]),
                // Overlay — always mounted to avoid Flutter remount on config toggle.
                // Use visibility (not display) so Flutter stays alive when hidden.
                div(
                  attributes: {
                    'style': overlay != null
                        ? 'position:absolute;inset:0;visibility:visible;'
                        : 'position:absolute;inset:0;visibility:hidden;pointer-events:none;',
                  },
                  [
                    EmbeddedUpdaterOverlay(
                      // Key only on dimensions — config changes update props in-place
                      key: ValueKey('embed_${_previewWidth.toInt()}_${_previewHeight.toInt()}'),
                      config: overlay ?? UpdaterOverlayConfig.killSwitch(message: ''),
                      onClose: () {},
                      width: _previewWidth,
                      height: _previewHeight,
                    ),
                  ],
                ),
              ],
            ),

            // Build tag below phone
            div(classes: 'absolute -bottom-10 left-0 right-0 flex justify-center', [
              span(classes: 'text-xs text-zinc-600 dark:text-zinc-400 font-mono', [
                Component.text('Build: $_build • Platform: ${(_platform == "android" ? "Android" : "iOS")}'),
              ]),
            ]),
          ]),
        ]),
      ]),

      // ══════════════════════════════════════
      // Modals
      // ══════════════════════════════════════
      if (_showJsonModal) _jsonModal(),
      if (_showGenerateModal) _generateModal(),
    ]);
  }

  String _overlayBadgeClass(UpdaterOverlayType type) {
    return switch (type) {
      UpdaterOverlayType.killSwitch =>
        'inline-flex items-center gap-1 text-xs font-semibold px-3 py-1 rounded-full bg-red-500/10 text-red-400',
      UpdaterOverlayType.maintenance =>
        'inline-flex items-center gap-1 text-xs font-semibold px-3 py-1 rounded-full bg-orange-500/10 text-orange-400',
      UpdaterOverlayType.forcedUpdate =>
        'inline-flex items-center gap-1 text-xs font-semibold px-3 py-1 rounded-full bg-blue-500/10 text-blue-400',
      UpdaterOverlayType.flexibleUpdate =>
        'inline-flex items-center gap-1 text-xs font-semibold px-3 py-1 rounded-full bg-sky-500/10 text-sky-400',
      UpdaterOverlayType.shorebirdPatch =>
        'inline-flex items-center gap-1 text-xs font-semibold px-3 py-1 rounded-full bg-violet-500/10 text-violet-400',
    };
  }

  String _overlayBadgeIcon(UpdaterOverlayType type) {
    return switch (type) {
      UpdaterOverlayType.killSwitch => 'block',
      UpdaterOverlayType.maintenance => 'construction',
      UpdaterOverlayType.forcedUpdate => 'system_update',
      UpdaterOverlayType.flexibleUpdate => 'update',
      UpdaterOverlayType.shorebirdPatch => 'auto_fix_high',
    };
  }
}

// ─── Default config ───────────────────────────────────────────────────────────

const _kDefaultJson = {
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
      "message": {"en": "Under maintenance, try again later."},
      "end_time": "12:00 PM",
    },
    "release_notes": {
      "en": "- Performance improvements\n- Bug fixes\n- New UI features",
    },
  },
};
