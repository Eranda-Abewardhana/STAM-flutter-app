import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_passenger_alert/theme/theme.dart';
import 'package:smart_passenger_alert/widgets/glass_morphism_container.dart';
import 'package:smart_passenger_alert/providers/app_providers.dart';

class AIPredictionCard extends ConsumerWidget {
  final String flightId;

  const AIPredictionCard({
    Key? key,
    required this.flightId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final predictionAsync = ref.watch(delayPredictionProvider(flightId));

    return predictionAsync.when(
      data: (prediction) => GlassMorphismContainer(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentGreen.withOpacity(0.6),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'AI INTELLIGENCE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.accentGreen,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Recommendation
            Text(
              prediction.recommendation,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Details
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.bgDark.withOpacity(0.5),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'IMPACT FACTOR',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          _getImpactIcon(prediction.impactFactor),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            prediction.impactFactor,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'CONFIDENCE',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          '${(prediction.confidence * 100).toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.accentGreen,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      loading: () => GlassMorphismContainer(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            CircularProgressIndicator(
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Analyzing prediction...',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      error: (error, stack) => GlassMorphismContainer(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          'Unable to load prediction',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.accentRed,
              ),
        ),
      ),
    );
  }

  Widget _getImpactIcon(String factor) {
    IconData icon;
    Color color;

    switch (factor.toLowerCase()) {
      case 'storm cell':
      case 'weather':
        icon = Icons.cloud;
        color = AppColors.warning;
        break;
      case 'mechanical':
        icon = Icons.build;
        color = AppColors.accentRed;
        break;
      case 'traffic':
        icon = Icons.traffic;
        color = AppColors.warning;
        break;
      default:
        icon = Icons.info;
        color = AppColors.primary;
    }

    return Icon(icon, color: color, size: 20);
  }
}
