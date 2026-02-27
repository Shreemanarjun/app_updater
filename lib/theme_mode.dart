import 'dart:convert';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

enum ThemeMode {
  auto,
  dark,
  light,
}

class ThemeNotifier extends Notifier<ThemeMode> {
  static const String _themeStorageKey = 'enhanced_theme_toggle_cache';

  @override
  ThemeMode build() {
    if (kIsWeb) {
      try {
        final storage = web.window.localStorage;
        final storageData = storage.getItem(_themeStorageKey);
        if (storageData != null) {
          final data = jsonDecode(storageData) as Map<String, dynamic>;
          final themeString = data['theme'] as String?;
          if (themeString != null) {
            return ThemeMode.values.firstWhere(
              (m) => m.name == themeString,
              orElse: () => ThemeMode.dark,
            );
          }
        }
      } catch (_) {}
    }
    return ThemeMode.dark;
  }

  void toggle(ThemeMode mode) {
    state = mode;
    _saveToStorage(mode);
  }

  void _saveToStorage(ThemeMode mode) {
    try {
      if (kIsWeb) {
        final storage = web.window.localStorage;
        final data = {
          'theme': mode.name,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
        storage.setItem(_themeStorageKey, jsonEncode(data));
      }
    } catch (_) {}
  }

  void loadFromStorage() {
    try {
      if (kIsWeb) {
        final storage = web.window.localStorage;
        final storageData = storage.getItem(_themeStorageKey);
        if (storageData != null) {
          final data = jsonDecode(storageData) as Map<String, dynamic>;
          final themeString = data['theme'] as String?;
          if (themeString != null) {
            final mode = ThemeMode.values.firstWhere(
              (m) => m.name == themeString,
              orElse: () => ThemeMode.dark,
            );
            state = mode;
          }
        }
      }
    } catch (_) {}
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);
