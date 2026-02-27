/// The entrypoint for the **server** environment.
///
/// The [main] method will only be executed on the server during pre-rendering.
/// To run code on the client, check the `main.client.dart` file.
library;

import 'package:jaspr/dom.dart';
// Server-specific Jaspr import.
import 'package:jaspr/server.dart';

// Imports the [App] component.
import 'app.dart';
import 'components/theme_toggle.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

// This file is generated automatically by Jaspr, do not remove or edit.
import 'main.server.options.dart';

void main() {
  // Initializes the server environment with the generated default options.
  Jaspr.initializeApp(
    options: defaultServerOptions,
  );

  // Starts the app.
  //
  // [Document] renders the root document structure (<html>, <head> and <body>)
  // with the provided parameters and components.
  runApp(
    Document(
      title: 'App Updater Generator',
      styles: [
        css.import(
          'https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono&display=swap',
        ),
        css.import('https://fonts.googleapis.com/icon?family=Material+Icons'),
      ],
      head: [
        // Apply theme immediately on load to prevent flash
        const ThemeScript(),
        link(rel: 'stylesheet', href: 'styles.css'),
        link(rel: 'manifest', href: 'manifest.json'),
        script(src: "flutter_bootstrap.js", async: true),
      ],
      body: ProviderScope(
        child: App(),
      ),
    ),
  );
}
