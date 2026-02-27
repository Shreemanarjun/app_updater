import 'package:flutter/material.dart';
import '../models/updater_config.dart';

class FlutterUpdaterOverlay extends StatelessWidget {
  const FlutterUpdaterOverlay({
    required this.config,
    required this.onClose,
    this.onAction,
    this.isDark = true,
    super.key,
  });

  final UpdaterOverlayConfig config;
  final VoidCallback onClose;
  final VoidCallback? onAction;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isFullscreen = config.type == UpdaterOverlayType.killSwitch || config.type == UpdaterOverlayType.maintenance;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Theme(
        data: isDark
            ? ThemeData.dark().copyWith(
                cardColor: const Color(0xFF18181B),
                scaffoldBackgroundColor: const Color(0xFF18181B),
              )
            : ThemeData.light().copyWith(
                cardColor: Colors.white,
                scaffoldBackgroundColor: const Color(0xFFF4F4F5),
              ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth.isFinite ? constraints.maxWidth : 300.0;
            final h = constraints.maxHeight.isFinite ? constraints.maxHeight : 580.0;
            return SizedBox(
              width: w,
              height: h,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Semi-transparent backdrop
                  GestureDetector(
                    onTap: config.isPermanent ? null : onClose,
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.45),
                    ),
                  ),
                  // Overlay content
                  isFullscreen
                      ? _FullscreenOverlay(config: config)
                      : Center(
                          child: _DialogOverlay(
                            config: config,
                            onClose: onClose,
                            onAction: onAction,
                          ),
                        ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FullscreenOverlay extends StatelessWidget {
  const _FullscreenOverlay({required this.config});

  final UpdaterOverlayConfig config;

  @override
  Widget build(BuildContext context) {
    final isKillSwitch = config.type == UpdaterOverlayType.killSwitch;
    final color = isKillSwitch ? const Color(0xFFEF4444) : const Color(0xFFF97316);
    final icon = isKillSwitch ? Icons.block : Icons.construction;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 80, color: color),
          ),
          const SizedBox(height: 32),
          Text(
            config.title,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            config.message,
            style: TextStyle(
              fontSize: 18,
              color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF52525B),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (config.endTime != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Text(
                "Estimated Back By: ${config.endTime!}",
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DialogOverlay extends StatelessWidget {
  const _DialogOverlay({
    required this.config,
    required this.onClose,
    this.onAction,
  });

  final UpdaterOverlayConfig config;
  final VoidCallback onClose;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color iconColor;
    IconData iconData;

    switch (config.type) {
      case UpdaterOverlayType.shorebirdPatch:
        iconColor = config.isPermanent ? const Color(0xFF7C3AED) : const Color(0xFF4F46E5);
        iconData = config.isPermanent ? Icons.bolt : Icons.auto_awesome;
        break;
      case UpdaterOverlayType.forcedUpdate:
      case UpdaterOverlayType.flexibleUpdate:
      default:
        iconColor = const Color(0xFF3B82F6);
        iconData = config.type == UpdaterOverlayType.forcedUpdate ? Icons.system_update : Icons.update;
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(iconData, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF18181B),
                      ),
                    ),
                    if (config.latestVersion != null)
                      Text(
                        config.type == UpdaterOverlayType.shorebirdPatch
                            ? "Patch #${config.latestVersion}"
                            : "v${config.latestVersion}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: iconColor,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            config.message,
            style: TextStyle(
              color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF52525B),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          if (config.currentBuild != null || config.latestBuild != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // From
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'CURRENT',
                        style: TextStyle(color: Color(0xFF71717A), fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        config.type == UpdaterOverlayType.shorebirdPatch
                            ? "Build ${config.currentBuild ?? '?'}${config.currentPatch != null && config.currentPatch! > 0 ? ' (Patch ${config.currentPatch})' : ''}"
                            : config.currentVersion != null
                            ? "v${config.currentVersion} (${config.currentBuild ?? '?'})"
                            : "Build ${config.currentBuild ?? '?'}",
                        style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Icon(Icons.arrow_forward, size: 14, color: Color(0xFF52525B)),
                  ),
                  // To
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        config.type == UpdaterOverlayType.shorebirdPatch ? 'PATCH' : 'TARGET',
                        style: TextStyle(
                          color: iconColor.withValues(alpha: 0.8),
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        config.type == UpdaterOverlayType.shorebirdPatch
                            ? "Build ${config.currentBuild ?? '?'}${config.latestVersion != null ? ' (Patch ${config.latestVersion})' : ''}"
                            : "v${config.latestVersion} (${config.latestBuild ?? '?'})",
                        style: TextStyle(
                          color: iconColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (config.releaseNotes?.isNotEmpty ?? false) ...[
            Text(
              config.type == UpdaterOverlayType.shorebirdPatch ? "Changes:" : "What's New:",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF18181B),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 150,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: SingleChildScrollView(
                child: Text(
                  config.releaseNotes!,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: Color(0xFF71717A),
                    height: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!config.isPermanent)
                TextButton(
                  onPressed: onClose,
                  child: const Text(
                    "Later",
                    style: TextStyle(color: Color(0xFF71717A)),
                  ),
                ),
              const Spacer(),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  config.actionLabel ?? "Update",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
