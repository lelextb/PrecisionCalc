// test/calculator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:calc_architect/features/calculator/domain/calculator.dart';

void main() {
  group('Calculator', () {
    late Calculator calc;

    setUp(() {
      calc = Calculator();
    });

    test('initial state is 0', () {
      expect(calc.state.display, '0');
    });

    test('input digits', () {
      calc.inputDigit('5');
      calc.inputDigit('2');
      expect(calc.state.display, '52');
    });

    test('addition', () {
      calc.inputDigit('2');
      calc.setOperator('+');
      calc.inputDigit('3');
      calc.evaluate();
      expect(calc.state.display, '5');
    });

    test('division by zero shows Error', () {
      calc.inputDigit('5');
      calc.setOperator('/');
      calc.inputDigit('0');
      calc.evaluate();
      expect(calc.state.display, 'Error');
    });
  });
}