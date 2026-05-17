import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_passenger_alert/theme/theme.dart';
import 'package:smart_passenger_alert/widgets/glass_morphism_container.dart';
import 'package:smart_passenger_alert/widgets/flight_card.dart';
import 'package:smart_passenger_alert/widgets/ai_card.dart';
import 'package:smart_passenger_alert/models/flight_model.dart';
import 'package:smart_passenger_alert/models/prediction_model.dart';
import 'package:smart_passenger_alert/providers/app_providers.dart';
import 'package:smart_passenger_alert/utils/google_maps_utils.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final flightsAsync = ref.watch(flightsProvider);
    final weatherAsync = ref.watch(weatherProvider('CMB'));

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: CustomScrollView(
        slivers: [
          // Custom AppBar with gradient
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.bgDark,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.bgDark,
                      AppColors.bgCard.withOpacity(0.5),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Good Morning, Javindi',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Text(
                              '👋 ',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              'FRIDAY, OCT 24 • TERMINAL 3',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.textTertiary,
                                    letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
              ),
            ],
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: flightsAsync.when(
                data: (flights) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Flight Status
                    if (flights.isNotEmpty) ...[
                      Text(
                        'Current Flight',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      FlightCard(flight: flights.first),
                      const SizedBox(height: AppSpacing.xxl),
                    ],

                    // AI Prediction
                    Text(
                      'AI Intelligence',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AIPredictionCard(flightId: flights.isNotEmpty ? flights.first.id : ''),
                    const SizedBox(height: AppSpacing.xxl),

                    // Travel Information
                    Text(
                      'Travel Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildTravelInfoCard(
                      context,
                      flights.isNotEmpty ? flights.first : null,
                      weatherAsync,
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Quick Actions
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildQuickActions(context),
                    const SizedBox(height: AppSpacing.xxl),

                    // Destination Spotlight
                    Text(
                      'Dubai Spotlight',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildDestinationSpotlight(context),
                  ],
                ),
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
                error: (error, stack) => Center(
                  child: Text('Error loading flights: $error'),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildTravelInfoCard(
    BuildContext context,
    Flight? flight,
    AsyncValue<Weather> weatherAsync,
  ) {
    return GlassMorphismContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ROUTE ${flight?.origin ?? 'CMB'} -> ${flight?.destination ?? 'DXB'}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 1,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const Icon(Icons.directions_car, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TRAVEL TIME',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Leave in 25 mins to ${flight?.origin ?? 'CMB'}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
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
                  'Light traffic',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.accentGreen,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const Icon(Icons.cloud, color: AppColors.warning, size: 20),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: weatherAsync.when(
                  data: (weather) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CURRENT WEATHER • COLOMBO, SRI LANKA',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${weather.temperature.toStringAsFixed(0)}°C • ${weather.description}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  loading: () => Text(
                    'Fetching Colombo weather...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  error: (_, __) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CURRENT WEATHER • COLOMBO, SRI LANKA',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '28°C • Windy & Rain showers',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        _buildActionButton(
          context,
          'Track Flight',
          Icons.flight_takeoff,
          () => Navigator.pushNamed(context, '/flight-details'),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildActionButton(
          context,
          'Set Alert',
          Icons.notifications,
          () => Navigator.pushNamed(context, '/alerts'),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildActionButton(
          context,
          'Pair Smartwatch',
          Icons.watch,
          () => Navigator.pushNamed(context, '/pair-watch', arguments: 'user_123'),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildActionButton(
          context,
          'Smart Sleep Alerts',
          Icons.health_and_safety,
          () => Navigator.pushNamed(context, '/vitality-ai', arguments: 'user_123'),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildActionButton(
          context,
          'View Route',
          Icons.map,
          () {
            GoogleMapsUtils.openRoute(
              originLabel: 'Bandaranaike International Airport, Colombo, Sri Lanka',
              destinationLabel: 'Dubai International Airport, Dubai, United Arab Emirates',
              travelMode: 'driving',
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: AppSpacing.lg),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward, color: AppColors.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationSpotlight(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.3),
            Colors.purple.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Dubai City',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'REQUIRED TONIGHT',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Text(
                      'VISA',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Text(
                      'ALTERNATIVE FLIGHT',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0.1,
              child: Icon(
                Icons.location_city,
                size: 150,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.home, 'HOME', true, () {}),
              _buildNavItem(
                context,
                Icons.flight,
                'FLIGHTS',
                false,
                () => Navigator.pushNamed(context, '/flight-details'),
              ),
              _buildNavItem(
                context,
                Icons.notifications,
                'ALERTS',
                false,
                () => Navigator.pushNamed(context, '/alerts'),
              ),
              _buildNavItem(
                context,
                Icons.chat,
                'AI CHAT',
                false,
                () => Navigator.pushNamed(context, '/intelligence'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            size: 24,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                  fontSize: 9,
                  letterSpacing: 0.5,
                ),
          ),
        ],
      ),
    );
  }
}
