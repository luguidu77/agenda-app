import 'package:flutter_native_splash/cli_commands.dart';

class CapitalizaPalabras {
  static String capitalizeWords(String input) {
    List<String> words = input.split(' ');
    for (int i = 0; i < words.length; i++) {
      if (words[i].isNotEmpty) words[i] = words[i].capitalize();
    }
    return words.join(' ');
  }
}
