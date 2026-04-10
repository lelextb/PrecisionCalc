import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:decimal/decimal.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/services/sound_manager.dart';
import '../bloc/calculator_bloc.dart';
import '../widgets/calc_button.dart';
import '../widgets/scientific_panel.dart';
import 'history_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> with SingleTickerProviderStateMixin {
  late final AnimationController _scientificController;
  late final Animation<double> _scientificAnimation;
  bool _scientificExpanded = false;

  @override
  void initState() {
    super.initState();
    _scientificController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400), // Smoother transition
    );
    _scientificAnimation = CurvedAnimation(
      parent: _scientificController,
      curve: Curves.elasticOut, // Dynamic response
    );
    SoundManager().initialize();
  }

  @override
  void dispose() {
    _scientificController.dispose();
    super.dispose();
  }

  void _toggleScientificPanel() {
    if (_scientificExpanded) {
      _scientificController.reverse();
    } else {
      _scientificController.forward();
    }
    setState(() => _scientificExpanded = !_scientificExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final padding = Responsive.pagePadding(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context, loc),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              colorScheme.surfaceContainerHighest,
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: padding,
            child: Column(
              children: [
                _buildMemoryRow(context, loc),
                const SizedBox(height: 12),
                _buildDisplay(context),
                const SizedBox(height: 20),
                ScientificPanel(
                  expanded: _scientificExpanded,
                  animation: _scientificAnimation,
                ),
                Expanded(
                  child: _buildButtonGrid(context, loc),
                ),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations loc) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      title: Text(
        loc.translate('calculator'),
        style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
      ),
      leading: IconButton(
        icon: const Icon(Icons.history_rounded),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HistoryPage()),
        ),
        tooltip: loc.translate('history'),
      ),
      actions: [
        BlocBuilder<CalculatorBloc, CalculatorState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Row(
                children: [
                  _buildAppBarAction(
                    icon: Icons.undo_rounded,
                    onPressed: state.canUndo ? () => context.read<CalculatorBloc>().add(Undo()) : null,
                    tooltip: loc.translate('undo'),
                  ),
                  _buildAppBarAction(
                    icon: Icons.redo_rounded,
                    onPressed: state.canRedo ? () => context.read<CalculatorBloc>().add(Redo()) : null,
                    tooltip: loc.translate('redo'),
                  ),
                  _buildAppBarAction(
                    icon: _scientificExpanded ? Icons.science : Icons.science_outlined,
                    onPressed: _toggleScientificPanel,
                    tooltip: loc.translate('scientific'),
                    isActive: _scientificExpanded,
                  ),
                  _buildAppBarAction(
                    icon: Icons.settings_suggest_rounded,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsPage()),
                    ),
                    tooltip: loc.translate('settings'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAppBarAction({required IconData icon, VoidCallback? onPressed, required String tooltip, bool isActive = false}) {
    return IconButton(
      icon: Icon(icon, color: isActive ? Theme.of(context).colorScheme.primary : null),
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: isActive ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2) : null,
      ),
    );
  }

  Widget _buildMemoryRow(BuildContext context, AppLocalizations loc) {
    final memoryOps = ['MC', 'MR', 'M+', 'M-', 'MS'];
    final isSmallScreen = Responsive.screenWidth(context) < 500;

    return BlocBuilder<CalculatorBloc, CalculatorState>(
      builder: (context, state) {
        final memoryDisplay = _formatMemory(state.memory);
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Badge(
                      label: Text(memoryDisplay),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: const Icon(Icons.memory_rounded, size: 18),
                    ),
                    const SizedBox(width: 16),
                    ...memoryOps.map((op) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () => _handleMemory(context, op),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(op, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSecondaryContainer)),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatMemory(Decimal memory) {
    String str = memory.toString();
    if (str.contains('.')) {
      str = str.replaceAll(RegExp(r'0+$'), '');
      str = str.replaceAll(RegExp(r'\.$'), '');
    }
    return str;
  }

  void _handleMemory(BuildContext context, String op) {
    final bloc = context.read<CalculatorBloc>();
    switch (op) {
      case 'MC': bloc.add(MemoryClear()); break;
      case 'MR': bloc.add(MemoryRecall()); break;
      case 'M+': bloc.add(MemoryAdd()); break;
      case 'M-': bloc.add(MemorySubtract()); break;
      case 'MS': bloc.add(MemoryStore()); break;
    }
  }

  Widget _buildDisplay(BuildContext context) {
    return BlocBuilder<CalculatorBloc, CalculatorState>(
      builder: (context, state) {
        final displayFontSize = Responsive.displayFontSize(context);
        final expressionFontSize = Responsive.expressionFontSize(context);
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark 
                ? [const Color(0xFF1A2A32), const Color(0xFF0F1A1F)]
                : [const Color(0xFFF5F5F5), const Color(0xFFE0E0E0)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                offset: const Offset(0, 10),
                blurRadius: 20,
                spreadRadius: -5,
              ),
              BoxShadow(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                offset: const Offset(-5, -5),
                blurRadius: 15,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    state.expression ?? '',
                    key: ValueKey(state.expression),
                    style: TextStyle(
                      fontSize: expressionFontSize,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                      fontFamily: 'Orbitron',
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) => SlideTransition(
                    position: anim.drive(Tween(begin: const Offset(0, 0.2), end: Offset.zero)),
                    child: child,
                  ),
                  child: Text(
                    state.display,
                    key: ValueKey(state.display),
                    style: TextStyle(
                      fontSize: displayFontSize,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFFB3E4FF) : const Color(0xFF0D47A1),
                      fontFamily: 'Orbitron',
                      letterSpacing: 4,
                      shadows: [
                        if (isDark) Shadow(color: const Color(0xFFB3E4FF).withValues(alpha: 0.3), blurRadius: 15),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildButtonGrid(BuildContext context, AppLocalizations loc) {
    final buttonLabels = [
      ['C', '⌫', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '−'],
      ['1', '2', '3', '+'],
      ['0', '.', '='],
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = constraints.maxWidth * 0.04;
        return GridView.builder(
          padding: const EdgeInsets.only(top: 10),
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: 1,
          ),
          itemCount: 19,
          itemBuilder: (context, index) {
            String label;
            if (index < 16) {
              final row = index ~/ 4;
              final col = index % 4;
              label = buttonLabels[row][col];
            } else {
              if (index == 16) label = '0';
              else if (index == 17) label = '.';
              else label = '=';
            }

            return CalcButton(
              label: label,
              onPressed: () => _handleButtonPress(context, label),
              isWide: label == '0',
              // Note: The specific coloring logic is now handled inside the specialized CalcButton widget
            );
          },
        );
      },
    );
  }

  void _handleButtonPress(BuildContext context, String label) {
    final bloc = context.read<CalculatorBloc>();
    if (label == 'C') {
      bloc.add(ClearPressed());
    } else if (label == '⌫') {
      bloc.add(BackspacePressed());
    } else if (label == '%') {
      bloc.add(PercentPressed());
    } else if (label == '=') {
      bloc.add(EqualsPressed());
    } else if (['÷', '×', '−', '+'].contains(label)) {
      String op = label;
      if (op == '÷') op = '/';
      if (op == '×') op = '*';
      if (op == '−') op = '-';
      bloc.add(OperatorPressed(op));
    } else {
      bloc.add(DigitPressed(label));
    }
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Text(
              'CALC ARCHITECT v3.5.0',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                fontFamily: 'Orbitron',
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}