import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_passenger_alert/models/prediction_model.dart';
import 'package:smart_passenger_alert/models/sensor_model.dart';
import 'package:smart_passenger_alert/providers/app_providers.dart';
import 'package:smart_passenger_alert/services/local_database_service.dart';
import 'package:smart_passenger_alert/theme/theme.dart';
import 'package:smart_passenger_alert/widgets/glass_morphism_container.dart';

class IntelligenceCenterScreen extends ConsumerStatefulWidget {
  const IntelligenceCenterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<IntelligenceCenterScreen> createState() => _IntelligenceCenterScreenState();
}

class _IntelligenceCenterScreenState extends ConsumerState<IntelligenceCenterScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'type': 'ai',
      'message': 'Hello! I\'m your AI Travel Assistant. I can help you with flight predictions, travel optimization, and personalized recommendations.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedConversation();
  }

  Future<void> _loadSavedConversation() async {
    final history = await ref.read(assistantHistoryProvider.future);
    if (!mounted || history.isEmpty) {
      return;
    }

    setState(() {
      _messages
        ..clear()
        ..addAll(history.map((AssistantMessage entry) {
          return {
            'type': entry.role,
            'message': entry.message,
          };
        }));
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    Weather? weather;
    VitalityMetrics? vitality;
    SleepAnalysis? sleep;

    try {
      weather = await ref.read(weatherProvider('CMB').future);
    } catch (_) {
      weather = null;
    }

    try {
      vitality = await ref.read(vitalityMetricsProvider('user_123').future);
    } catch (_) {
      vitality = null;
    }

    try {
      sleep = await ref.read(sleepAnalysisProvider('user_123').future);
    } catch (_) {
      sleep = null;
    }

    final aiResponse = await ref.read(aiAssistantProvider).generateTravelAdvice(
          userMessage: userMessage,
          weather: weather,
          vitality: vitality,
          sleepAnalysis: sleep,
        );

    setState(() {
      _messages.add({
        'type': 'user',
        'message': userMessage,
      });
      _messages.add({
        'type': 'ai',
        'message': aiResponse,
      });
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Intelligence Center',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Real-time adjustments and environmental monitoring',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Messages section
          Expanded(
            child: SingleChildScrollView(
              reverse: true,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    // Alert cards
                    _buildAlertCard(
                      context,
                      'Flight DXB-902 Delayed',
                      'Departure time shifted to 03:45 AM. AI has automatically rescheduled your terminal transfer.',
                      'CRITICAL ALERT',
                      AppColors.accentRed,
                      Icons.flight_takeoff,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildAlertCard(
                      context,
                      'Approaching Storm',
                      'Severe turbulence predicted over North Atlantic: Suggesting cabin light adjustment for comfort.',
                      'PRECAUTIONARY',
                      AppColors.warning,
                      Icons.cloud,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildAlertCard(
                      context,
                      'Circadian Adjustment Set',
                      'Wake-up sequence initiated for 06:15 AM with localized dawn simulation. Room temperature optimized for REM stage recovery.',
                      'OPTIMIZATION SUCCESS',
                      AppColors.accentGreen,
                      Icons.check_circle,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildAlertCard(
                      context,
                      'Dining Recommendation',
                      'Lounge A123 is serving organic breakfast early for your flight.',
                      'INFO',
                      AppColors.primary,
                      Icons.restaurant,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildAlertCard(
                      context,
                      'Transport Arrived',
                      'Your black car is waiting at Gate 4. Plate: MC-2024.',
                      'INFO',
                      AppColors.primary,
                      Icons.directions_car,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Chat messages
                    if (_messages.isNotEmpty)
                      Column(
                        children: [
                          const SizedBox(height: AppSpacing.lg),
                          ..._messages.map((msg) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: _buildChatMessage(context, msg),
                          )),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Input section
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              border: Border(
                top: BorderSide(
                  color: AppColors.divider,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask AI for recommendations...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: const BorderSide(color: AppColors.divider),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(
    BuildContext context,
    String title,
    String description,
    String tag,
    Color tagColor,
    IconData icon,
  ) {
    return GlowingContainer(
      glowColor: tagColor,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Center(
                  child: Icon(icon, color: tagColor, size: 20),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: tagColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Text(
                        tag,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: tagColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(BuildContext context, Map<String, String> msg) {
    final isUser = msg['type'] == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Text(
          msg['message']!,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isUser ? Colors.white : AppColors.textPrimary,
              ),
        ),
      ),
    );
  }
}
