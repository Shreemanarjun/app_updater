enum UpdaterOverlayType {
  killSwitch,
  maintenance,
  forcedUpdate,
  flexibleUpdate,
  shorebirdPatch,
}

class UpdaterOverlayConfig {
  final UpdaterOverlayType type;
  final String title;
  final String message;
  final String? storeUrl;
  final String? releaseNotes;
  final bool isPermanent;
  final String? latestVersion;
  final String? currentVersion;
  final String? endTime;
  final String? actionLabel;

  const UpdaterOverlayConfig({
    required this.type,
    required this.title,
    required this.message,
    this.storeUrl,
    this.releaseNotes,
    this.isPermanent = false,
    this.latestVersion,
    this.currentVersion,
    this.endTime,
    this.actionLabel,
  });

  factory UpdaterOverlayConfig.killSwitch({required String message}) => UpdaterOverlayConfig(
    type: UpdaterOverlayType.killSwitch,
    title: "Service Terminated",
    message: message,
    isPermanent: true,
  );

  factory UpdaterOverlayConfig.maintenance({required String message, String? endTime}) => UpdaterOverlayConfig(
    type: UpdaterOverlayType.maintenance,
    title: "Under Maintenance",
    message: message,
    isPermanent: true,
    endTime: endTime,
  );

  factory UpdaterOverlayConfig.update({
    required bool isForced,
    required String storeUrl,
    required String releaseNotes,
    String? latestVersion,
    String? currentVersion,
  }) => UpdaterOverlayConfig(
    type: isForced ? UpdaterOverlayType.forcedUpdate : UpdaterOverlayType.flexibleUpdate,
    title: isForced ? "Required Update" : "New Update",
    message: isForced
        ? "A critical update is required to continue using the application."
        : "A new version of Panha is available with new features and fixes.",
    storeUrl: storeUrl,
    releaseNotes: releaseNotes,
    isPermanent: isForced,
    latestVersion: latestVersion,
    currentVersion: currentVersion,
    actionLabel: "Update Now",
  );

  factory UpdaterOverlayConfig.shorebird({
    required String patchNotes,
    required bool isHotfix,
    int? patchNumber,
  }) {
    return UpdaterOverlayConfig(
      type: UpdaterOverlayType.shorebirdPatch,
      title: isHotfix ? "Critical Hotfix" : "System Patch",
      message: patchNotes.isNotEmpty
          ? patchNotes
          : "A new optimization is ready to be applied. Download now for a better experience.",
      isPermanent: isHotfix,
      latestVersion: patchNumber?.toString(),
      actionLabel: "Download & Apply",
    );
  }
}
