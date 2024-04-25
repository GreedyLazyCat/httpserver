import 'package:crypton/crypton.dart';

String getEncryptedString({required RSAPublicKey publicKey, required String string}){
  return publicKey.encrypt(string);
}