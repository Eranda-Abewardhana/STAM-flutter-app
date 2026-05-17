import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_passenger_alert/theme/theme.dart';
import 'package:smart_passenger_alert/widgets/glass_morphism_container.dart';
import 'package:smart_passenger_alert/models/alert_model.dart';
import 'package:smart_passenger_alert/providers/app_providers.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  final String userId;

  const AlertsScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(alertsProvider(widget.userId));

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Alerts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                _buildFilterChip('All', true, () {}),
                const SizedBox(width: AppSpacing.md),
                _buildFilterChip('Critical', false, () {}),
                const SizedBox(width: AppSpacing.md),
                _buildFilterChip('Unread', false, () {}),
              ],
            ),
          ),
          // Alerts list
          Expanded(
            child: alertsAsync.when(
              data: (alerts) {
                if (alerts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off,
                          size: 60,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'No alerts yet',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: alerts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    return AlertCard(
                      alert: alerts[index],
                      onDismiss: () {
                        ref.read(alertsNotifierProvider(widget.userId).notifier).deleteAlert(alerts[index].id);
                      },
                      onMarkAsRead: () {
                        ref.read(alertsNotifierProvider(widget.userId).notifier).markAsRead(alerts[index].id);
                      },
                    );
                  },
                );
              },
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
              error: (error, stack) => Center(
                child: Text('Error loading alerts: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
        ),
      ),
    );
  }
}

class AlertCard extends StatelessWidget {
  final Alert alert;
  final VoidCallback onDismiss;
  final VoidCallback onMarkAsRead;

  const AlertCard({
    Key? key,
    required this.alert,
    required this.onDismiss,
    required this.onMarkAsRead,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color glowColor = AppColors.primary;
    IconData icon = Icons.notifications;

    if (alert.isCritical) {
      glowColor = AppColors.accentRed;
      icon = Icons.warning;
    } else if (alert.isWarning) {
      glowColor = AppColors.warning;
      icon = Icons.error;
    }

    return Stack(
      children: [
        GlowingContainer(
          glowColor: glowColor,
          borderRadius: AppRadius.lg,
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
                      color: glowColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Center(
                      child: Icon(icon, color: glowColor, size: 20),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          alert.message,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          _formatTime(alert.timestamp),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (!alert.read) ...[
                    const SizedBox(width: AppSpacing.md),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: glowColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
              if (alert.action != null) ...[
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onMarkAsRead,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: glowColor),
                      foregroundColor: glowColor,
                    ),
                    child: Text(alert.action!),
                  ),
                ),
              ],
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onDismiss,
            child: Icon(
              Icons.close,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
