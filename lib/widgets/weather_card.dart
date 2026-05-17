import 'package:flutter/material.dart';
import 'package:smart_passenger_alert/models/prediction_model.dart';
import 'package:smart_passenger_alert/theme/theme.dart';
import 'package:smart_passenger_alert/widgets/glass_morphism_container.dart';

class WeatherCard extends StatelessWidget {
  final Weather weather;
  final String? location;

  const WeatherCard({
    Key? key,
    required this.weather,
    this.location,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassMorphismContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location ?? 'Current Location',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    weather.description,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                  ),
                ],
              ),
              Text(
                '${weather.temperature.toStringAsFixed(0)}°C',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Weather details grid
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            children: [
              _buildWeatherDetail(
                context,
                'Humidity',
                '${weather.humidity}%',
                Icons.water_drop,
              ),
              _buildWeatherDetail(
                context,
                'Wind',
                '${weather.windSpeed.toStringAsFixed(1)} km/h',
                Icons.air,
              ),
              _buildWeatherDetail(
                context,
                'Visibility',
                '${(weather.visibility / 1000).toStringAsFixed(1)} km',
                Icons.visibility,
              ),
            ],
          ),

          if (weather.hasAdverseWeather) ...[
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.accentRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: AppColors.accentRed.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: AppColors.accentRed, size: 16),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Adverse weather conditions may affect your flight',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.accentRed,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 16),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
