import 'package:flutter/material.dart';
import 'package:smart_passenger_alert/services/python_backend_service.dart';
import 'package:smart_passenger_alert/services/flight_data_service.dart';
import 'package:smart_passenger_alert/theme/theme.dart';
import 'package:smart_passenger_alert/widgets/glass_morphism_container.dart';

class FlightDetailsScreen extends StatefulWidget {
  const FlightDetailsScreen({Key? key}) : super(key: key);

  @override
  State<FlightDetailsScreen> createState() => _FlightDetailsScreenState();
}

class _FlightDetailsScreenState extends State<FlightDetailsScreen> {
  List<FlightData> _flights = [];
  FlightData? _selectedFlight;
  FlightDelayPrediction? _delayPrediction;
  bool _isLoadingFlights = true;
  bool _isLoadingPrediction = false;
  String? _flightError;
  String? _predictionError;

  @override
  void initState() {
    super.initState();
    _loadFlights();
  }

  /// Load real departures from airport API
  Future<void> _loadFlights() async {
    if (!mounted) return;

    setState(() {
      _isLoadingFlights = true;
      _flightError = null;
    });

    try {
      // Try to fetch real flights from airport API
      // Leave apiToken as null to use fallback data
      // In production, replace with actual API token
      final flights = await FlightDataService.fetchRealDepartures(
        apiToken: null, // Replace with actual token from airport
      );

      if (mounted) {
        setState(() {
          _flights = flights;
          _isLoadingFlights = false;
          // Auto-select first flight
          if (_flights.isNotEmpty) {
            _selectedFlight = _flights[0];
            _getPrediction(_selectedFlight!);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _flightError = 'Error loading flights: $e';
          _isLoadingFlights = false;
          // Use fallback data
          _flights = FlightDataService.getFallbackFlights();
          if (_flights.isNotEmpty) {
            _selectedFlight = _flights[0];
            _getPrediction(_selectedFlight!);
          }
        });
      }
    }
  }

  /// Get delay prediction for selected flight
  Future<void> _getPrediction(FlightData flight) async {
    if (!mounted) return;

    setState(() {
      _isLoadingPrediction = true;
      _predictionError = null;
    });

    try {
      final prediction = await PythonBackendService.predictFlightDelay(
        weather: flight.weather,
        trafficLevel: flight.trafficLevel,
        departureHour: flight.departureHour,
        aircraftType: flight.aircraftType,
      );

      if (mounted) {
        setState(() {
          _delayPrediction = prediction;
          _isLoadingPrediction = false;
          if (!prediction.success) {
            _predictionError = prediction.error ?? 'Failed to get prediction';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _predictionError = 'Error: $e';
          _isLoadingPrediction = false;
        });
      }
    }
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'very high':
        return AppColors.accentRed;
      case 'high':
        return const Color(0xFFFF9800);
      case 'medium':
        return const Color(0xFFFFC107);
      case 'low':
        return AppColors.accentGreen;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getRiskIcon(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'very high':
        return Icons.warning;
      case 'high':
        return Icons.error_outline;
      case 'medium':
        return Icons.info_outline;
      default:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Flight Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoadingFlights
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Available Flights List
                    Text(
                      'Today\'s Departures',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (_flightError != null)
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.accentRed.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Text(
                          _flightError!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.accentRed,
                              ),
                        ),
                      ),
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _flights.length,
                        itemBuilder: (context, index) {
                          final flight = _flights[index];
                          final isSelected = _selectedFlight == flight;
                          return Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.md),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedFlight = flight;
                                });
                                _getPrediction(flight);
                              },
                              child: GlassMorphismContainer(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                border: isSelected
                                    ? Border.all(color: AppColors.primary, width: 2)
                                    : null,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      flight.flightNumber,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          ),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      flight.airline,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      flight.departureTime,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: flight.isDelayed
                                            ? AppColors.accentRed.withValues(alpha: 0.2)
                                            : AppColors.accentGreen.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        flight.status,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: flight.isDelayed
                                                  ? AppColors.accentRed
                                                  : AppColors.accentGreen,
                                              fontSize: 10,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Selected Flight Details
                    if (_selectedFlight != null) ...[
                      Text(
                        'Flight Information',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      GlassMorphismContainer(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          children: [
                            _buildFlightInfoRow(
                              context,
                              'Flight Number',
                              _selectedFlight!.flightNumber,
                              Icons.flight_takeoff,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _buildFlightInfoRow(
                              context,
                              'Airline',
                              _selectedFlight!.airline,
                              Icons.business,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _buildFlightInfoRow(
                              context,
                              'Aircraft',
                              _selectedFlight!.aircraftType,
                              Icons.airplanemode_active,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _buildFlightInfoRow(
                              context,
                              'Departure',
                              _selectedFlight!.departureTime,
                              Icons.schedule,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _buildFlightInfoRow(
                              context,
                              'Destination',
                              _selectedFlight!.destination,
                              Icons.location_on,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _buildFlightInfoRow(
                              context,
                              'Status',
                              _selectedFlight!.status,
                              Icons.info_outline,
                              statusColor: _selectedFlight!.isDelayed
                                  ? AppColors.accentRed
                                  : AppColors.accentGreen,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // AI Delay Prediction
                      Text(
                        'AI Delay Prediction',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildPredictionCard(context),
                      const SizedBox(height: AppSpacing.xl),

                      // Conditions
                      Text(
                        'Flight Conditions',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      GlassMorphismContainer(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          children: [
                            _buildFlightInfoRow(
                              context,
                              'Weather',
                              _selectedFlight!.weather,
                              Icons.cloud,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _buildFlightInfoRow(
                              context,
                              'Traffic Level',
                              _selectedFlight!.trafficLevel,
                              Icons.traffic,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFlightInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? statusColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPredictionCard(BuildContext context) {
    if (_isLoadingPrediction) {
      return GlassMorphismContainer(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: const SizedBox(
          height: 150,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_predictionError != null) {
      return GlassMorphismContainer(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: AppColors.accentRed, size: 40),
            const SizedBox(height: AppSpacing.md),
            Text(
              _predictionError!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.accentRed,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () => _getPrediction(_selectedFlight!),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_delayPrediction == null || !_delayPrediction!.success) {
      return GlassMorphismContainer(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: const Center(child: Text('No prediction available')),
      );
    }

    return GlassMorphismContainer(
      border: Border.all(color: _getRiskColor(_delayPrediction!.riskLevel), width: 2),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getRiskIcon(_delayPrediction!.riskLevel),
                color: _getRiskColor(_delayPrediction!.riskLevel),
                size: 32,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delay Risk',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _delayPrediction!.riskLevel,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color:
                                _getRiskColor(_delayPrediction!.riskLevel),
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Prediction',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _delayPrediction!.prediction,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _delayPrediction!.delayPredicted
                              ? AppColors.accentRed
                              : AppColors.accentGreen,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _delayPrediction!.confidenceValue / 100,
              minHeight: 8,
              backgroundColor:
                  _getRiskColor(_delayPrediction!.riskLevel)
                      .withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getRiskColor(_delayPrediction!.riskLevel),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Confidence',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
              ),
              Text(
                '${_delayPrediction!.confidenceValue.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommendation',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _delayPrediction!.recommendation,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
