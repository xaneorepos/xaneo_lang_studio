import 'dart:convert';

/// Metadata & definitions for a single key from canonical manifest.v1.json
class ManifestKeyDef {
  final String key;
  final String scope;
  final String type;
  final List<String> placeholders;
  final int maxLength;
  final bool securityCritical;
  final String fallbackRu;
  final String description;

  ManifestKeyDef({
    required this.key,
    required this.scope,
    required this.type,
    required this.placeholders,
    required this.maxLength,
    required this.securityCritical,
    required this.fallbackRu,
    required this.description,
  });

  factory ManifestKeyDef.fromJson(String key, Map<String, dynamic> json) {
    return ManifestKeyDef(
      key: key,
      scope: json['scope']?.toString() ?? 'common',
      type: json['type']?.toString() ?? 'text',
      placeholders: (json['placeholders'] as List?)?.map((e) => e.toString()).toList() ?? [],
      maxLength: json['max_length'] is int ? json['max_length'] : 4096,
      securityCritical: json['security_critical'] == true,
      fallbackRu: json['fallback_ru']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}

/// Language Pack Document model
class LanguagePack {
  int schemaVersion;
  String locale;
  String name;
  String nativeName;
  String direction;
  String fallbackLocale;
  String author;
  String version;
  String description;
  Map<String, String> strings;

  LanguagePack({
    this.schemaVersion = 1,
    this.locale = 'custom-lang',
    this.name = 'New Custom Language',
    this.nativeName = 'Custom Language',
    this.direction = 'ltr',
    this.fallbackLocale = 'ru',
    this.author = '',
    this.version = '1.0.0',
    this.description = '',
    Map<String, String>? strings,
  }) : strings = strings ?? {};

  LanguagePack copyWith({
    int? schemaVersion,
    String? locale,
    String? name,
    String? nativeName,
    String? direction,
    String? fallbackLocale,
    String? author,
    String? version,
    String? description,
    Map<String, String>? strings,
  }) {
    return LanguagePack(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      locale: locale ?? this.locale,
      name: name ?? this.name,
      nativeName: nativeName ?? this.nativeName,
      direction: direction ?? this.direction,
      fallbackLocale: fallbackLocale ?? this.fallbackLocale,
      author: author ?? this.author,
      version: version ?? this.version,
      description: description ?? this.description,
      strings: strings ?? Map.from(this.strings),
    );
  }

  factory LanguagePack.fromJson(Map<String, dynamic> json) {
    final rawStrings = json['strings'];
    final Map<String, String> parsedStrings = {};
    if (rawStrings is Map) {
      rawStrings.forEach((k, v) {
        if (k != null && v != null) {
          parsedStrings[k.toString()] = v.toString();
        }
      });
    }

    return LanguagePack(
      schemaVersion: json['schema_version'] is int ? json['schema_version'] : 1,
      locale: json['locale']?.toString() ?? 'custom-lang',
      name: json['name']?.toString() ?? 'Custom Language',
      nativeName: json['native_name']?.toString() ?? json['name']?.toString() ?? '',
      direction: json['direction']?.toString().toLowerCase() == 'rtl' ? 'rtl' : 'ltr',
      fallbackLocale: json['fallback_locale']?.toString() ?? 'ru',
      author: json['author']?.toString() ?? '',
      version: json['version']?.toString() ?? '1.0.0',
      description: json['description']?.toString() ?? '',
      strings: parsedStrings,
    );
  }

  Map<String, dynamic> toJson({bool includeExtraMeta = true}) {
    final map = <String, dynamic>{
      'schema_version': schemaVersion,
      'locale': locale,
      'name': name,
      'native_name': nativeName,
      'direction': direction,
      'fallback_locale': fallbackLocale,
    };
    if (includeExtraMeta) {
      if (author.isNotEmpty) map['author'] = author;
      if (version.isNotEmpty) map['version'] = version;
      if (description.isNotEmpty) map['description'] = description;
    }
    map['strings'] = strings;
    return map;
  }

  String toFormattedJson() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }
}

/// Validation result with detailed errors and warnings
class ValidationReport {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final int totalKeys;
  final int translatedKeys;
  final int missingKeys;

  ValidationReport({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.totalKeys,
    required this.translatedKeys,
    required this.missingKeys,
  });

  double get completionPercentage =>
      totalKeys == 0 ? 0.0 : (translatedKeys / totalKeys) * 100;
}
