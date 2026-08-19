import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/language_pack.dart';
import '../theme/app_theme.dart';

class StringEditorCard extends StatefulWidget {
  final ManifestKeyDef keyDef;
  final String currentValue;
  final ValueChanged<String> onChanged;

  const StringEditorCard({
    super.key,
    required this.keyDef,
    required this.currentValue,
    required this.onChanged,
  });

  @override
  State<StringEditorCard> createState() => _StringEditorCardState();
}

class _StringEditorCardState extends State<StringEditorCard> {
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
  }

  @override
  void didUpdateWidget(covariant StringEditorCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentValue != widget.currentValue &&
        _controller.text != widget.currentValue) {
      _controller.text = widget.currentValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTranslated = widget.currentValue.trim().isNotEmpty;
    final isSecurityCritical = widget.keyDef.securityCritical;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        border: Border.all(
          color: _isFocused
              ? AppTheme.pureWhite
              : (isSecurityCritical
                  ? AppTheme.accentAmber.withValues(alpha: 0.4)
                  : AppTheme.cardBorder),
          width: _isFocused ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Key Name + Tags
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      widget.keyDef.key,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.pureWhite,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.keyDef.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.keyDef.description,
                        style: const TextStyle(
                          color: AppTheme.mutedGray,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Category scope badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  border: Border.all(color: AppTheme.subtleGray),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.keyDef.scope.toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.lightGray,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              if (isSecurityCritical)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.accentAmber.withValues(alpha: 0.15),
                    border: Border.all(color: AppTheme.accentAmber),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'SECURITY',
                    style: TextStyle(
                      color: AppTheme.accentAmber,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const SizedBox(width: 6),
              // Copy key button
              IconButton(
                icon: const Icon(Icons.copy, size: 14, color: AppTheme.mutedGray),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Скопировать ключ',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.keyDef.key));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ключ ${widget.keyDef.key} скопирован'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Fallback Russian text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.darkSurface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.subtleGray.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ЭТАЛОН (RU):',
                      style: TextStyle(
                        color: AppTheme.mutedGray,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _controller.text = widget.keyDef.fallbackRu;
                        widget.onChanged(widget.keyDef.fallbackRu);
                      },
                      child: const Text(
                        'Вставить как перевод',
                        style: TextStyle(
                          color: AppTheme.lightGray,
                          fontSize: 11,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SelectableText(
                  widget.keyDef.fallbackRu.isEmpty ? '[пусто]' : widget.keyDef.fallbackRu,
                  style: const TextStyle(
                    color: AppTheme.softWhite,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Placeholders chips if any
          if (widget.keyDef.placeholders.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 3),
                  child: Text(
                    'Плейсхолдеры:',
                    style: TextStyle(color: AppTheme.mutedGray, fontSize: 11),
                  ),
                ),
                ...widget.keyDef.placeholders.map((ph) {
                  return ActionChip(
                    label: Text(
                      ph,
                      style: const TextStyle(fontSize: 11, color: AppTheme.pureWhite),
                    ),
                    backgroundColor: AppTheme.darkSurface,
                    side: const BorderSide(color: AppTheme.subtleGray),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    onPressed: () {
                      final currentText = _controller.text;
                      final selection = _controller.selection;
                      final newText = selection.isValid
                          ? currentText.replaceRange(selection.start, selection.end, ph)
                          : currentText + ph;
                      _controller.text = newText;
                      widget.onChanged(newText);
                    },
                  );
                }),
              ],
            ),
            const SizedBox(height: 10),
          ],

          // Translation input
          Focus(
            onFocusChange: (focused) => setState(() => _isFocused = focused),
            child: TextField(
              controller: _controller,
              maxLines: null,
              onChanged: widget.onChanged,
              style: const TextStyle(color: AppTheme.pureWhite, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Введите перевод для ${widget.keyDef.key}...',
                suffixIcon: isTranslated
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16, color: AppTheme.mutedGray),
                        onPressed: () {
                          _controller.clear();
                          widget.onChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
