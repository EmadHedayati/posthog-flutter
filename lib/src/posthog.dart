import 'dart:io';

import 'package:posthog_flutter/src/posthog_platform_interface.dart';

export 'package:posthog_flutter/src/posthog_default_options.dart';

class Posthog {
  static Map<String, Posthog> _instances = <String, Posthog>{};

  late PosthogPlatform _posthog;
  late int _index;

  factory Posthog() {
    return getInstance();
  }

  Posthog._internal(PosthogPlatform posthogPlatform, int index) {
    this._posthog = posthogPlatform;
    this._index = index;
  }

  static Posthog getInstance({String instanceName = '\$default_instance'}) {
    return _instances.putIfAbsent(
      instanceName,
      () => Posthog._internal(
        PosthogPlatform.createNewInstance(),
        _instances.length,
      ),
    );
  }

  String? currentScreen;

  Future<void> init({
    required String writeKey,
    required String posthogHost,
    bool captureApplicationLifecycleEvents = false,
    bool debug = false,
  }) {
    return _posthog.init(
      writeKey: writeKey,
      posthogHost: posthogHost,
      captureApplicationLifecycleEvents: captureApplicationLifecycleEvents,
      debug: debug,
    );
  }

  Future<void> identify({
    required int index,
    required userId,
    Map<String, dynamic>? properties,
    Map<String, dynamic>? options,
  }) {
    return _posthog.identify(
      userId: userId,
      properties: properties,
      options: options,
      index: index,
    );
  }

  Future<void> capture({
    required int index,
    required String eventName,
    Map<String, dynamic>? properties,
    Map<String, dynamic>? options,
  }) {
    if (properties != null && !properties.containsKey('\$screen_name') && this.currentScreen != null) {
      properties['\$screen_name'] = this.currentScreen;
    }
    return _posthog.capture(
      eventName: eventName,
      properties: properties,
      options: options,
      index: index,
    );
  }

  Future<void> screen({
    required int index,
    required String screenName,
    Map<String, dynamic>? properties,
    Map<String, dynamic>? options,
  }) {
    if (screenName != '/') {
      this.currentScreen = screenName;
    }
    return _posthog.screen(
      screenName: screenName,
      properties: properties,
      options: options,
      index: index,
    );
  }

  Future<void> alias({
    required int index,
    required String alias,
    Map<String, dynamic>? options,
  }) {
    return _posthog.alias(
      alias: alias,
      options: options,
      index: index,
    );
  }

  Future<String?> getAnonymousId({
    required int index,
  }) {
    return _posthog.getAnonymousId(index: index);
  }

  Future<void> reset({
    required int index,
  }) {
    return _posthog.reset(index: index);
  }

  Future<void> disable({
    required int index,
  }) {
    return _posthog.disable(index: index);
  }

  Future<void> enable({
    required int index,
  }) {
    return _posthog.enable(index: index);
  }

  Future<void> debug(
    bool enabled, {
    required int index,
  }) {
    if (Platform.isAndroid) {
      print('Debug flag cannot be dynamically set on Android.\n'
          'Add to AndroidManifest and avoid calling this method when Platform.isAndroid.');
      return Future.value();
    }

    return _posthog.debug(enabled, index: index);
  }

  Future<void> setContext(
    Map<String, dynamic> context, {
    required int index,
  }) {
    return _posthog.setContext(context, index: index);
  }
}
