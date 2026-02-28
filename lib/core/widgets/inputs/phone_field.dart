// lib/core/widgets/inputs/phone_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/utils/helpers/string_helper.dart';

import '../../utils/validators/auth_validator.dart';

class PhoneField extends StatefulWidget {
  final String? initialValue;
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final bool autoFocus;
  final FocusNode? focusNode;

  const PhoneField({
    Key? key,
    this.initialValue,
    this.controller,
    this.label,
    this.hint = '0912 345 678',
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.autoFocus = false,
    this.focusNode,
  }) : super(key: key);

  @override
  State<PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<PhoneField> {
  late TextEditingController _controller;
  final _formatter = PhoneNumberFormatter();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppDimens.margin8),
        ],
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.grey800 : AppColors.grey50,
            borderRadius: BorderRadius.circular(AppDimens.radius12),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Row(
            children: [
              // Country Code
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.padding16,
                  vertical: AppDimens.padding16,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.grey700 : AppColors.grey200,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppDimens.radius12),
                    bottomLeft: Radius.circular(AppDimens.radius12),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 16,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('assets/images/ethiopia_flag.png'),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: AppDimens.margin8),
                    Text(
                      '+251',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Phone Number Input
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  focusNode: widget.focusNode,
                  keyboardType: TextInputType.phone,
                  enabled: widget.enabled,
                  autofocus: widget.autoFocus,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _formatter,
                  ],
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.padding16,
                      vertical: AppDimens.padding16,
                    ),
                  ),
                  style: theme.textTheme.bodyLarge,
                  validator: widget.validator ?? (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone number is required';
                    }
                    final digits = value.replaceAll(RegExp(r'\D'), '');

                    // Handle different formats
                    if (digits.length == 9) {
                      // User entered 9 digits (without leading 0)
                      final fullNumber = '0$digits';
                      return AuthValidator.validatePhone(fullNumber);
                    } else if (digits.length == 10) {
                      // User entered 10 digits
                      return AuthValidator.validatePhone(digits);
                    } else if (digits.length == 12 && digits.startsWith('251')) {
                      // International format
                      return AuthValidator.validatePhone(digits);
                    }
                    return 'Please enter a valid Ethiopian phone number';
                  },
                  onChanged: (value) {
                    final digits = value.replaceAll(RegExp(r'\D'), '');
                    // Pass the full number including country code
                    String fullNumber;
                    if (digits.length == 9) {
                      fullNumber = '0$digits';
                    } else {
                      fullNumber = digits;
                    }
                    widget.onChanged?.call(fullNumber);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digits.length > 9) {
      return oldValue;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 4 || i == 7) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}