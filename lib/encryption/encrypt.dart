import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';

final algorithm = AesGcm.with256bits();

final Future<SecretKey> secretKey = getSecretKeyFromFile('${Directory.current.path}\\lib\\encryption\\config.txt');

Future<String> enryptString(String string, SecretKey secretKey) async {
  final secretBox = await algorithm.encryptString(
    string,
    secretKey: secretKey,
  );
  final concatenatedBytes = secretBox.concatenation();
  return base64Encode(concatenatedBytes);
}

Future<String> deryptString(String encoded, SecretKey secretKey) async {
  final secretBox = SecretBox.fromConcatenation(base64Decode(encoded),
      nonceLength: 12, macLength: 16);

  return await algorithm.decryptString(secretBox, secretKey: secretKey);
}

Future<SecretKey> getSecretKeyFromFile(String path) async {
  var config = File(path);
  var contents = await config.readAsString();
  final keyBytes = base64Decode(contents);

  return await algorithm.newSecretKeyFromBytes(keyBytes);
}

Future<String> generateSecretKey() async {
  final secretKey = await algorithm.newSecretKey();
  return base64Encode(await secretKey.extractBytes());
}
