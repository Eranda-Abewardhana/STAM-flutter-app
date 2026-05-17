import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:smart_passenger_alert/services/alert_service.dart';
import 'package:smart_passenger_alert/theme/theme.dart';
import 'package:smart_passenger_alert/widgets/glass_morphism_container.dart';

class SmartAlertCard extends StatefulWidget {
  final String message;
  final AlertPriority priority;

  const SmartAlertCard({
    Key? key,
    required this.message,
    required this.priority,
  }) : super(key: key);

  @override
  State<SmartAlertCard> createState() => _SmartAlertCardState();
}

class _SmartAlertCardState extends State<SmartAlertCard>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    if (_isUrgent(widget.priority)) {
      _shakeController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant SmartAlertCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isUrgent(widget.priority) && !_shakeController.isAnimating) {
      _shakeController.repeat(reverse: true);
    } else if (!_isUrgent(widget.priority) && _shakeController.isAnimating) {
      _shakeController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _priorityColor(widget.priority);
    final badge = _priorityLabel(widget.priority);

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _shakeController]),
      builder: (context, child) {
        final pulseScale = 1 + (_pulseController.value * 0.025);
        final shake = _isUrgent(widget.priority)
            ? math.sin(_shakeController.value * math.pi * 6) * 5
            : 0.0;

        return Transform.translate(
          offset: Offset(shake, 0),
          child: Transform.scale(
            scale: pulseScale,
            child: child,
          ),
        );
      },
      child: GlowingContainer(
        glowColor: color,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications_active, color: color),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'SMART ALERT',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: color.withOpacity(0.45)),
                  ),
                  child: Text(
                    badge,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              widget.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.35,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isUrgent(AlertPriority priority) {
    return priority == AlertPriority.high || priority == AlertPriority.critical;
  }

  Color _priorityColor(AlertPriority priority) {
    switch (priority) {
      case AlertPriority.critical:
        return AppColors.accentRed;
      case AlertPriority.high:
        return AppColors.warning;
      case AlertPriority.medium:
        return AppColors.primary;
      case AlertPriority.low:
        return AppColors.accentGreen;
    }
  }

  String _priorityLabel(AlertPriority priority) {
    switch (priority) {
      case AlertPriority.critical:
        return 'CRITICAL';
      case AlertPriority.high:
        return 'HIGH';
      case AlertPriority.medium:
        return 'MEDIUM';
      case AlertPriority.low:
        return 'LOW';
    }
  }
}
