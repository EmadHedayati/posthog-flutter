import 'dart:io';

import 'package:posthog_flutter/src/posthog_platform_interface.dart';

export 'package:posthog_flutter/src/posthog_default_options.dart';

class Posthog {
  static Map<String, Posthog> _instances = <String, Posthog>{};

  static PosthogPlatform _posthogPlatform = PosthogPlatform.createNewInstance();

  late int _index;
  late String _tag;
  bool _debug = false;

  Posthog._internal(int index, String tag) {
    this._index = index;
    this._tag = tag;
  }

  static Posthog getInstance({String instanceName = '\$default_instance'}) {
    return _instances.putIfAbsent(
      instanceName,
      () => Posthog._internal(_instances.length, instanceName),
    );
  }

  String? currentScreen;

  Future<void> init({
    required String writeKey,
    required String posthogHost,
    required String tag,
    bool captureApplicationLifecycleEvents = false,
    bool debug = false,
  }) {
    this._debug = debug;
    return _posthogPlatform.init(
      writeKey: writeKey,
      posthogHost: posthogHost,
      tag: tag,
      captureApplicationLifecycleEvents: captureApplicationLifecycleEvents,
      debug: debug,
    );
  }

  Future<void> identify({
    required userId,
    Map<String, dynamic>? properties,
    Map<String, dynamic>? options,
  }) {
    return _posthogPlatform.identify(
      userId: userId,
      properties: properties,
      options: options,
      index: _index,
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
    return _posthogPlatform.capture(
      eventName: eventName,
      properties: properties,
      options: options,
      index: _index,
    );
  }

  Future<void> group({
    required String groupType,
    required String groupKey,
    Map<String, dynamic>? properties,
  }) {
    return _posthogPlatform.group(
      groupType: groupType,
      groupKey: groupKey,
      properties: properties,
      index: _index,
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
    // todo: this causes a bug on flutter build apk --release, java.lang.NoSuchMethodException: e.g.a.q.<init> [interface java.util.Map]
    return Future.value();
    // return _posthogPlatform.screen(
    //   screenName: screenName,
    //   properties: properties,
    //   options: options,
    //   index: _index,
    // );
  }

  Future<void> alias({
    required String alias,
    Map<String, dynamic>? options,
  }) {
    return _posthogPlatform.alias(
      alias: alias,
      options: options,
      index: _index,
    );
  }

  Future<String?> getAnonymousId() {
    return _posthogPlatform.getAnonymousId(index: _index);
  }

  Future<void> reset() {
    return _posthogPlatform.reset(index: _index);
  }

  Future<void> flush() {
    return _posthogPlatform.flush(index: _index);
  }

  Future<void> disable() {
    return _posthogPlatform.disable(index: _index);
  }

  Future<void> enable() {
    return _posthogPlatform.enable(index: _index);
  }

  Future<void> debug(bool enabled) {
    if (Platform.isAndroid) {
      if (_debug) print('Debug flag cannot be dynamically set on Android.');
      return Future.value();
    }

    return _posthogPlatform.debug(enabled, index: _index);
  }

  Future<void> setContext(Map<String, dynamic> context) {
    return _posthogPlatform.setContext(context, index: _index);
  }

  Future<void> shutdown() {
    if (Platform.isIOS) {
      if (_debug) print("Posthog instances on ios can not be shutdown.");
      return Future.value();
    }
    return _posthogPlatform.shutdown(index: _index, tag: _tag);
  }
}
