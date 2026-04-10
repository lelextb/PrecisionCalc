import 'dart:math' as math;
import 'package:decimal/decimal.dart';
import 'package:rational/rational.dart';
import '../presentation/bloc/calculator_bloc.dart';

enum AngleMode { rad, deg }

class Calculator {
  String _display = '0';
  Decimal? _previousValue;
  String? _operator;
  bool _waitingForOperand = false;
  bool _justEvaluated = false;
  String? _lastExpression;
  Decimal _memory = Decimal.zero;
  AngleMode _angleMode = AngleMode.rad;
  final List<CalculatorState> _undoStack = [];
  final List<CalculatorState> _redoStack = [];
  static const int _maxStackSize = 50;

  CalculatorState get state => CalculatorState(
        display: _display,
        expression: _buildExpression(),
        result: _justEvaluated ? _display : null,
        waitingForOperand: _waitingForOperand,
        memory: _memory,
        angleMode: _angleMode,
        canUndo: _undoStack.isNotEmpty,
        canRedo: _redoStack.isNotEmpty,
      );

  String? _buildExpression() {
    if (_previousValue != null && _operator != null) {
      return '${_formatDecimal(_previousValue!)} ${_operatorSymbol(_operator!)}';
    }
    return null;
  }

  String _formatDecimal(Decimal d) {
    String str = d.toString();
    if (str.contains('.')) {
      str = str.replaceAll(RegExp(r'0+$'), '');
      str = str.replaceAll(RegExp(r'\.$'), '');
    }
    return str;
  }

  String _operatorSymbol(String op) {
    switch (op) {
      case '+': return '+';
      case '-': return '−';
      case '*': return '×';
      case '/': return '÷';
      case '%': return '%';
      case '^': return '^';
      default: return op;
    }
  }

  void _pushUndo() {
    _undoStack.add(state.copyWith());
    if (_undoStack.length > _maxStackSize) _undoStack.removeAt(0);
    _redoStack.clear();
  }

  CalculatorState inputDigit(String digit) {
    _pushUndo();
    if (_justEvaluated) {
      _clear();
    }
    if (_waitingForOperand) {
      _display = digit;
      _waitingForOperand = false;
    } else {
      if (_display == '0' && digit != '.') {
        _display = digit;
      } else {
        if (digit == '.' && _display.contains('.')) return state;
        _display += digit;
      }
    }
    _justEvaluated = false;
    return state;
  }

  CalculatorState setOperator(String op) {
    _pushUndo();
    if (_justEvaluated) {
      _previousValue = Decimal.parse(_display);
      _operator = op;
      _waitingForOperand = true;
      _justEvaluated = false;
      return state;
    }

    if (_operator != null && !_waitingForOperand) {
      _evaluate();
      _previousValue = Decimal.parse(_display);
      _operator = op;
      _waitingForOperand = true;
      _justEvaluated = false;
    } else {
      _previousValue = Decimal.parse(_display);
      _operator = op;
      _waitingForOperand = true;
    }
    return state;
  }

  CalculatorState evaluate() {
    _pushUndo();
    if (_operator != null && !_waitingForOperand) {
      _lastExpression = '${_formatDecimal(_previousValue!)} ${_operatorSymbol(_operator!)} ${_formatDecimal(Decimal.parse(_display))}';
      _evaluate();
      _previousValue = null;
      _operator = null;
      _waitingForOperand = true;
      _justEvaluated = true;
    }
    return state;
  }

  void _evaluate() {
    if (_previousValue == null || _operator == null) return;
    final second = Decimal.parse(_display);
    try {
      late Decimal result;
      switch (_operator) {
        case '+':
          result = _previousValue! + second;
          break;
        case '-':
          result = _previousValue! - second;
          break;
        case '*':
          result = _previousValue! * second;
          break;
        case '/':
          if (second == Decimal.zero) throw Exception('Division by zero');
          final Rational rational = _previousValue! / second;
          result = rational.toDecimal(scaleOnInfinitePrecision: 10);
          break;
        case '%':
          result = _previousValue! % second;  // modulo returns Decimal directly
          break;
        case '^':
          result = _power(_previousValue!, second);
          break;
        default:
          return;
      }
      _display = _normalize(result);
    } catch (e) {
      _clear();
      _display = 'Error';
    }
  }

  Decimal _power(Decimal base, Decimal exponent) {
    final baseDouble = base.toDouble();
    final expDouble = exponent.toDouble();
    final result = math.pow(baseDouble, expDouble);
    return Decimal.parse(result.toString());
  }

  String _normalize(Decimal d) {
    String str = d.toString();
    if (str.contains('.')) {
      str = str.replaceAll(RegExp(r'0+$'), '');
      str = str.replaceAll(RegExp(r'\.$'), '');
    }
    return str.isEmpty ? '0' : str;
  }

  CalculatorState applyPercent() {
    _pushUndo();
    try {
      final current = Decimal.parse(_display);
      final Rational rational = current / Decimal.fromInt(100);
      _display = _normalize(rational.toDecimal(scaleOnInfinitePrecision: 10));
    } catch (_) {
      _display = '0';
    }
    return state;
  }

  CalculatorState backspace() {
    _pushUndo();
    if (_justEvaluated) {
      _clear();
      return state;
    }
    if (_waitingForOperand) return state;
    if (_display.length > 1) {
      _display = _display.substring(0, _display.length - 1);
      if (_display == '-' || _display.isEmpty) _display = '0';
    } else {
      _display = '0';
    }
    return state;
  }

  void clear() {
    _pushUndo();
    _clear();
  }

  void _clear() {
    _display = '0';
    _previousValue = null;
    _operator = null;
    _waitingForOperand = false;
    _justEvaluated = false;
    _lastExpression = null;
  }

  // Memory operations
  CalculatorState memoryClear() {
    _memory = Decimal.zero;
    return state.copyWith(memory: _memory);
  }

  CalculatorState memoryRecall() {
    _pushUndo();
    _display = _formatDecimal(_memory);
    return state;
  }

  CalculatorState memoryAdd() {
    try {
      _memory += Decimal.parse(_display);
    } catch (_) {}
    return state.copyWith(memory: _memory);
  }

  CalculatorState memorySubtract() {
    try {
      _memory -= Decimal.parse(_display);
    } catch (_) {}
    return state.copyWith(memory: _memory);
  }

  CalculatorState memoryStore() {
    try {
      _memory = Decimal.parse(_display);
    } catch (_) {}
    return state.copyWith(memory: _memory);
  }

  // Scientific functions
  CalculatorState applyFunction(String func) {
    _pushUndo();
    try {
      final value = Decimal.parse(_display);
      late Decimal result;
      switch (func) {
        case 'sin':
          final radians = _toRadians(value);
          result = Decimal.parse(math.sin(radians).toString());
          break;
        case 'cos':
          final radians = _toRadians(value);
          result = Decimal.parse(math.cos(radians).toString());
          break;
        case 'tan':
          final radians = _toRadians(value);
          result = Decimal.parse(math.tan(radians).toString());
          break;
        case 'log':
          result = Decimal.parse(math.log(value.toDouble()).toString());
          break;
        case 'ln':
          result = Decimal.parse(math.log(value.toDouble()).toString());
          break;
        case 'sqrt':
          result = Decimal.parse(math.sqrt(value.toDouble()).toString());
          break;
        case 'square':
          result = value * value;
          break;
        case 'cube':
          result = value * value * value;
          break;
        case 'factorial':
          result = _factorial(value.toBigInt().toInt());
          break;
        case 'pi':
          result = Decimal.parse(math.pi.toString());
          break;
        case 'e':
          result = Decimal.parse(math.e.toString());
          break;
        default:
          return state;
      }
      _display = _normalize(result);
      _justEvaluated = true;
    } catch (e) {
      _display = 'Error';
    }
    return state;
  }

  double _toRadians(Decimal deg) {
    if (_angleMode == AngleMode.deg) {
      return deg.toDouble() * math.pi / 180;
    }
    return deg.toDouble();
  }

  Decimal _factorial(int n) {
    if (n < 0) throw Exception('Negative factorial');
    Decimal result = Decimal.one;
    for (int i = 2; i <= n; i++) {
      result *= Decimal.fromInt(i);
    }
    return result;
  }

  CalculatorState toggleAngleMode() {
    _angleMode = _angleMode == AngleMode.rad ? AngleMode.deg : AngleMode.rad;
    return state.copyWith(angleMode: _angleMode);
  }

  // Undo/Redo
  CalculatorState undo() {
    if (_undoStack.isEmpty) return state;
    _redoStack.add(state.copyWith());
    final previous = _undoStack.removeLast();
    _applyState(previous);
    return state.copyWith(canUndo: _undoStack.isNotEmpty, canRedo: true);
  }

  CalculatorState redo() {
    if (_redoStack.isEmpty) return state;
    _undoStack.add(state.copyWith());
    final next = _redoStack.removeLast();
    _applyState(next);
    return state.copyWith(canUndo: true, canRedo: _redoStack.isNotEmpty);
  }

  void _applyState(CalculatorState s) {
    _display = s.display;
    _previousValue = s.expression != null ? Decimal.tryParse(s.display) : null;
    _operator = _extractOperator(s.expression);
    _waitingForOperand = s.waitingForOperand;
    _justEvaluated = s.result != null;
  }

  String? _extractOperator(String? expr) {
    if (expr == null) return null;
    if (expr.contains('+')) return '+';
    if (expr.contains('−')) return '-';
    if (expr.contains('×')) return '*';
    if (expr.contains('÷')) return '/';
    if (expr.contains('^')) return '^';
    return null;
  }

  String? getLastExpression() => _lastExpression;
}