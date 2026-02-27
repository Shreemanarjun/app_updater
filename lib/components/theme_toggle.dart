import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import '../theme_mode.dart' as tm;

/// A script component that applies theme immediately on page load to prevent flash
class ThemeScript extends StatelessComponent {
  const ThemeScript({super.key});

  @override
  Component build(BuildContext context) {
    return script(
      content: '''
        (function() {
          // Theme initialization
          try {
            var storage = window.localStorage;
            var storageData = storage.getItem('enhanced_theme_toggle_cache');
            var themeValue = 'dark'; // Default to dark

            if (storageData) {
              var data = JSON.parse(storageData);
              var themeString = data.theme;
              var timestamp = data.timestamp;
              var now = Date.now();

              // Check if cache is not expired (24 hours)
              if (themeString && timestamp && (now - timestamp) < 86400000) {
                if (themeString === 'dark') {
                  themeValue = 'dark';
                } else if (themeString === 'light') {
                  themeValue = 'light';
                }
              }
            } else {
              var prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
              if (prefersDark) themeValue = 'dark';
            }

            // Apply theme immediately
            document.documentElement.setAttribute('data-theme', themeValue);
            document.documentElement.classList.toggle('dark', themeValue === 'dark');
          } catch (e) {
            // Fallback to dark
            document.documentElement.setAttribute('data-theme', 'dark');
            document.documentElement.classList.add('dark');
          }
        })();
      ''',
    );
  }
}

/// An enhanced theme toggle button with auto, dark, and light options.
@client
class EnhancedThemeToggle extends StatefulComponent {
  const EnhancedThemeToggle({super.key});

  @override
  State<EnhancedThemeToggle> createState() => EnhancedThemeToggleState();

  @css
  static List<StyleRule> get styles => EnhancedThemeToggleState.styles;
}

class EnhancedThemeToggleState extends State<EnhancedThemeToggle> {
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _loadInitialTheme();
    }
  }

  void _loadInitialTheme() {
    Future.microtask(() {
      if (mounted) {
        context.read(tm.themeProvider.notifier).loadFromStorage();
      }
    });
  }

  @override
  Component build(BuildContext context) {
    final tm.ThemeMode currentMode = context.watch(tm.themeProvider);

    final currentIcon = switch (currentMode) {
      tm.ThemeMode.auto => MonitorIcon(size: 16),
      tm.ThemeMode.dark => MoonIcon(size: 16),
      tm.ThemeMode.light => SunIcon(size: 16),
    };

    final currentLabel = switch (currentMode) {
      tm.ThemeMode.auto => 'Auto',
      tm.ThemeMode.dark => 'Dark',
      tm.ThemeMode.light => 'Light',
    };

    return div(
      classes: 'enhanced-theme-toggle-container',
      [
        div(
          classes: 'theme-dropdown ${_isDropdownOpen ? 'open' : ''} ${currentMode.name}',
          [
            // Current selection display
            div(
              classes: 'dropdown-trigger',
              events: events(
                onClick: () => _toggleDropdown(),
              ),
              [
                currentIcon,
                span(classes: 'theme-label', [Component.text(currentLabel)]),
                ChevronDownIcon(size: 14),
              ],
            ),
            // Dropdown options (only shown when open)
            if (_isDropdownOpen) ...[
              // Backdrop blur
              div(
                classes: 'dropdown-backdrop',
                events: events(
                  onClick: () => _closeDropdown(),
                ),
                [],
              ),
              // Options container
              div(classes: 'dropdown-options', [
                // Auto option
                div(
                  classes: 'dropdown-option ${tm.ThemeMode.auto == currentMode ? 'active' : ''}',
                  events: events(
                    onClick: () => _selectTheme(tm.ThemeMode.auto),
                  ),
                  [
                    MonitorIcon(size: 16),
                    span(classes: 'theme-label', [Component.text('Auto')]),
                  ],
                ),
                // Dark option
                div(
                  classes: 'dropdown-option ${tm.ThemeMode.dark == currentMode ? 'active' : ''}',
                  events: events(
                    onClick: () => _selectTheme(tm.ThemeMode.dark),
                  ),
                  [
                    MoonIcon(size: 16),
                    span(classes: 'theme-label', [Component.text('Dark')]),
                  ],
                ),
                // Light option
                div(
                  classes: 'dropdown-option ${tm.ThemeMode.light == currentMode ? 'active' : ''}',
                  events: events(
                    onClick: () => _selectTheme(tm.ThemeMode.light),
                  ),
                  [
                    SunIcon(size: 16),
                    span(classes: 'theme-label', [Component.text('Light')]),
                  ],
                ),
              ]),
            ],
          ],
        ),
      ],
    );
  }

  void _toggleDropdown() {
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });
  }

  void _closeDropdown() {
    setState(() {
      _isDropdownOpen = false;
    });
  }

  void _selectTheme(tm.ThemeMode mode) {
    context.read(tm.themeProvider.notifier).toggle(mode);
    setState(() {
      _isDropdownOpen = false;
    });
  }

  @css
  static List<StyleRule> get styles => [
    css('.enhanced-theme-toggle-container', [
      css('&').styles(
        display: Display.inlineBlock,
        raw: {'position': 'relative'},
      ),
    ]),
    css('.theme-dropdown', [
      css('&').styles(
        raw: {'position': 'relative', 'display': 'inline-block', 'min-width': '110px'},
      ),
    ]),
    css('.dropdown-trigger', [
      css('&').styles(
        display: Display.flex,
        padding: Padding.symmetric(horizontal: 10.px, vertical: 6.px),
        border: Border.all(color: Color('hsl(var(--border))'), width: 1.px, style: BorderStyle.solid),
        radius: BorderRadius.circular(8.px),
        cursor: Cursor.pointer,
        transition: Transition('all', duration: 150.ms),
        justifyContent: JustifyContent.spaceBetween,
        alignItems: AlignItems.center,
        color: Color('var(--text-color)'),
        fontSize: 0.8125.rem,
        fontWeight: FontWeight.w500,
        backgroundColor: Colors.transparent,
        raw: {'gap': '6px'},
      ),
      css('.dark &').styles(
        color: Colors.white,
        backgroundColor: Color('rgba(255,255,255,0.05)'),
        raw: {
          'border-color': 'rgba(255,255,255,0.1)',
        },
      ),
      css('&:hover').styles(
        backgroundColor: Color('rgba(0,0,0,0.05)'),
      ),
      css('.dark &:hover').styles(
        backgroundColor: Color('rgba(255,255,255,0.1)'),
      ),
    ]),
    css('.dropdown-backdrop', [
      css('&').styles(
        raw: {
          'position': 'fixed',
          'top': '0',
          'left': '0',
          'right': '0',
          'bottom': '0',
          'z-index': '999',
        },
      ),
    ]),
    css('.dropdown-options', [
      css('&').styles(
        padding: Padding.all(4.px),
        border: Border.all(color: Color('#e4e4e7'), width: 1.px, style: BorderStyle.solid),
        radius: BorderRadius.circular(8.px),
        backgroundColor: Colors.white,
        raw: {
          'position': 'absolute',
          'top': '100%',
          'left': '0',
          'right': '0',
          'z-index': '1000',
          'margin-top': '4px',
          'box-shadow': '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)',
        },
      ),
      css('.dark &').styles(
        backgroundColor: Color('#18181b'),
        raw: {
          'border-color': '#27272a',
        },
      ),
    ]),
    css('.dropdown-option', [
      css('&').styles(
        display: Display.flex,
        padding: Padding.symmetric(horizontal: 8.px, vertical: 6.px),
        radius: BorderRadius.circular(6.px),
        cursor: Cursor.pointer,
        transition: Transition('all', duration: 150.ms),
        alignItems: AlignItems.center,
        color: Color('#71717a'),
        fontSize: 0.8125.rem,
        fontWeight: FontWeight.w500,
        backgroundColor: Colors.transparent,
        raw: {'gap': '8px'},
      ),
      css('.dark &').styles(
        color: Color('#a1a1aa'),
      ),
      css('&:hover').styles(
        color: Color('#18181b'),
        backgroundColor: Color('#f4f4f5'),
      ),
      css('.dark &:hover').styles(
        color: Colors.white,
        backgroundColor: Color('#27272a'),
      ),
      css('&.active').styles(
        color: Color('#18181b'),
        backgroundColor: Color('#f4f4f5'),
      ),
      css('.dark &.active').styles(
        color: Colors.white,
        backgroundColor: Color('#27272a'),
      ),
    ]),
    css('.theme-label', [
      css('&').styles(
        fontSize: 0.8125.rem,
      ),
    ]),
    // Chevron rotation
    css('.theme-dropdown.open .dropdown-trigger svg:last-child', [
      css('&').styles(
        raw: {'transform': 'rotate(180deg)'},
      ),
    ]),
  ];
}

class MonitorIcon extends StatelessComponent {
  const MonitorIcon({required this.size, super.key});

  final double size;

  @override
  Component build(BuildContext context) {
    return svg(
      viewBox: '0 0 24 24',
      attributes: {'fill': 'currentColor'},
      styles: Styles(width: size.px, height: size.px),
      [
        path(
          d: 'M21 2H3c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h7v2H8v2h8v-2h-2v-2h7c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm0 14H3V4h18v12z',
          [],
        ),
      ],
    );
  }
}

class MoonIcon extends StatelessComponent {
  const MoonIcon({required this.size, super.key});

  final double size;

  @override
  Component build(BuildContext context) {
    return svg(
      viewBox: '0 0 24 24',
      attributes: {'fill': 'currentColor'},
      styles: Styles(width: size.px, height: size.px),
      [
        path(
          d: 'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 17.93c-3.94-.49-7-3.85-7-7.93 0-.62.08-1.21.21-1.79L9 15v1c0 1.1.9 2 2 2v1.93zm6.9-2.54c-.26-.81-1-1.39-1.9-1.39h-1v-3c0-.55-.45-1-1-1H8v-2h2c.55 0 1-.45 1-1V7h2c1.1 0 2-.9 2-2v-.41c2.93 1.19 5 4.06 5 7.41 0 2.08-.8 3.97-2.1 5.39z',
          [],
        ),
      ],
    );
  }
}

class SunIcon extends StatelessComponent {
  const SunIcon({required this.size, super.key});

  final double size;

  @override
  Component build(BuildContext context) {
    return svg(
      viewBox: '0 0 24 24',
      attributes: {'fill': 'currentColor'},
      styles: Styles(width: size.px, height: size.px),
      [
        path(
          d: 'M12 7c-2.76 0-5 2.24-5 5s2.24 5 5 5 5-2.24 5-5-2.24-5-5-5zM2 13h2c.55 0 1-.45 1-1s-.45-1-1-1H2c-.55 0-1 .45-1 1s.45 1 1 1zm18 0h2c.55 0 1-.45 1-1s-.45-1-1-1h-2c-.55 0-1 .45-1 1s.45 1 1 1zM11 2v2c0 .55.45 1 1 1s1-.45 1-1V2c0-.55-.45-1-1-1s-1 .45-1 1zm0 18v2c0 .55.45 1 1 1s1-.45 1-1v-2c0-.55-.45-1-1-1s-1 .45-1 1zM5.99 4.58c-.39-.39-1.03-.39-1.41 0-.39.39-.39 1.03 0 1.41l1.06 1.06c.39.39 1.03.39 1.41 0s.39-1.03 0-1.41L5.99 4.58zm12.37 12.37c-.39-.39-1.03-.39-1.41 0-.39.39-.39 1.03 0 1.41l1.06 1.06c.39.39 1.03.39 1.41 0 .39-.39.39-1.03 0-1.41l-1.06-1.06zm-12.37 0c.39.39.39 1.03 0 1.41L4.93 19.5c-.39.39-1.03.39-1.41 0-.39-.39-.39-1.03 0-1.41l1.06-1.06c.39-.39 1.03-.39 1.41 0zM18.01 4.58c.39-.39 1.03-.39 1.41 0 .39.39.39 1.03 0 1.41L18.36 7.05c-.39.39-1.03.39-1.41 0-.39-.39-.39-1.03 0-1.41l1.06-1.06z',
          [],
        ),
      ],
    );
  }
}

class ChevronDownIcon extends StatelessComponent {
  const ChevronDownIcon({required this.size, super.key});

  final double size;

  @override
  Component build(BuildContext context) {
    return svg(
      viewBox: '0 0 24 24',
      attributes: {'fill': 'currentColor', 'stroke': 'none'},
      styles: Styles(width: size.px, height: size.px),
      [
        path(
          d: 'M7 10l5 5 5-5z',
          [],
        ),
      ],
    );
  }
}
