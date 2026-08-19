import 'package:flutter/material.dart';
import '../models/language_pack.dart';
import '../theme/app_theme.dart';

class ValidationDialog extends StatelessWidget {
  final ValidationReport report;

  const ValidationDialog({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.cardDark,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: 600,
        height: 520,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  report.isValid ? Icons.check_circle_outline : Icons.error_outline,
                  color: report.isValid ? AppTheme.accentGreen : AppTheme.accentRed,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.isValid ? 'Пакет валиден' : 'Обнаружены ошибки в пакете',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Переведено: ${report.translatedKeys} из ${report.totalKeys} (${report.completionPercentage.toStringAsFixed(1)}%)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: report.completionPercentage / 100.0,
                backgroundColor: AppTheme.subtleGray,
                valueColor: AlwaysStoppedAnimation<Color>(
                  report.isValid ? AppTheme.accentGreen : AppTheme.accentAmber,
                ),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  if (report.errors.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.cancel, color: AppTheme.accentRed, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Критические ошибки (${report.errors.length})',
                          style: const TextStyle(
                            color: AppTheme.accentRed,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...report.errors.map((e) => _buildIssueTile(e, AppTheme.accentRed)),
                    const SizedBox(height: 14),
                  ],
                  if (report.warnings.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.warning_amber, color: AppTheme.accentAmber, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Предупреждения (${report.warnings.length})',
                          style: const TextStyle(
                            color: AppTheme.accentAmber,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...report.warnings.map((w) => _buildIssueTile(w, AppTheme.accentAmber)),
                  ],
                  if (report.errors.isEmpty && report.warnings.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Text(
                          'Никаких замечаний не найдено. Пакет готов к установке в Xaneo!',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Закрыть'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueTile(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(color: AppTheme.softWhite, fontSize: 12),
      ),
    );
  }
}
