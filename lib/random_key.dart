import 'dart:math';

String generateRandomKey() {
  var r = Random();
  return String.fromCharCodes(
      List.generate(32, (index) => r.nextInt(33) + 89));
}
