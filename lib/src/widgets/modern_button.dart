import 'package:flutter/material.dart';
import '../config/design_constants.dart';
import '../config/app_theme.dart';

/// Modern button with press feedback and loading states
class ModernButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final ButtonStyle? buttonStyle;
  final bool isPrimary;
  final bool isFullWidth;
  
  const ModernButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.buttonStyle,
    this.isPrimary = true,
    this.isFullWidth = true,
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DesignConstants.animationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final button = widget.isPrimary
        ? ElevatedButton.icon(
            onPressed: widget.isLoading ? null : widget.onPressed,
            icon: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : widget.icon != null
                    ? Icon(widget.icon)
                    : const SizedBox.shrink(),
            label: Text(widget.label),
            style: widget.buttonStyle ??
                ElevatedButton.styleFrom(
                  minimumSize: widget.isFullWidth
                      ? const Size(double.infinity, DesignConstants.buttonHeightMedium)
                      : null,
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignConstants.spaceLarge,
                    vertical: DesignConstants.spaceMedium,
                  ),
                ),
          )
        : OutlinedButton.icon(
            onPressed: widget.isLoading ? null : widget.onPressed,
            icon: widget.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primaryColor,
                    ),
                  )
                : widget.icon != null
                    ? Icon(widget.icon)
                    : const SizedBox.shrink(),
            label: Text(widget.label),
            style: widget.buttonStyle ??
                OutlinedButton.styleFrom(
                  minimumSize: widget.isFullWidth
                      ? const Size(double.infinity, DesignConstants.buttonHeightMedium)
                      : null,
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignConstants.spaceLarge,
                    vertical: DesignConstants.spaceMedium,
                  ),
                ),
          );

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: button,
      ),
    );
  }
}
