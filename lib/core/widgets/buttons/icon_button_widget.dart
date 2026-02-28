// lib/core/widgets/buttons/icon_button_widget.dart

import 'package:flutter/material.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';

class IconButtonWidget extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final double borderRadius;
  final double elevation;
  final String? tooltip;
  final bool isDisabled;
  final bool hasBorder;
  final EdgeInsets? padding;

  const IconButtonWidget({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.size = AppDimens.buttonHeightMedium,
    this.iconSize = AppDimens.iconSize24,
    this.backgroundColor,
    this.iconColor,
    this.borderRadius = AppDimens.radius8,
    this.elevation = AppDimens.elevation0,
    this.tooltip,
    this.isDisabled = false,
    this.hasBorder = false,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultBackground = backgroundColor ??
        (isDark ? AppColors.grey800 : AppColors.grey100);
    final defaultIconColor = iconColor ??
        (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    return Material(
      color: defaultBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      elevation: elevation,
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: hasBorder ? Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ) : null,
          ),
          child: IconButton(
            icon: Icon(icon),
            iconSize: iconSize,
            color: defaultIconColor,
            onPressed: isDisabled ? null : onPressed,
            tooltip: tooltip,
            padding: padding ?? EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
      ),
    );
  }
}

// Specialized Icon Buttons
class BackButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;

  const BackButtonWidget({Key? key, this.onPressed, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButtonWidget(
      icon: Icons.arrow_back_ios_new_rounded,
      onPressed: onPressed ?? () => Navigator.pop(context),
      backgroundColor: Colors.transparent,
      iconColor: color,
      size: 40,
      iconSize: 20,
    );
  }
}

class CloseButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;

  const CloseButtonWidget({Key? key, this.onPressed, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButtonWidget(
      icon: Icons.close_rounded,
      onPressed: onPressed ?? () => Navigator.pop(context),
      backgroundColor: Colors.transparent,
      iconColor: color,
      size: 40,
      iconSize: 24,
    );
  }
}

class FavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final Function(bool) onFavoriteChanged;
  final double size;

  const FavoriteButton({
    Key? key,
    required this.isFavorite,
    required this.onFavoriteChanged,
    this.size = 40,
  }) : super(key: key);

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDimens.animationFast,
      width: widget.size,
      height: widget.size,
      child: IconButton(
        icon: Icon(
          _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: _isFavorite ? AppColors.primaryRed : null,
        ),
        iconSize: widget.size * 0.6,
        onPressed: () {
          setState(() {
            _isFavorite = !_isFavorite;
          });
          widget.onFavoriteChanged(_isFavorite);
        },
      ),
    );
  }
}