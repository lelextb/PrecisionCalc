part of 'calculator_bloc.dart';

sealed class CalculatorEvent extends Equatable {
  const CalculatorEvent();
  @override
  List<Object?> get props => [];
}

class DigitPressed extends CalculatorEvent {
  final String digit;
  const DigitPressed(this.digit);
  @override
  List<Object?> get props => [digit];
}

class OperatorPressed extends CalculatorEvent {
  final String operator;
  const OperatorPressed(this.operator);
  @override
  List<Object?> get props => [operator];
}

class EqualsPressed extends CalculatorEvent {}
class ClearPressed extends CalculatorEvent {}
class BackspacePressed extends CalculatorEvent {}
class PercentPressed extends CalculatorEvent {}
class LoadHistory extends CalculatorEvent {}
class DeleteHistoryItem extends CalculatorEvent {
  final int id;
  const DeleteHistoryItem(this.id);
  @override
  List<Object?> get props => [id];
}
class ClearHistory extends CalculatorEvent {}
class HistoryItemSelected extends CalculatorEvent {
  final String result;
  const HistoryItemSelected(this.result);
  @override
  List<Object?> get props => [result];
}
class MemoryClear extends CalculatorEvent {}
class MemoryRecall extends CalculatorEvent {}
class MemoryAdd extends CalculatorEvent {}
class MemorySubtract extends CalculatorEvent {}
class MemoryStore extends CalculatorEvent {}
class ScientificFunctionPressed extends CalculatorEvent {
  final String function;
  const ScientificFunctionPressed(this.function);
  @override
  List<Object?> get props => [function];
}
class ToggleAngleMode extends CalculatorEvent {}
class Undo extends CalculatorEvent {}
class Redo extends CalculatorEvent {}