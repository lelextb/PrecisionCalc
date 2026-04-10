import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:decimal/decimal.dart';
import '../../domain/calculator.dart'; 
import '../../../../core/database/database.dart';

part 'calculator_event.dart';
part 'calculator_state.dart';

class CalculatorBloc extends Bloc<CalculatorEvent, CalculatorState> {
  final Calculator _calculator = Calculator();
  List<CalculationEntry> _history = [];

  CalculatorBloc() : super(CalculatorState()) {   // ← no const
    on<DigitPressed>(_onDigitPressed);
    on<OperatorPressed>(_onOperatorPressed);
    on<EqualsPressed>(_onEqualsPressed);
    on<ClearPressed>(_onClearPressed);
    on<BackspacePressed>(_onBackspacePressed);
    on<PercentPressed>(_onPercentPressed);
    on<LoadHistory>(_onLoadHistory);
    on<DeleteHistoryItem>(_onDeleteHistoryItem);
    on<ClearHistory>(_onClearHistory);
    on<HistoryItemSelected>(_onHistoryItemSelected);
    on<MemoryClear>(_onMemoryClear);
    on<MemoryRecall>(_onMemoryRecall);
    on<MemoryAdd>(_onMemoryAdd);
    on<MemorySubtract>(_onMemorySubtract);
    on<MemoryStore>(_onMemoryStore);
    on<ScientificFunctionPressed>(_onScientificFunction);
    on<ToggleAngleMode>(_onToggleAngleMode);
    on<Undo>(_onUndo);
    on<Redo>(_onRedo);
  }

  Future<void> _onDigitPressed(DigitPressed event, Emitter<CalculatorState> emit) async {
    emit(_calculator.inputDigit(event.digit));
  }

  Future<void> _onOperatorPressed(OperatorPressed event, Emitter<CalculatorState> emit) async {
    emit(_calculator.setOperator(event.operator));
  }

  Future<void> _onEqualsPressed(EqualsPressed event, Emitter<CalculatorState> emit) async {
    final expressionBefore = _calculator.getLastExpression();
    final newState = _calculator.evaluate();
    if (newState.result != null && expressionBefore != null) {
      await AppDatabase.instance.insertCalculation(
        '$expressionBefore = ${newState.result}',
        newState.result!,
      );
    }
    emit(newState);
    add(LoadHistory());
  }

  Future<void> _onClearPressed(ClearPressed event, Emitter<CalculatorState> emit) async {
    _calculator.clear();
    emit(CalculatorState()); 
  }

  Future<void> _onBackspacePressed(BackspacePressed event, Emitter<CalculatorState> emit) async {
    emit(_calculator.backspace());
  }

  Future<void> _onPercentPressed(PercentPressed event, Emitter<CalculatorState> emit) async {
    emit(_calculator.applyPercent());
  }

  Future<void> _onLoadHistory(LoadHistory event, Emitter<CalculatorState> emit) async {
    final rows = await AppDatabase.instance.getHistory();
    _history = rows.map((row) => CalculationEntry(
      id: row['id'] as int,
      expression: row['expression'] as String,
      result: row['result'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp'] as int),
    )).toList();
    emit(state.copyWith(history: _history));
  }

  Future<void> _onDeleteHistoryItem(DeleteHistoryItem event, Emitter<CalculatorState> emit) async {
    await AppDatabase.instance.deleteHistoryItem(event.id);
    add(LoadHistory());
  }

  Future<void> _onClearHistory(ClearHistory event, Emitter<CalculatorState> emit) async {
    await AppDatabase.instance.clearHistory();
    add(LoadHistory());
  }

  Future<void> _onHistoryItemSelected(HistoryItemSelected event, Emitter<CalculatorState> emit) async {
    _calculator.clear();
    emit(_calculator.inputDigit(event.result));
  }

  void _onMemoryClear(MemoryClear event, Emitter<CalculatorState> emit) {
    emit(_calculator.memoryClear());
  }

  void _onMemoryRecall(MemoryRecall event, Emitter<CalculatorState> emit) {
    emit(_calculator.memoryRecall());
  }

  void _onMemoryAdd(MemoryAdd event, Emitter<CalculatorState> emit) {
    emit(_calculator.memoryAdd());
  }

  void _onMemorySubtract(MemorySubtract event, Emitter<CalculatorState> emit) {
    emit(_calculator.memorySubtract());
  }

  void _onMemoryStore(MemoryStore event, Emitter<CalculatorState> emit) {
    emit(_calculator.memoryStore());
  }

  void _onScientificFunction(ScientificFunctionPressed event, Emitter<CalculatorState> emit) {
    emit(_calculator.applyFunction(event.function));
  }

  void _onToggleAngleMode(ToggleAngleMode event, Emitter<CalculatorState> emit) {
    emit(_calculator.toggleAngleMode());
  }

  void _onUndo(Undo event, Emitter<CalculatorState> emit) {
    emit(_calculator.undo());
  }

  void _onRedo(Redo event, Emitter<CalculatorState> emit) {
    emit(_calculator.redo());
  }
}