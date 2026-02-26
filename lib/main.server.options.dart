// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:app_updater/components/embedded_updater_overlay.dart'
    as _embedded_updater_overlay;
import 'package:app_updater/components/header.dart' as _header;
import 'package:app_updater/pages/about.dart' as _about;
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
  clients: {_about.About: ClientTarget<_about.About>('about')},
  styles: () => [
    ..._embedded_updater_overlay.EmbeddedUpdaterOverlay.styles,
    ..._header.Header.styles,
    ..._about.About.styles,
    ..._generator.GeneratorPage.styles,
    ..._app.App.styles,
  ],
);
