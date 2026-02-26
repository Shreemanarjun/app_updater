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
          'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono&display=swap',
        ),
        css.import('https://fonts.googleapis.com/icon?family=Material+Icons'),
        css('html, body').styles(
          width: 100.percent,
          minHeight: 100.vh,
          padding: Padding.zero,
          margin: Margin.zero,
          color: Color.rgba(255, 255, 255, 1.0),
          backgroundColor: Color.rgb(9, 9, 11),
        ),
      ],
      head: [
        link(rel: 'manifest', href: 'manifest.json'),
        script(src: "flutter_bootstrap.js", async: true),
      ],
      body: App(),
    ),
  );
}
