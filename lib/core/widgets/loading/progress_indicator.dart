// lib/core/widgets/loading/progress_indicator.dart

import 'package:flutter/material.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';

class CustomProgressIndicator extends StatelessWidget {
  final double value;
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final bool showPercentage;
  final String? label;
  final String? suffix;

  const CustomProgressIndicator({
    Key? key,
    required this.value,
    this.height = 8,
    this.backgroundColor,
    this.progressColor,
    this.showPercentage = false,
    this.label,
    this.suffix,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null || showPercentage)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.padding4),
            child: Row(
              children: [
                if (label != null)
                  Text(
                    label!,
                    style: theme.textTheme.bodySmall,
                  ),
                const Spacer(),
                if (showPercentage)
                  Text(
                    '${(value * 100).toStringAsFixed(0)}%${suffix ?? ''}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: AppFonts.semiBold,
                      color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                    ),
                  ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: height,
            backgroundColor: backgroundColor ??
                (isDark ? AppColors.grey700 : AppColors.grey200),
            valueColor: AlwaysStoppedAnimation<Color>(
              progressColor ?? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen),
            ),
          ),
        ),
      ],
    );
  }
}

class CircularProgressWithValue extends StatelessWidget {
  final double value;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? backgroundColor;
  final Widget? child;

  const CircularProgressWithValue({
    Key? key,
    required this.value,
    this.size = 60,
    this.strokeWidth = 4,
    this.color,
    this.backgroundColor,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: value.clamp(0.0, 1.0),
            strokeWidth: strokeWidth,
            backgroundColor: backgroundColor ??
                (isDark ? AppColors.grey700 : AppColors.grey200),
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen),
            ),
          ),
          if (child != null)
            Center(child: child),
        ],
      ),
    );
  }
}

class DotsProgressIndicator extends StatelessWidget {
  final int currentIndex;
  final int totalDots;
  final Color? activeColor;
  final Color? inactiveColor;
  final double dotSize;
  final double spacing;

  const DotsProgressIndicator({
    Key? key,
    required this.currentIndex,
    required this.totalDots,
    this.activeColor,
    this.inactiveColor,
    this.dotSize = 8,
    this.spacing = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalDots, (index) {
        return AnimatedContainer(
          duration: AppDimens.animationFast,
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          width: currentIndex == index ? dotSize * 1.5 : dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: currentIndex == index
                ? (activeColor ?? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen))
                : (inactiveColor ?? (isDark ? AppColors.grey600 : AppColors.grey300)),
            borderRadius: BorderRadius.circular(dotSize / 2),
          ),
        );
      }),
    );
  }
}

class PulseLoadingIndicator extends StatefulWidget {
  final Color? color;
  final double size;
  final Duration duration;

  const PulseLoadingIndicator({
    Key? key,
    this.color,
    this.size = 40,
    this.duration = const Duration(milliseconds: 1000),
  }) : super(key: key);

  @override
  State<PulseLoadingIndicator> createState() => _PulseLoadingIndicatorState();
}

class _PulseLoadingIndicatorState extends State<PulseLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = widget.color ?? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size * _animation.value,
          height: widget.size * _animation.value,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: widget.size * 0.6,
              height: widget.size * 0.6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final Color? color;

  const LoadingOverlay({
    Key? key,
    required this.child,
    required this.isLoading,
    this.message,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(AppDimens.padding20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.white,
                  borderRadius: BorderRadius.circular(AppDimens.radius16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: AppDimens.shadowBlurLarge,
                      spreadRadius: AppDimens.shadowSpreadNone,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PulseLoadingIndicator(
                      color: color ?? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: AppDimens.margin16),
                      Text(
                        message!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}