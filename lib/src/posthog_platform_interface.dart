import 'package:posthog_flutter/src/posthog_method_channel.dart';

abstract class PosthogPlatform {
  /// The default instance of [PosthogPlatform] to use
  ///
  /// Platform-specific plugins should override this with their own
  /// platform-specific class that extends [PosthogPlatform] when they
  /// register themselves.
  ///
  /// Defaults to [PosthogMethodChannel]
  static PosthogPlatform createNewInstance() => PosthogMethodChannel();

  Future<void> init({
    required String writeKey,
    required String posthogHost,
    required String tag,
    bool captureApplicationLifecycleEvents = false,
    bool debug = false,
  }) {
    throw UnimplementedError('init() has not been implemented.');
  }

  Future<void> identify({
    required int index,
    required userId,
    Map<String, dynamic>? properties,
    Map<String, dynamic>? options,
  }) {
    throw UnimplementedError('identify() has not been implemented.');
  }

  Future<void> capture({
    required int index,
    required String eventName,
    Map<String, dynamic>? properties,
    Map<String, dynamic>? options,
  }) {
    throw UnimplementedError('capture() has not been implemented.');
  }

  Future<void> screen({
    required int index,
    required String screenName,
    Map<String, dynamic>? properties,
    Map<String, dynamic>? options,
  }) {
    throw UnimplementedError('screen() has not been implemented.');
  }

  Future<void> alias({
    required int index,
    required String alias,
    Map<String, dynamic>? options,
  }) {
    throw UnimplementedError('alias() has not been implemented.');
  }

  Future<String?> getAnonymousId({
    required int index,
  }) {
    throw UnimplementedError('getAnonymousId() has not been implemented.');
  }

  Future<void> reset({
    required int index,
  }) {
    throw UnimplementedError('reset() has not been implemented.');
  }

  Future<void> disable({
    required int index,
  }) {
    throw UnimplementedError('disable() has not been implemented.');
  }

  Future<void> enable({
    required int index,
  }) {
    throw UnimplementedError('enable() has not been implemented.');
  }

  Future<void> debug(
    bool enabled, {
    required int index,
  }) {
    throw UnimplementedError('debug() has not been implemented.');
  }

  Future<void> setContext(
    Map<String, dynamic> context, {
    required int index,
  }) {
    throw UnimplementedError('setContext() has not been implemented.');
  }

  Future<void> shutdown({
    required int index,
    required String tag,
  }) {
    throw UnimplementedError('shutdown() has not been implemented.');
  }
}
