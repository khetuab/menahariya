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
  bool _obscureText = false;
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

  void _handleFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
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
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radius8),
            boxShadow: _hasFocus ? [
              BoxShadow(
                color: (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
                    .withOpacity(0.2),
                blurRadius: AppDimens.shadowBlurSmall,
                spreadRadius: AppDimens.shadowSpreadNone,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            obscureText: _obscureText,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
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
              border: _buildBorder(isDark, theme),
              enabledBorder: _buildBorder(isDark, theme, isEnabled: true),
              focusedBorder: _buildBorder(isDark, theme, isFocused: true),
              errorBorder: _buildErrorBorder(isDark),
              focusedErrorBorder: _buildErrorBorder(isDark, isFocused: true),
              disabledBorder: _buildBorder(isDark, theme, isEnabled: false),
              counterText: '',
            ),
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
    if (widget.suffixIcon != null || widget.suffix != null) {
      return GestureDetector(
        onTap: widget.onSuffixTap,
        child: widget.suffix ?? Icon(widget.suffixIcon, size: AppDimens.iconSize20),
      );
    }

    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
          size: AppDimens.iconSize20,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

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

  OutlineInputBorder _buildBorder(
      bool isDark,
      ThemeData theme, {
        bool isEnabled = true,
        bool isFocused = false,
      }) {
    Color borderColor;

    if (isFocused) {
      borderColor = isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen;
    } else if (!isEnabled) {
      borderColor = isDark ? AppColors.grey700 : AppColors.grey300;
    } else {
      borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    }

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimens.radius8),
      borderSide: BorderSide(
        color: borderColor,
        width: isFocused ? 2 : 1,
      ),
    );
  }

  OutlineInputBorder _buildErrorBorder(bool isDark, {bool isFocused = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimens.radius8),
      borderSide: BorderSide(
        color: isFocused ? AppColors.errorLight : AppColors.error,
        width: isFocused ? 2 : 1,
      ),
    );
  }
}