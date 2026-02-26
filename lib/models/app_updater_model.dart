class AppUpdaterModel {
  final PlatformConfig android;
  final PlatformConfig ios;
  final GlobalConfig global;

  AppUpdaterModel({
    required this.android,
    required this.ios,
    required this.global,
  });

  factory AppUpdaterModel.fromJson(Map<String, dynamic> json) {
    return AppUpdaterModel(
      android: PlatformConfig.fromJson(json['android']),
      ios: PlatformConfig.fromJson(json['ios']),
      global: GlobalConfig.fromJson(json['global']),
    );
  }

  Map<String, dynamic> toJson() => {
    'android': android.toJson(),
    'ios': ios.toJson(),
    'global': global.toJson(),
  };
}

class PlatformConfig {
  final VersionConfig version;
  final PatchConfig patch;
  final UpdateConfig update;
  final String storeUrl;

  PlatformConfig({
    required this.version,
    required this.patch,
    required this.update,
    required this.storeUrl,
  });

  factory PlatformConfig.fromJson(Map<String, dynamic> json) {
    return PlatformConfig(
      version: VersionConfig.fromJson(json['version']),
      patch: PatchConfig.fromJson(json['patch']),
      update: UpdateConfig.fromJson(json['update']),
      storeUrl: json['store_url'],
    );
  }

  Map<String, dynamic> toJson() => {
    'version': version.toJson(),
    'patch': patch.toJson(),
    'update': update.toJson(),
    'store_url': storeUrl,
  };
}

class VersionConfig {
  final VersionDetail min;
  final VersionDetail recommended;
  final VersionDetail latest;

  VersionConfig({
    required this.min,
    required this.recommended,
    required this.latest,
  });

  factory VersionConfig.fromJson(Map<String, dynamic> json) {
    return VersionConfig(
      min: VersionDetail.fromJson(json['min']),
      recommended: VersionDetail.fromJson(json['recommended']),
      latest: VersionDetail.fromJson(json['latest']),
    );
  }

  Map<String, dynamic> toJson() => {
    'min': min.toJson(),
    'recommended': recommended.toJson(),
    'latest': latest.toJson(),
  };
}

class VersionDetail {
  final String semver;
  final int build;

  VersionDetail({required this.semver, required this.build});

  factory VersionDetail.fromJson(Map<String, dynamic> json) {
    return VersionDetail(
      semver: json['semver'],
      build: json['build'],
    );
  }

  Map<String, dynamic> toJson() => {
    'semver': semver,
    'build': build,
  };
}

class PatchConfig {
  final int number;
  final int minAppBuild;
  final int maxAppBuild;
  final bool hotfix;
  final String notes;

  PatchConfig({
    required this.number,
    required this.minAppBuild,
    required this.maxAppBuild,
    required this.hotfix,
    required this.notes,
  });

  factory PatchConfig.fromJson(Map<String, dynamic> json) {
    return PatchConfig(
      number: json['number'],
      minAppBuild: json['min_app_build'],
      maxAppBuild: json['max_app_build'],
      hotfix: json['hotfix'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
    'number': number,
    'min_app_build': minAppBuild,
    'max_app_build': maxAppBuild,
    'hotfix': hotfix,
    'notes': notes,
  };
}

class UpdateConfig {
  final int forceBelowBuild;
  final int flexibleBelowBuild;

  UpdateConfig({
    required this.forceBelowBuild,
    required this.flexibleBelowBuild,
  });

  factory UpdateConfig.fromJson(Map<String, dynamic> json) {
    return UpdateConfig(
      forceBelowBuild: json['force_below_build'],
      flexibleBelowBuild: json['flexible_below_build'],
    );
  }

  Map<String, dynamic> toJson() => {
    'force_below_build': forceBelowBuild,
    'flexible_below_build': flexibleBelowBuild,
  };
}

class GlobalConfig {
  final bool killSwitch;
  final MaintenanceConfig maintenance;
  final Map<String, String> releaseNotes;

  GlobalConfig({
    required this.killSwitch,
    required this.maintenance,
    required this.releaseNotes,
  });

  factory GlobalConfig.fromJson(Map<String, dynamic> json) {
    return GlobalConfig(
      killSwitch: json['kill_switch'],
      maintenance: MaintenanceConfig.fromJson(json['maintenance']),
      releaseNotes: Map<String, String>.from(json['release_notes']),
    );
  }

  Map<String, dynamic> toJson() => {
    'kill_switch': killSwitch,
    'maintenance': maintenance.toJson(),
    'release_notes': releaseNotes,
  };
}

class MaintenanceConfig {
  final bool active;
  final Map<String, String> message;
  final String? endTime;

  MaintenanceConfig({
    required this.active,
    required this.message,
    this.endTime,
  });

  factory MaintenanceConfig.fromJson(Map<String, dynamic> json) {
    return MaintenanceConfig(
      active: json['active'],
      message: Map<String, String>.from(json['message']),
      endTime: json['end_time'],
    );
  }

  Map<String, dynamic> toJson() => {
    'active': active,
    'message': message,
    'end_time': endTime,
  };
}
