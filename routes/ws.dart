import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:httpserver/authentificator.dart';

Future<Response> onRequest(RequestContext context) async {
  final auth = context.read<Authentificator>();
  var fisrtMessage = true;
  final handler = webSocketHandler((channel, protocol) {
    channel.stream.listen((event) async {
      if (fisrtMessage) {
        var user = await auth.tokenIsValid(event as String);
        if (user != null) {
          fisrtMessage = false;
          channel.sink.add('authorized successfully');
        } else {
          channel.sink.add('token is invalid');
        }
      } else {
        channel.sink.add('authorized successfully');
      }
    });
  });
  return handler(context);
}
