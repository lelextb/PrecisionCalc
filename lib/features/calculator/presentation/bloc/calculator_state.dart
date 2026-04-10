part of 'calculator_bloc.dart';

class CalculationEntry {
  final int id;
  final String expression;
  final String result;
  final DateTime timestamp;

  CalculationEntry({
    required this.id,
    required this.expression,
    required this.result,
    required this.timestamp,
  });
}

class CalculatorState extends Equatable {
  final String display;
  final String? expression;
  final String? result;
  final bool waitingForOperand;
  final List<CalculationEntry> history;
  final Decimal memory;
  final AngleMode angleMode;
  final bool canUndo;
  final bool canRedo;

  CalculatorState({
    this.display = '0',
    this.expression,
    this.result,
    this.waitingForOperand = false,
    this.history = const [],
    Decimal? memory,
    this.angleMode = AngleMode.rad,
    this.canUndo = false,
    this.canRedo = false,
  }) : memory = memory ?? Decimal.zero;

  CalculatorState copyWith({
    String? display,
    String? expression,
    String? result,
    bool? waitingForOperand,
    List<CalculationEntry>? history,
    Decimal? memory,
    AngleMode? angleMode,
    bool? canUndo,
    bool? canRedo,
  }) {
    return CalculatorState(
      display: display ?? this.display,
      expression: expression ?? this.expression,
      result: result ?? this.result,
      waitingForOperand: waitingForOperand ?? this.waitingForOperand,
      history: history ?? this.history,
      memory: memory ?? this.memory,
      angleMode: angleMode ?? this.angleMode,
      canUndo: canUndo ?? this.canUndo,
      canRedo: canRedo ?? this.canRedo,
    );
  }

  @override
  List<Object?> get props => [
        display,
        expression,
        result,
        waitingForOperand,
        history,
        memory,
        angleMode,
        canUndo,
        canRedo,
      ];
}