import 'package:flutter/material.dart';
import 'package:origin/core/fonts.dart';
import '../../app/theme.dart';

enum OriginButtonVariant { filled, outlined, ghost }

class OriginButton extends StatefulWidget {
  const OriginButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = OriginButtonVariant.filled,
    this.icon,
    this.isFullWidth = false,
    this.isLoading = false,
    this.padding,
    this.fontSize = 12.0,
    this.letterSpacing = 2.4,
  });

  final String text;
  final VoidCallback? onPressed;
  final OriginButtonVariant variant;
  final Widget? icon;
  final bool isFullWidth;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;
  final double fontSize;
  final double letterSpacing;

  @override
  State<OriginButton> createState() => _OriginButtonState();
}

class _OriginButtonState extends State<OriginButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Border? border;

    switch (widget.variant) {
      case OriginButtonVariant.filled:
        bg = _isHovered ? const Color(0xFF7D5C2F) : OriginColors.goldDark;
        fg = Colors.white;
        border = Border.all(color: OriginColors.goldDark, width: 1);
        break;
      case OriginButtonVariant.outlined:
        bg = _isHovered ? OriginColors.gold.withValues(alpha: 0.18) : Colors.transparent;
        fg = OriginColors.goldDark;
        border = Border.all(color: OriginColors.goldDark, width: 1);
        break;
      case OriginButtonVariant.ghost:
        bg = _isHovered ? OriginColors.gold.withValues(alpha: 0.12) : Colors.transparent;
        fg = OriginColors.goldDark;
        border = null;
        break;
    }

    Widget content = widget.isLoading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : Row(
            mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 8),
              ],
              Text(
                widget.text.toUpperCase(),
                style: GoogleFonts.montserrat(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: widget.letterSpacing,
                  color: fg,
                ),
              ),
            ],
          );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onPressed != null && !widget.isLoading
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.isLoading ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: widget.isFullWidth ? double.infinity : null,
          padding: widget.padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          decoration: BoxDecoration(
            color: bg,
            border: border,
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: content,
        ),
      ),
    );
  }
}
