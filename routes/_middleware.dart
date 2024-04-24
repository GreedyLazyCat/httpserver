import 'package:dart_frog/dart_frog.dart';

import '../providers/auth_provider.dart';

Handler middleware(Handler handler) {
  // TODO: implement middleware
  return handler.use(authProvider());
}
