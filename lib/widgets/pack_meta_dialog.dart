import 'package:flutter/material.dart';
import '../models/language_pack.dart';
import '../theme/app_theme.dart';

class PackMetaDialog extends StatefulWidget {
  final LanguagePack pack;
  final ValueChanged<LanguagePack> onSave;

  const PackMetaDialog({
    super.key,
    required this.pack,
    required this.onSave,
  });

  @override
  State<PackMetaDialog> createState() => _PackMetaDialogState();
}

class _PackMetaDialogState extends State<PackMetaDialog> {
  late TextEditingController _nameController;
  late TextEditingController _nativeNameController;
  late TextEditingController _localeController;
  late TextEditingController _authorController;
  late TextEditingController _versionController;
  late TextEditingController _descController;
  String _direction = 'ltr';
  String _fallbackLocale = 'ru';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pack.name);
    _nativeNameController = TextEditingController(text: widget.pack.nativeName);
    _localeController = TextEditingController(text: widget.pack.locale);
    _authorController = TextEditingController(text: widget.pack.author);
    _versionController = TextEditingController(text: widget.pack.version);
    _descController = TextEditingController(text: widget.pack.description);
    _direction = widget.pack.direction;
    _fallbackLocale = widget.pack.fallbackLocale;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nativeNameController.dispose();
    _localeController.dispose();
    _authorController.dispose();
    _versionController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.cardDark,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tune, color: AppTheme.pureWhite, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Параметры языкового пакета',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Название языка (English)',
                        hintText: 'e.g. Tsukishiro Agent',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nativeNameController,
                      decoration: const InputDecoration(
                        labelText: 'Оригинальное название (Native Name)',
                        hintText: 'e.g. Цукиширо Агент',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _localeController,
                            decoration: const InputDecoration(
                              labelText: 'Код языка (Locale BCP 47)',
                              hintText: 'e.g. ru-agent, pirate',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _direction,
                            decoration: const InputDecoration(
                              labelText: 'Направление текста',
                            ),
                            dropdownColor: AppTheme.cardDark,
                            items: const [
                              DropdownMenuItem(value: 'ltr', child: Text('LTR (Слева направо)')),
                              DropdownMenuItem(value: 'rtl', child: Text('RTL (Справа налево)')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _direction = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _fallbackLocale,
                            decoration: const InputDecoration(
                              labelText: 'Резервный язык (Fallback)',
                            ),
                            dropdownColor: AppTheme.cardDark,
                            items: const [
                              DropdownMenuItem(value: 'ru', child: Text('Русский (ru)')),
                              DropdownMenuItem(value: 'en', child: Text('English (en)')),
                              DropdownMenuItem(value: 'fr', child: Text('Français (fr)')),
                              DropdownMenuItem(value: 'de', child: Text('Deutsch (de)')),
                              DropdownMenuItem(value: 'es', child: Text('Español (es)')),
                              DropdownMenuItem(value: 'zh', child: Text('Chinese (zh)')),
                              DropdownMenuItem(value: 'ja', child: Text('Japanese (ja)')),
                              DropdownMenuItem(value: 'ar', child: Text('Arabic (ar)')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _fallbackLocale = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _versionController,
                            decoration: const InputDecoration(
                              labelText: 'Версия пакета',
                              hintText: '1.0.0',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _authorController,
                      decoration: const InputDecoration(
                        labelText: 'Автор / Разработчик',
                        hintText: 'Ваш никнейм или команда',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Описание пакета',
                        hintText: 'Краткое описание стилистики или тематики языка',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final updated = widget.pack.copyWith(
                      name: _nameController.text.trim(),
                      nativeName: _nativeNameController.text.trim(),
                      locale: _localeController.text.trim(),
                      direction: _direction,
                      fallbackLocale: _fallbackLocale,
                      author: _authorController.text.trim(),
                      version: _versionController.text.trim(),
                      description: _descController.text.trim(),
                    );
                    widget.onSave(updated);
                    Navigator.pop(context);
                  },
                  child: const Text('Применить'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
