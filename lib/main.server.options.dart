// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:app_updater/components/embedded_updater_overlay.dart'
    as _embedded_updater_overlay;
import 'package:app_updater/components/header.dart' as _header;
import 'package:app_updater/components/theme_manager.dart' as _theme_manager;
import 'package:app_updater/components/theme_toggle.dart' as _theme_toggle;
import 'package:app_updater/pages/generator.dart' as _generator;
import 'package:app_updater/app.dart' as _app;

/// Default [ServerOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.server.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultServerOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ServerOptions get defaultServerOptions => ServerOptions(
  clientId: 'main.client.dart.js',
  clients: {
    _theme_manager.ThemeManager: ClientTarget<_theme_manager.ThemeManager>(
      'theme_manager',
    ),
    _theme_toggle.EnhancedThemeToggle:
        ClientTarget<_theme_toggle.EnhancedThemeToggle>('theme_toggle'),
    _generator.GeneratorPage: ClientTarget<_generator.GeneratorPage>(
      'generator',
    ),
  },
  styles: () => [
    ..._embedded_updater_overlay.EmbeddedUpdaterOverlay.styles,
    ..._header.Header.styles,
    ..._theme_toggle.EnhancedThemeToggle.styles,
    ..._theme_toggle.EnhancedThemeToggleState.styles,
    ..._app.App.styles,
  ],
);
