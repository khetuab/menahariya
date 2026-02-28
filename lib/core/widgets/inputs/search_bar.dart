// lib/core/widgets/inputs/search_bar.dart

import 'package:flutter/material.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/widgets/buttons/icon_button_widget.dart';

class SearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSearch;
  final VoidCallback? onFilter;
  final bool autoFocus;
  final TextEditingController? controller;

  const SearchBar({
    Key? key,
    this.hintText = 'Search destination...',
    this.onChanged,
    this.onSearch,
    this.onFilter,
    this.autoFocus = false,
    this.controller,
  }) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radius16),
        color: isDark ? AppColors.grey800 : AppColors.grey50,
        border: Border.all(
          color: _isFocused
              ? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: _isFocused ? 2 : 1,
        ),
        boxShadow: _isFocused
            ? [
          BoxShadow(
            color: (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
                .withOpacity(0.1),
            blurRadius: AppDimens.shadowBlurMedium,
            spreadRadius: AppDimens.shadowSpreadNone,
            offset: const Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: Row(
        children: [
          // Search Icon
          const SizedBox(width: AppDimens.padding16),
          Icon(
            Icons.search_rounded,
            color: _isFocused
                ? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
                : (isDark ? AppColors.textHintDark : AppColors.textHintLight),
            size: AppDimens.iconSize24,
          ),
          const SizedBox(width: AppDimens.padding12),

          // Search Field
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: widget.autoFocus,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: theme.textTheme.bodyLarge,
              onChanged: widget.onChanged,
              onSubmitted: (_) => widget.onSearch?.call(),
            ),
          ),

          // Clear Button
          if (_controller.text.isNotEmpty)
            IconButtonWidget(
              icon: Icons.close_rounded,
              onPressed: () {
                _controller.clear();
                widget.onChanged?.call('');
              },
              size: 40,
              iconSize: 20,
              backgroundColor: Colors.transparent,
            ),

          // Filter Button
          if (widget.onFilter != null) ...[
            Container(
              width: 1,
              height: 32,
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
            IconButtonWidget(
              icon: Icons.tune_rounded,
              onPressed: widget.onFilter,
              size: 56,
              iconSize: 24,
              backgroundColor: Colors.transparent,
              iconColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ],
        ],
      ),
    );
  }
}