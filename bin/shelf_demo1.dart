import 'dart:async' show Future;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

class Service {
  // The [Router] can be used to create a handler, which can be used with
  // [shelf_io.serve].
  int _counter = 0;
  Handler get handler {
    final router = Router();

    // Handlers can be added with `router.<verb>('<route>', handler)`, the
    // '<route>' may embed URL-parameters, and these may be taken as parameters
    // by the handler (but either all URL parameters or no URL parameters, must
    // be taken parameters by the handler).
    router.get('/say-hi/<name>', (Request request, String name) {
      return Response.ok('hi $name');
    });

    // Embedded URL parameters may also be associated with a regular-expression
    // that the pattern must match.
    router.get('/user/<userId|[0-9]+>', (Request request, String userId) {
      return Response.ok('User has the user-number: $userId');
    });

    // Handlers can be asynchronous (returning `FutureOr` is also allowed).
    router.get('/wave', (Request request) async {
      _counter ++;
      await Future.delayed(Duration(milliseconds: 100));
      return Response.ok(_counter.toString());
    });

    router.get('/counter/inc', (Request request) async {
      _counter ++;
      await Future.delayed(Duration(milliseconds: 100));
      return Response.ok(_counter.toString() + '\n' );
    });
    router.get('/counter/dec', (Request request) async {
      _counter --;
      await Future.delayed(Duration(milliseconds: 100));
      return Response.ok(_counter.toString() + '\n');
    });
    router.get('/counter/reset', (Request request) async {
      _counter =0 ;
      await Future.delayed(Duration(milliseconds: 100));
      return Response.ok(_counter.toString() + '\n');
    });

    // Other routers can be mounted...
    router.mount('/api/', Api().router);

    // You can catch all verbs and use a URL-parameter with a regular expression
    // that matches everything to catch app.
    router.all('/<ignored|.*>', (Request request) {
      return Response.notFound('Page not found');
    });

    return router;
  }
}

class Api {
  Future<Response> _messages(Request request) async {
    print(_messages.toString());
    return Response.ok('[api test message ]');
  }

  Future<Response> _increment(Request request) async {
    print("increment");
    return Response.ok('[increment]');
  }

  Future<Response> _decrement(Request request) async {
    print("decrement");
    return Response.ok("[decrement]");
  }

  // By exposing a [Router] for an object, it can be mounted in other routers.
  Router get router {
    final router = Router();

    // A handler can have more that one route.
    router.get('/messages', _messages);
    router.get('/messages/', _messages);
    router.get('/increment/', _increment);
    router.get('/decrement/', _decrement);

    // This nested catch-all, will only catch /api/.* when mounted above.
    // Notice that ordering if annotated handlers and mounts is significant.
    router.all('/<ignored|.*>', (Request request) => Response.notFound('null'));

    return router;
  }
}

// Run shelf server and host a [Service] instance on port 8080.
void main() async {
  final service = Service();
  final server = await shelf_io.serve(service.handler, 'localhost', 9091);
  print('Server running on localhost:${server.port}');
}
