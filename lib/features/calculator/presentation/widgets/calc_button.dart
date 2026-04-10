import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/services/sound_manager.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';

class CalcButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? shadowColor;
  final bool isWide;

  const CalcButton({
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.shadowColor,
    this.isWide = false,
    super.key,
  });

  @override
  State<CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final buttonSize = Responsive.buttonSize(context);
    final isDark = theme.brightness == Brightness.dark;

    // Advanced Color Logic for Architecture Consistency
    Color bg;
    Color textColor;
    if (widget.label == 'C') {
      bg = colorScheme.error;
      textColor = colorScheme.onError;
    } else if (widget.label == '=') {
      bg = colorScheme.primary;
      textColor = colorScheme.onPrimary;
    } else if (['÷', '×', '−', '+', '%'].contains(widget.label)) {
      bg = colorScheme.secondaryContainer.withValues(alpha: isDark ? 0.3 : 0.8);
      textColor = colorScheme.onSecondaryContainer;
    } else {
      bg = widget.backgroundColor ?? (isDark ? const Color(0xFF1E2A32) : const Color(0xFFF0F0F0));
      textColor = colorScheme.onSurface;
    }

    final depth = _isPressed ? 0.0 : (buttonSize * 0.06);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 80),
      curve: Curves.easeOut,
      width: widget.isWide ? (buttonSize * 2) + 16 : buttonSize,
      height: buttonSize,
      margin: EdgeInsets.only(top: _isPressed ? depth : 0, bottom: _isPressed ? 0 : depth),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(buttonSize * 0.35), // Sophisticated Squircle
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bg,
            bg.withValues(alpha: 0.85),
          ],
        ),
        boxShadow: [
          // The "Bottom" Shadow (Depth)
          BoxShadow(
            color: widget.shadowColor ?? (isDark ? Colors.black.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.2)),
            offset: Offset(0, depth),
            blurRadius: _isPressed ? 2 : 4,
            spreadRadius: 0,
          ),
          // Inner Bevel for "Relentless" High-End Finish
          if (!_isPressed)
            BoxShadow(
              color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.5),
              offset: const Offset(-2, -2),
              blurRadius: 4,
              spreadRadius: -1,
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: () async {
            final settings = context.read<SettingsBloc>().state;
            
            // Execute Haptics
            if (settings.hapticEnabled) {
              await Haptics.vibrate(HapticsType.selection);
            }

            // Execute Sound logic
            if (settings.soundEnabled) {
              if (widget.label == 'C') {
                SoundManager().playClear();
              } else if (widget.label == '=') {
                SoundManager().playEquals();
              } else {
                SoundManager().playClick();
              }
            }
            
            widget.onPressed();
          },
          borderRadius: BorderRadius.circular(buttonSize * 0.35),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              widget.label,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontWeight: FontWeight.w900,
                color: textColor,
                fontSize: buttonSize * 0.32,
                shadows: [
                  if (widget.label == '=')
                    Shadow(
                      color: textColor.withValues(alpha: 0.5),
                      blurRadius: 10,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}