// lib/core/widgets/inputs/custom_textfield.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final IconData? prefixIcon;
  final Widget? prefix;
  final IconData? suffixIcon;
  final Widget? suffix;
  final VoidCallback? onSuffixTap;
  final String? errorText;
  final String? helperText;
  final bool isRequired;
  final TextCapitalization textCapitalization;
  final Color? fillColor;
  final bool showClearButton;
  final bool autoFocus;
  final EdgeInsets? contentPadding;

  const CustomTextField({
    Key? key,
    required this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.inputFormatters,
    this.prefixIcon,
    this.prefix,
    this.suffixIcon,
    this.suffix,
    this.onSuffixTap,
    this.errorText,
    this.helperText,
    this.isRequired = false,
    this.textCapitalization = TextCapitalization.none,
    this.fillColor,
    this.showClearButton = false,
    this.autoFocus = false,
    this.contentPadding,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late bool _obscureText;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.obscureText != widget.obscureText) {
      setState(() {
        _obscureText = widget.obscureText;
      });
    }
  }

  void _handleFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (widget.label.isNotEmpty) ...[
          Row(
            children: [
              Text(
                widget.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: AppFonts.medium,
                  color: _hasFocus
                      ? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
              ),
              if (widget.isRequired) ...[
                const SizedBox(width: AppDimens.margin4),
                Text(
                  '*',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryRed,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppDimens.margin6),
        ],

        // Text Field
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: _obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.obscureText ? 1 : widget.maxLines, // CRITICAL FIX
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          validator: widget.validator,
          inputFormatters: widget.inputFormatters,
          textCapitalization: widget.textCapitalization,
          autofocus: widget.autoFocus,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: widget.enabled
                ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                : (isDark ? AppColors.textHintDark : AppColors.textHintLight),
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
            ),
            errorText: widget.errorText,
            helperText: widget.helperText,
            filled: true,
            fillColor: widget.fillColor ?? (isDark ? AppColors.grey800 : AppColors.grey50),
            contentPadding: widget.contentPadding ?? EdgeInsets.symmetric(
              horizontal: AppDimens.padding16,
              vertical: widget.maxLines > 1 ? AppDimens.padding16 : AppDimens.padding12,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, size: AppDimens.iconSize20)
                : widget.prefix,
            suffixIcon: _buildSuffixIcon(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radius8),
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radius8),
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radius8),
              borderSide: BorderSide(
                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radius8),
              borderSide: BorderSide(
                color: isDark ? AppColors.errorLight : AppColors.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radius8),
              borderSide: BorderSide(
                color: isDark ? AppColors.errorLight : AppColors.error,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radius8),
              borderSide: BorderSide(
                color: isDark ? AppColors.grey700 : AppColors.grey300,
                width: 1,
              ),
            ),
            counterText: '',
          ),
        ),

        // Helper text
        if (widget.helperText != null && widget.errorText == null) ...[
          const SizedBox(height: AppDimens.margin4),
          Text(
            widget.helperText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
            ),
          ),
        ],
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    // If custom suffix icon is provided
    if (widget.suffixIcon != null || widget.suffix != null) {
      return GestureDetector(
        onTap: widget.onSuffixTap,
        child: widget.suffix ?? Icon(widget.suffixIcon, size: AppDimens.iconSize20),
      );
    }

    // Password visibility toggle
    if (_obscureText || widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
          size: AppDimens.iconSize20,
          color: _hasFocus
              ? (Theme.of(context).brightness == Brightness.dark
              ? AppColors.primaryGreenLight
              : AppColors.primaryGreen)
              : null,
        ),
        onPressed: _toggleObscureText,
        tooltip: _obscureText ? 'Show password' : 'Hide password',
      );
    }

    // Clear button
    if (widget.showClearButton && _controller.text.isNotEmpty) {
      return IconButton(
        icon: const Icon(Icons.close_rounded, size: AppDimens.iconSize20),
        onPressed: () {
          _controller.clear();
          widget.onChanged?.call('');
        },
      );
    }

    return null;
  }
}