import 'package:flutter/material.dart';
import 'package:tupay_app/core/theme/app_colors.dart';

/// A widget that displays the current step in the transaction flow.
class StepperComponent extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const StepperComponent({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isEven) {
            final stepIndex = index ~/ 2;
            final isActive = stepIndex <= currentStep;
            final isCompleted = stepIndex < currentStep;

            return _StepCircle(
              number: stepIndex + 1,
              isActive: isActive,
              isCompleted: isCompleted,
            );
          } else {
            final stepIndex = index ~/ 2;
            final isActive = stepIndex < currentStep;
            return Expanded(
              child: Container(
                height: 2,
                color: isActive
                    ? AppColors.successPrimary
                    : AppColors.cardBorder,
              ),
            );
          }
        }),
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int number;
  final bool isActive;
  final bool isCompleted;

  const _StepCircle({
    required this.number,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.successPrimary : Colors.transparent,
        border: Border.all(
          color: isActive ? AppColors.successPrimary : AppColors.cardBorder,
          width: 2,
        ),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: AppColors.textWhite, size: 16)
            : Text(
                '$number',
                style: TextStyle(
                  color: isActive ? AppColors.textWhite : AppColors.iconMuted,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }
}
