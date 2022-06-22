import 'package:flutter/material.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

void main() {
  /// Wait until the platform channel is properly initialized so we can call
  /// `setContext` during the app initialization.
  WidgetsFlutterBinding.ensureInitialized();

  /// The `context.device.token` is a special property.
  /// When you define it, setting the context again with no token property (ex: `{}`)
  /// has no effect on cleaning up the device token.
  ///
  /// This is used as an example to allow you to set string-based
  /// device tokens, which is the use case when integrating with
  /// Firebase Cloud Messaging (FCM).
  ///
  /// This plugin currently does not support Apple Push Notification service (APNs)
  /// tokens, which are binary structures.
  ///
  /// Aside from this special use case, any other context property that needs
  /// to be defined (or re-defined) can be done.
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(),
      navigatorObservers: [],
    );
  }
}
