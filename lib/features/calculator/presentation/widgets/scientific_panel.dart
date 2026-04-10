import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/calculator.dart';
import '../bloc/calculator_bloc.dart';
import 'calc_button.dart';

class ScientificPanel extends StatelessWidget {
  final bool expanded;
  final Animation<double> animation;

  const ScientificPanel({
    required this.expanded,
    required this.animation,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation,
        axisAlignment: -1.0,
        child: BlocBuilder<CalculatorBloc, CalculatorState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildAngleToggle(context, state),
                        const SizedBox(height: 16),
                        _buildScientificGrid(context),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAngleToggle(BuildContext context, CalculatorState state) {
    final loc = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return SegmentedButton<AngleMode>(
      segments: [
        ButtonSegment<AngleMode>(
          value: AngleMode.rad,
          label: Text(loc.translate('rad').toUpperCase(), 
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        ),
        ButtonSegment<AngleMode>(
          value: AngleMode.deg,
          label: Text(loc.translate('deg').toUpperCase(), 
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        ),
      ],
      selected: {state.angleMode},
      onSelectionChanged: (_) => context.read<CalculatorBloc>().add(ToggleAngleMode()),
      style: SegmentedButton.styleFrom(
        backgroundColor: colorScheme.surface.withValues(alpha: 0.5),
        selectedBackgroundColor: colorScheme.primary,
        selectedForegroundColor: colorScheme.onPrimary,
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildScientificGrid(BuildContext context) {
    final functions = [
      ['sin', 'cos', 'tan'],
      ['log', 'ln', 'sqrt'],
      ['x²', 'x³', 'xʸ'],
      ['n!', 'π', 'e'],
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6, // Slimmer profile for scientific tools
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            final row = index ~/ 3;
            final col = index % 3;
            final label = functions[row][col];
            
            return CalcButton(
              label: label,
              onPressed: () => _handleScientific(context, label),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            );
          },
        );
      },
    );
  }

  void _handleScientific(BuildContext context, String func) {
    final bloc = context.read<CalculatorBloc>();
    String mapped = func;
    if (func == 'x²') mapped = 'square';
    if (func == 'x³') mapped = 'cube';
    if (func == 'xʸ') mapped = '^';
    if (func == 'n!') mapped = 'factorial';
    bloc.add(ScientificFunctionPressed(mapped));
  }
}