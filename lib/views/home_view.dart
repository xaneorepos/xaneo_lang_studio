import 'package:flutter/material.dart';
import '../models/language_pack.dart';
import '../services/manifest_service.dart';
import '../services/file_service.dart';
import '../theme/app_theme.dart';
import '../widgets/string_editor_card.dart';
import '../widgets/pack_meta_dialog.dart';
import '../widgets/validation_dialog.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ManifestService _manifest = ManifestService.instance;
  final FileService _fileService = FileService.instance;

  LanguagePack _currentPack = LanguagePack();
  String _selectedCategory = 'all';
  String _searchQuery = '';
  bool _showOnlyMissing = false;
  bool _isLoading = true;
  String? _loadedFilePath;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initManifest();
  }

  Future<void> _initManifest() async {
    await _manifest.loadManifest();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filteredKeyNames {
    final categoryKeys = _selectedCategory == 'all'
        ? _manifest.keys.keys.toList()
        : (_manifest.keysByCategory[_selectedCategory] ?? []);

    return categoryKeys.where((key) {
      final keyDef = _manifest.keys[key];
      if (keyDef == null) return false;

      final translation = _currentPack.strings[key] ?? '';
      final isMissing = translation.trim().isEmpty;

      if (_showOnlyMissing && !isMissing) return false;

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesKey = key.toLowerCase().contains(query);
        final matchesFallback = keyDef.fallbackRu.toLowerCase().contains(query);
        final matchesTrans = translation.toLowerCase().contains(query);
        if (!matchesKey && !matchesFallback && !matchesTrans) return false;
      }

      return true;
    }).toList();
  }

  int get _totalTranslatedCount {
    int count = 0;
    for (final k in _manifest.keys.keys) {
      if ((_currentPack.strings[k] ?? '').trim().isNotEmpty) {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.pureBlack,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.pureWhite),
        ),
      );
    }

    final totalKeys = _manifest.totalKeysCount;
    final translated = _totalTranslatedCount;
    final percentage = totalKeys == 0 ? 0.0 : (translated / totalKeys) * 100;
    final filteredKeys = _filteredKeyNames;

    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      body: Column(
        children: [
          // Top Navigation Bar
          _buildTopBar(translated, totalKeys, percentage),
          const Divider(),

          // Main Workspace Layout: Categories Sidebar + Editor
          Expanded(
            child: Row(
              children: [
                // Left Sidebar: Categories + Stats
                _buildSidebar(),
                const VerticalDivider(),

                // Right Area: Filter Bar + Virtualized List of Key Cards
                Expanded(
                  child: Column(
                    children: [
                      _buildFilterBar(filteredKeys.length),
                      const Divider(),
                      Expanded(
                        child: filteredKeys.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.all(20),
                                itemCount: filteredKeys.length,
                                itemBuilder: (context, index) {
                                  final keyName = filteredKeys[index];
                                  final keyDef = _manifest.keys[keyName]!;
                                  final currentVal = _currentPack.strings[keyName] ?? '';

                                  return StringEditorCard(
                                    key: ValueKey(keyName),
                                    keyDef: keyDef,
                                    currentValue: currentVal,
                                    onChanged: (newVal) {
                                      setState(() {
                                        if (newVal.trim().isEmpty) {
                                          _currentPack.strings.remove(keyName);
                                        } else {
                                          _currentPack.strings[keyName] = newVal;
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(int translated, int totalKeys, double percentage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: AppTheme.darkSurface,
      child: Row(
        children: [
          // App Title
          const Icon(Icons.language, color: AppTheme.pureWhite, size: 22),
          const SizedBox(width: 10),
          Text(
            'XANEO LANG STUDIO',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(width: 16),
          // Current Pack Name Badge
          InkWell(
            onTap: _openMetaDialog,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                border: Border.all(color: AppTheme.cardBorder),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Text(
                    '${_currentPack.nativeName.isNotEmpty ? _currentPack.nativeName : _currentPack.name} [${_currentPack.locale}]',
                    style: const TextStyle(
                      color: AppTheme.pureWhite,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.edit, size: 12, color: AppTheme.mutedGray),
                ],
              ),
            ),
          ),
          const Spacer(),

          // Progress indicator in navbar
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Прогресс: $translated / $totalKeys (${percentage.toStringAsFixed(1)}%)',
                style: const TextStyle(color: AppTheme.lightGray, fontSize: 11),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 140,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: percentage / 100.0,
                    backgroundColor: AppTheme.subtleGray,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.pureWhite),
                    minHeight: 4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),

          // Actions
          OutlinedButton.icon(
            icon: const Icon(Icons.folder_open, size: 16),
            label: const Text('Открыть'),
            onPressed: _openPack,
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.check_circle_outline, size: 16),
            label: const Text('Валидация'),
            onPressed: _validatePack,
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.save_alt, size: 16),
            label: const Text('Экспорт JSON'),
            onPressed: _savePack,
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 240,
      color: AppTheme.darkSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.category, size: 16, color: AppTheme.mutedGray),
                const SizedBox(width: 8),
                Text(
                  'МОДУЛИ И КАТЕГОРИИ',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _manifest.categories.length,
              itemBuilder: (context, index) {
                final category = _manifest.categories[index];
                final isSelected = _selectedCategory == category;
                final count = category == 'all'
                    ? _manifest.totalKeysCount
                    : (_manifest.keysByCategory[category]?.length ?? 0);

                return ListTile(
                  dense: true,
                  selected: isSelected,
                  selectedTileColor: AppTheme.cardDark,
                  leading: Icon(
                    category == 'all' ? Icons.apps : Icons.folder_outlined,
                    size: 16,
                    color: isSelected ? AppTheme.pureWhite : AppTheme.mutedGray,
                  ),
                  title: Text(
                    category.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? AppTheme.pureWhite : AppTheme.lightGray,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.subtleGray : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected ? AppTheme.pureWhite : AppTheme.mutedGray,
                      ),
                    ),
                  ),
                  onTap: () => setState(() => _selectedCategory = category),
                );
              },
            ),
          ),
          const Divider(),
          // Quick Autofill actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.auto_fix_high, size: 14),
                  label: const Text('Заполнить эталоном (RU)', style: TextStyle(fontSize: 11)),
                  onPressed: _autofillWithRussianFallback,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(int matchCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: AppTheme.darkSurface,
      child: Row(
        children: [
          // Search Box
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Поиск по ключу, русскому оригиналу или переводу...',
                prefixIcon: Icon(Icons.search, size: 18, color: AppTheme.mutedGray),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
            ),
          ),
          const SizedBox(width: 16),

          // Show Only Missing Toggle
          FilterChip(
            label: const Text('Только непереведённые'),
            selected: _showOnlyMissing,
            onSelected: (val) => setState(() => _showOnlyMissing = val),
            selectedColor: AppTheme.pureWhite,
            checkmarkColor: AppTheme.pureBlack,
            labelStyle: TextStyle(
              color: _showOnlyMissing ? AppTheme.pureBlack : AppTheme.lightGray,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            backgroundColor: AppTheme.cardDark,
            side: const BorderSide(color: AppTheme.cardBorder),
          ),
          const SizedBox(width: 16),

          // Match Count
          Text(
            'Найдено: $matchCount',
            style: const TextStyle(color: AppTheme.mutedGray, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 48, color: AppTheme.subtleGray),
          const SizedBox(height: 12),
          Text(
            'Ничего не найдено',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          const Text(
            'Попробуйте изменить запрос поиска или сбросить фильтр',
            style: TextStyle(color: AppTheme.mutedGray, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _openMetaDialog() {
    showDialog(
      context: context,
      builder: (context) => PackMetaDialog(
        pack: _currentPack,
        onSave: (updated) => setState(() => _currentPack = updated),
      ),
    );
  }

  Future<void> _openPack() async {
    final pack = await _fileService.openPackFile();
    if (pack != null && mounted) {
      setState(() {
        _currentPack = pack;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Пакет "${pack.name}" успешно загружен!')),
      );
    }
  }

  void _validatePack() {
    final report = _manifest.validatePack(_currentPack);
    showDialog(
      context: context,
      builder: (context) => ValidationDialog(report: report),
    );
  }

  Future<void> _savePack() async {
    final path = await _fileService.savePackToFile(_currentPack, targetPath: _loadedFilePath);
    if (path != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Файл успешно сохранён: $path')),
      );
    }
  }

  void _autofillWithRussianFallback() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text('Заполнить недостающие ключи эталоном (RU)?'),
        content: const Text(
          'Все непереведённые ключи будут автоматически заполнены текстом из официального русского манифеста. Существующие переводы не будут перезаписаны.',
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              int filled = 0;
              setState(() {
                _manifest.keys.forEach((key, def) {
                  if (!_currentPack.strings.containsKey(key) ||
                      _currentPack.strings[key]!.trim().isEmpty) {
                    _currentPack.strings[key] = def.fallbackRu;
                    filled++;
                  }
                });
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Заполнено $filled ключей эталонным текстом')),
              );
            },
            child: const Text('Заполнить'),
          ),
        ],
      ),
    );
  }
}
