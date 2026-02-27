// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/client.dart';

import 'package:app_updater/components/theme_manager.dart'
    deferred as _theme_manager;
import 'package:app_updater/components/theme_toggle.dart'
    deferred as _theme_toggle;
import 'package:app_updater/pages/generator.dart' deferred as _generator;

/// Default [ClientOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.client.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultClientOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ClientOptions get defaultClientOptions => ClientOptions(
  clients: {
    'theme_manager': ClientLoader(
      (p) => _theme_manager.ThemeManager(),
      loader: _theme_manager.loadLibrary,
    ),
    'theme_toggle': ClientLoader(
      (p) => _theme_toggle.EnhancedThemeToggle(),
      loader: _theme_toggle.loadLibrary,
    ),
    'generator': ClientLoader(
      (p) => _generator.GeneratorPage(),
      loader: _generator.loadLibrary,
    ),
  },
);
