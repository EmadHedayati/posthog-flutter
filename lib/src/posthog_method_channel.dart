import 'package:flutter/services.dart';
import 'package:posthog_flutter/src/posthog_default_options.dart';
import 'package:posthog_flutter/src/posthog_platform_interface.dart';

const MethodChannel _channel = MethodChannel('posthogflutter');

class PosthogMethodChannel extends PosthogPlatform {
  Future<void> init({
    required String writeKey,
    required String posthogHost,
    required String tag,
    bool captureApplicationLifecycleEvents = false,
    bool debug = false,
  }) async {
    try {
      await _channel.invokeMethod('init', {
        'writeKey': writeKey,
        'posthogHost': posthogHost,
        'tag': tag,
        'captureApplicationLifecycleEvents': captureApplicationLifecycleEvents,
        'debug': debug,
      });
    } on PlatformException catch (exception) {
      print(exception);
    }
  }

  Future<void> identify({
    required int index,
    required userId,
    Map<String, dynamic>? properties,
    Map<String, dynamic>? options,
  }) async {
    try {
      await _channel.invokeMethod('identify', {
        'index': index,
        'userId': userId,
        'properties': properties ?? {},
        'options': options ?? PosthogDefaultOptions.instance.options ?? {},
      });
    } on PlatformException catch (exception) {
      print(exception);
    }
  }

  Future<void> capture({
    required int index,
    required String eventName,
    Map<String, dynamic>? properties,
    Map<String, dynamic>? options,
  }) async {
    try {
      await _channel.invokeMethod('capture', {
        'index': index,
        'eventName': eventName,
        'properties': properties ?? {},
        'options': options ?? PosthogDefaultOptions.instance.options ?? {},
      });
    } on PlatformException catch (exception) {
      print(exception);
    }
  }

  Future<void> screen({
    required int index,
    required String screenName,
    Map<String, dynamic>? properties,
    Map<String, dynamic>? options,
  }) async {
    try {
      await _channel.invokeMethod('screen', {
        'index': index,
        'screenName': screenName,
        'properties': properties ?? {},
        'options': options ?? PosthogDefaultOptions.instance.options ?? {},
      });
    } on PlatformException catch (exception) {
      print(exception);
    }
  }

  Future<void> alias({
    required int index,
    required String alias,
    Map<String, dynamic>? options,
  }) async {
    try {
      await _channel.invokeMethod('alias', {
        'index': index,
        'alias': alias,
        'options': options ?? PosthogDefaultOptions.instance.options ?? {},
      });
    } on PlatformException catch (exception) {
      print(exception);
    }
  }

  Future<String?> getAnonymousId({
    required int index,
  }) async {
    return await _channel.invokeMethod('getAnonymousId', {
      'index': index,
    });
  }

  Future<void> reset({
    required int index,
  }) async {
    try {
      await _channel.invokeMethod('reset', {
        'index': index,
      });
    } on PlatformException catch (exception) {
      print(exception);
    }
  }

  Future<void> flush({
    required int index,
  }) async {
    try {
      await _channel.invokeMethod('flush', {
        'index': index,
      });
    } on PlatformException catch (exception) {
      print(exception);
    }
  }

  Future<void> disable({
    required int index,
  }) async {
    try {
      await _channel.invokeMethod('disable', {
        'index': index,
      });
    } on PlatformException catch (exception) {
      print(exception);
    }
  }

  Future<void> enable({
    required int index,
  }) async {
    try {
      await _channel.invokeMethod('enable', {
        'index': index,
      });
    } on PlatformException catch (exception) {
      print(exception);
    }
  }

  Future<void> debug(
    bool enabled, {
    required int index,
  }) async {
    try {
      await _channel.invokeMethod('debug', {
        'index': index,
        'debug': enabled,
      });
    } on PlatformException catch (exception) {
      print(exception);
    }
  }

  Future<void> setContext(
    Map<String, dynamic> context, {
    required int index,
  }) async {
    try {
      await _channel.invokeMethod('setContext', {
        'index': index,
        'context': context,
      });
    } on PlatformException catch (exception) {
      print(exception);
    }
  }

  Future<void> shutdown({
    required int index,
    required String tag,
  }) async {
    try {
      await _channel.invokeMethod('shutdown', {
        'index': index,
        'tag': tag,
      });
    } on PlatformException catch (exception) {
      print(exception);
    }
  }
}
