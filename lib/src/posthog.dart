import 'dart:io';

import 'package:posthog_flutter/src/posthog_platform_interface.dart';

export 'package:posthog_flutter/src/posthog_default_options.dart';
export 'package:posthog_flutter/src/posthog_observer.dart';

class Posthog {
  static Map<String, PosthogPlatform>? _instances;

  late String _instanceName;

  static PosthogPlatform getInstance({String instanceName = '\$default_instance'}) {
    if (_instances == null) {
      _instances = <String, PosthogPlatform>{};
    }

    return _instances!.putIfAbsent(instanceName, () => PosthogPlatform.createNewInstance());
  }

  String? currentScreen;

  Future<void> init({
    required String writeKey,
    required String posthogHost,
    bool captureApplicationLifecycleEvents = false,
    bool debug = false,
  }) {
    return getInstance(instanceName: _instanceName).init(
      writeKey: writeKey,
      posthogHost: posthogHost,
      captureApplicationLifecycleEvents: captureApplicationLifecycleEvents,
      debug: debug,
    );
  }

  Future<void> identify({
    required userId,
    Map<String, dynamic>? properties,
    Map<String, dynamic>? options,
  }) {
    return getInstance(instanceName: _instanceName).identify(
      userId: userId,
      properties: properties,
      options: options,
    );
  }

  Future<void> capture({
    required String eventName,
    Map<String, dynamic>? properties,
    Map<String, dynamic>? options,
  }) {
    if (properties != null && !properties.containsKey('\$screen_name') && this.currentScreen != null) {
      properties['\$screen_name'] = this.currentScreen;
    }
    return getInstance(instanceName: _instanceName).capture(
      eventName: eventName,
      properties: properties,
      options: options,
    );
  }

  Future<void> screen({
    required String screenName,
    Map<String, dynamic>? properties,
    Map<String, dynamic>? options,
  }) {
    if (screenName != '/') {
      this.currentScreen = screenName;
    }
    return getInstance(instanceName: _instanceName).screen(
      screenName: screenName,
      properties: properties,
      options: options,
    );
  }

  Future<void> alias({
    required String alias,
    Map<String, dynamic>? options,
  }) {
    return getInstance(instanceName: _instanceName).alias(
      alias: alias,
      options: options,
    );
  }

  Future<String?> get getAnonymousId {
    return getInstance(instanceName: _instanceName).getAnonymousId;
  }

  Future<void> reset() {
    return getInstance(instanceName: _instanceName).reset();
  }

  Future<void> disable() {
    return getInstance(instanceName: _instanceName).disable();
  }

  Future<void> enable() {
    return getInstance(instanceName: _instanceName).enable();
  }

  Future<void> debug(bool enabled) {
    if (Platform.isAndroid) {
      print('Debug flag cannot be dynamically set on Android.\n'
          'Add to AndroidManifest and avoid calling this method when Platform.isAndroid.');
      return Future.value();
    }

    return getInstance(instanceName: _instanceName).debug(enabled);
  }

  Future<void> setContext(Map<String, dynamic> context) {
    return getInstance(instanceName: _instanceName).setContext(context);
  }
}
