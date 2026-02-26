import 'package:flutter/material.dart';
import '../models/updater_config.dart';

class FlutterUpdaterOverlay extends StatelessWidget {
  const FlutterUpdaterOverlay({
    required this.config,
    required this.onClose,
    this.onAction,
    super.key,
  });

  final UpdaterOverlayConfig config;
  final VoidCallback onClose;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final isFullscreen = config.type == UpdaterOverlayType.killSwitch || config.type == UpdaterOverlayType.maintenance;

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF09090B),
        cardColor: const Color(0xFF18181B),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Backdrop
            GestureDetector(
              onTap: config.isPermanent ? null : onClose,
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
            // Content
            Center(
              child: isFullscreen
                  ? _FullscreenOverlay(config: config)
                  : _DialogOverlay(
                      config: config,
                      onClose: onClose,
                      onAction: onAction,
                    ),
            ),
          ],
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

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF18181B),
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
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFFA1A1AA),
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
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
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
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
            style: const TextStyle(
              color: Color(0xFFA1A1AA),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          if (config.currentVersion != null &&
              config.latestVersion != null &&
              config.type != UpdaterOverlayType.shorebirdPatch) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    config.currentVersion!,
                    style: const TextStyle(color: Color(0xFF71717A), fontSize: 11),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(Icons.arrow_forward, size: 12, color: Color(0xFF52525B)),
                  ),
                  Text(
                    config.latestVersion!,
                    style: const TextStyle(
                      color: Color(0xFF3B82F6),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (config.releaseNotes?.isNotEmpty ?? false) ...[
            Text(
              config.type == UpdaterOverlayType.shorebirdPatch ? "Changes:" : "What's New:",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 150,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
