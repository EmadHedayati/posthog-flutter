import 'dart:js';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart' show Registrar;

class PosthogWeb {
  static List<dynamic> _instances = [];

  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'posthogflutter',
      const StandardMethodCodec(),
      registrar.messenger,
    );
    final PosthogWeb instance = PosthogWeb();
    channel.setMethodCallHandler(instance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    if (call.method == "init") {
      print("inside");

      final analytics = JsObject.fromBrowserObject(context['posthog']);
      print(analytics);

      dynamic _instance = analytics.callMethod("init", [
        call.arguments["writeKey"],
        {"api_host": call.arguments["posthogHost"]},
        call.arguments["tag"],
      ]);
      print(_instance);

      _instances.add(_instance);
      print(_instances.length);
      return;
    }

    final instance = _instances[call.arguments["index"]];
    print("outside");
    print(instance);

    switch (call.method) {
      case 'identify':
        instance.callMethod('identify', [
          call.arguments['userId'],
          JsObject.jsify(call.arguments['properties']),
        ]);
        break;
      case 'capture':
        instance.callMethod('capture', [
          call.arguments['eventName'],
          JsObject.jsify(call.arguments['properties']),
        ]);
        break;
      case 'group':
        instance.callMethod('group', [
          call.arguments['groupType'],
          call.arguments['groupKey'],
          JsObject.jsify(call.arguments['properties']),
        ]);
        break;
      case 'screen':
        instance.callMethod('capture', [
          call.arguments['screenName'],
          JsObject.jsify(call.arguments['properties']),
        ]);
        break;
      case 'alias':
        instance.callMethod('alias', [
          call.arguments['alias'],
        ]);
        break;
      case 'getAnonymousId':
        final anonymousId = instance.callMethod('get_distinct_id');
        return anonymousId;
      case 'reset':
        instance.callMethod('reset');
        break;
      case 'debug':
        instance.callMethod('debug', [
          call.arguments['debug'],
        ]);
        break;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: "The posthog plugin for web doesn't implement the method '${call.method}'",
        );
    }
  }
}
