import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../theme/app_theme.dart';

/// A modern, premium search bar with smooth animations and elegant design.
/// Features: rounded corners, soft shadows, search + mic icons, focus animation.
class PremiumSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onMicTap;
  final VoidCallback? onFilterTap;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final bool showMic;
  final bool showFilter;
  final bool autofocus;
  final EdgeInsetsGeometry? padding;

  const PremiumSearchBar({
    super.key,
    this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onMicTap,
    this.onFilterTap,
    this.onTap,
    this.focusNode,
    this.showMic = true,
    this.showFilter = false,
    this.autofocus = false,
    this.padding,
  });

  @override
  State<PremiumSearchBar> createState() => _PremiumSearchBarState();
}

class _PremiumSearchBarState extends State<PremiumSearchBar>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    _hasText = widget.controller?.text.isNotEmpty ?? false;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _focusNode.removeListener(_onFocusChange);
    _animController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    if (_focusNode.hasFocus) {
      HapticFeedback.selectionClick();
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: GestureDetector(
          onTap: () {
            widget.onTap?.call();
            _focusNode.requestFocus();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            height: 56,
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.darkCard.withValues(alpha: 0.95)
                  : Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: _isFocused
                    ? AppTheme.primary.withValues(alpha: 0.6)
                    : (isDark
                        ? AppTheme.darkBorder.withValues(alpha: 0.3)
                        : AppTheme.lightBorder.withValues(alpha: 0.5)),
                width: _isFocused ? 1.5 : 1,
              ),
              boxShadow: [
                // Base shadow
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: -2,
                ),
                // Focus glow effect
                if (_isFocused)
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: isDark ? 0.15 : 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                // Inner subtle shadow for depth
                BoxShadow(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.02)
                      : Colors.white.withValues(alpha: 0.8),
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Row(
                children: [
                  const SizedBox(width: 18),
                  // Animated Search Icon
                  _buildSearchIcon(isDark),
                  const SizedBox(width: 14),
                  // Text Field
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      autofocus: widget.autofocus,
                      onChanged: (val) {
                        setState(() {
                          _hasText = val.isNotEmpty;
                        });
                        widget.onChanged?.call(val);
                      },
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppTheme.textPrimary : AppTheme.lightText,
                        letterSpacing: 0.2,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: isDark
                              ? AppTheme.textHint
                              : AppTheme.lightTextSub.withValues(alpha: 0.6),
                          letterSpacing: 0.2,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        filled: false,
                      ),
                    ),
                  ),
                  // Clear button (when text exists)
                  if (_hasText) ...[
                    _buildClearButton(isDark),
                    const SizedBox(width: 4),
                  ],
                  // Mic button
                  if (widget.showMic && !_hasText) ...[
                    _buildMicButton(isDark),
                    const SizedBox(width: 4),
                  ],
                  // Filter button
                  if (widget.showFilter) ...[
                    _buildFilterButton(isDark),
                    const SizedBox(width: 8),
                  ] else ...[
                    const SizedBox(width: 14),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchIcon(bool isDark) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (_, value, child) => Transform.scale(
        scale: 0.5 + (value * 0.5),
        child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _isFocused
              ? AppTheme.primary.withValues(alpha: 0.12)
              : (isDark
                  ? AppTheme.darkBorder.withValues(alpha: 0.3)
                  : AppTheme.lightBorder.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Iconsax.search_normal_1,
          size: 18,
          color: _isFocused
              ? AppTheme.primary
              : (isDark ? AppTheme.textSecondary : AppTheme.lightTextSub),
        ),
      ),
    );
  }

  Widget _buildClearButton(bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.controller?.clear();
        widget.onChanged?.call('');
        setState(() {
          _hasText = false;
        });
      },
      child: AnimatedScale(
        scale: _hasText ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.danger.withValues(alpha: 0.15)
                : AppTheme.danger.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Iconsax.close_circle5,
            size: 18,
            color: AppTheme.danger.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }

  Widget _buildMicButton(bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onMicTap?.call();
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutBack,
        builder: (_, value, child) => Transform.scale(
          scale: value,
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: _isFocused
                ? LinearGradient(
                    colors: [
                      AppTheme.accent.withValues(alpha: 0.2),
                      AppTheme.primary.withValues(alpha: 0.15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: _isFocused
                ? null
                : (isDark
                    ? AppTheme.darkBorder.withValues(alpha: 0.3)
                    : AppTheme.lightBorder.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Iconsax.microphone,
            size: 18,
            color: _isFocused
                ? AppTheme.accent
                : (isDark ? AppTheme.textSecondary : AppTheme.lightTextSub),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onFilterTap?.call();
      },
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: const Icon(
          Iconsax.setting_4,
          size: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Utility widget for AnimatedBuilder pattern
class AnimatedBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder2(
      animation: animation,
      builder: builder,
      child: child,
    );
  }
}

class AnimatedBuilder2 extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const AnimatedBuilder2({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
