import 'package:flutter/foundation.dart';

class InstructionProvider extends ChangeNotifier {
  List<String> _instructions = [];

  List<String> get instructions => _instructions;

  void addInstruction(String instruction) {
    _instructions.add(instruction);
    notifyListeners();
  }

  void clearInstructions() {
    _instructions.clear();
    notifyListeners();
  }
}
