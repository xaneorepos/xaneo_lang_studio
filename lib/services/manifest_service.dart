import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/language_pack.dart';

class ManifestService {
  static final ManifestService instance = ManifestService._();
  ManifestService._();

  Map<String, dynamic>? _rawManifest;
  final Map<String, ManifestKeyDef> _keys = {};
  final List<String> _categories = [];
  final Map<String, List<String>> _keysByCategory = {};

  bool get isLoaded => _rawManifest != null;
  Map<String, ManifestKeyDef> get keys => _keys;
  List<String> get categories => _categories;
  Map<String, List<String>> get keysByCategory => _keysByCategory;
  int get totalKeysCount => _keys.length;

  Future<void> loadManifest() async {
    if (isLoaded) return;
    try {
      final jsonString = await rootBundle.loadString('assets/manifest.v1.json');
      _rawManifest = jsonDecode(jsonString) as Map<String, dynamic>;
      _parseKeys();
    } catch (e) {
      debugPrint('Failed to load manifest: $e');
    }
  }

  void _parseKeys() {
    _keys.clear();
    _categories.clear();
    _keysByCategory.clear();

    final rawKeys = _rawManifest?['keys'];
    if (rawKeys is! Map) return;

    final categorySet = <String>{};

    rawKeys.forEach((k, v) {
      if (k is String && v is Map<String, dynamic>) {
        final def = ManifestKeyDef.fromJson(k, v);
        _keys[k] = def;

        // Group into semantic categories
        String category = 'common';
        if (k.contains('.')) {
          category = k.split('.').first;
        } else if (def.scope.isNotEmpty) {
          category = def.scope;
        }

        categorySet.add(category);
        _keysByCategory.putIfAbsent(category, () => []).add(k);
      }
    });

    _categories.addAll(categorySet.toList()..sort());
    _categories.insert(0, 'all');
  }

  ValidationReport validatePack(LanguagePack pack) {
    final List<String> errors = [];
    final List<String> warnings = [];

    if (pack.locale.trim().isEmpty) {
      errors.add('Код языка (locale) не может быть пустым');
    } else if (!RegExp(r'^[a-z]{2,3}(-[a-zA-Z0-9_-]+)?$').hasMatch(pack.locale)) {
      warnings.add('Код языка "${pack.locale}" не соответствует стандарту BCP 47 (например: ru-pirate, en-cyber)');
    }

    if (pack.name.trim().isEmpty) {
      errors.add('Название языка не может быть пустым');
    }

    int translatedCount = 0;
    int missingCount = 0;

    _keys.forEach((key, def) {
      final value = pack.strings[key];
      if (value != null && value.trim().isNotEmpty) {
        translatedCount++;

        // Check placeholders
        for (final ph in def.placeholders) {
          if (!value.contains(ph)) {
            warnings.add('Ключ "$key": отсутствует плейсхолдер $ph в переводе');
          }
        }

        // Check max length
        if (value.length > def.maxLength) {
          errors.add('Ключ "$key": превышена максимальная длина (${value.length} > ${def.maxLength})');
        }
      } else {
        missingCount++;
        if (def.securityCritical) {
          errors.add('Критически важный ключ безопасности "$key" не переведён');
        }
      }
    });

    // Check unknown keys
    pack.strings.forEach((key, value) {
      if (!_keys.containsKey(key)) {
        warnings.add('Неизвестный ключ "$key" отсутствует в манифесте v1');
      }
    });

    final isValid = errors.isEmpty;

    return ValidationReport(
      isValid: isValid,
      errors: errors,
      warnings: warnings,
      totalKeys: _keys.length,
      translatedKeys: translatedCount,
      missingKeys: missingCount,
    );
  }
}
