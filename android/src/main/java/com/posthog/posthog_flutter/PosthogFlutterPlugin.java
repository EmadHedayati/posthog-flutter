package com.posthog.posthog_flutter;

import androidx.annotation.NonNull;

import android.app.Activity;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.util.Log;

import com.posthog.android.PostHog;
import com.posthog.android.PostHogContext;
import com.posthog.android.Properties;
import com.posthog.android.Options;
import com.posthog.android.Middleware;
import com.posthog.android.payloads.BasePayload;
import static com.posthog.android.PostHog.LogLevel;

import java.util.LinkedHashMap;
import java.util.HashMap;
import java.util.Map;
import java.util.ArrayList;
import java.util.List;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.embedding.engine.plugins.FlutterPlugin;

/** PosthogFlutterPlugin */
public class PosthogFlutterPlugin implements MethodCallHandler, FlutterPlugin {
  private Context applicationContext;
  private MethodChannel methodChannel;
  private List<PostHog> posthogList = new ArrayList<PostHog>();

  static HashMap<String, Object> appendToContextMiddleware;

  /** Plugin registration. */
  public static void registerWith(PluginRegistry.Registrar registrar) {
    final PosthogFlutterPlugin instance = new PosthogFlutterPlugin();
    instance.setupChannels(registrar.context(), registrar.messenger());
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    setupChannels(binding.getApplicationContext(), binding.getBinaryMessenger());
  }

  private void setupChannels(Context applicationContext, BinaryMessenger messenger) {
    try {
      methodChannel = new MethodChannel(messenger, "posthogflutter");
      this.applicationContext = applicationContext;

      // register the channel to receive calls
      methodChannel.setMethodCallHandler(this);
    } catch (Exception e) {
      Log.e("PosthogFlutter", e.getMessage());
    }
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) { }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("init")) {
      this.init(call, result);
    } else if (call.method.equals("identify")) {
      this.identify(call, result);
    } else if (call.method.equals("capture")) {
      this.capture(call, result);
    } else if (call.method.equals("screen")) {
      this.screen(call, result);
    } else if (call.method.equals("alias")) {
      this.alias(call, result);
    } else if (call.method.equals("getAnonymousId")) {
      this.anonymousId(call, result);
    } else if (call.method.equals("reset")) {
      this.reset(call, result);
    } else if (call.method.equals("setContext")) {
      this.setContext(call, result);
    } else if (call.method.equals("disable")) {
      this.disable(call, result);
    } else if (call.method.equals("enable")) {
      this.enable(call, result);
    } else {
      result.notImplemented();
    }
  }

  private void init(MethodCall call, Result result) {
    try {
      String writeKey = call.argument("writeKey");
      String posthogHost = call.argument("posthogHost");
      Boolean captureApplicationLifecycleEvents = call.argument("captureApplicationLifecycleEvents");
      Boolean debug = call.argument("debug");

      PostHog.Builder posthogBuilder = new PostHog.Builder(applicationContext, writeKey, posthogHost);
      if (captureApplicationLifecycleEvents) {
        // Enable this to record certain application events automatically
        posthogBuilder.captureApplicationLifecycleEvents();
      }

      if (debug) {
        posthogBuilder.logLevel(LogLevel.DEBUG);
      }

      // Here we build a middleware that just appends data to the current context
      // using the [deepMerge] strategy.
      posthogBuilder.middleware(
              new Middleware() {
                @Override
                public void intercept(Chain chain) {
                  try {
                    if (appendToContextMiddleware == null) {
                      chain.proceed(chain.payload());
                      return;
                    }

                    BasePayload payload = chain.payload();
                    BasePayload newPayload = payload.toBuilder()
                            .context(appendToContextMiddleware)
                            .build();

                    chain.proceed(newPayload);
                  } catch (Exception e) {
                    Log.e("PosthogFlutter", e.getMessage());
                    chain.proceed(chain.payload());
                  }
                }
              }
      );

      this.posthogList.add(posthogBuilder.build());
      result.success(true);
    } catch (Exception e) {
      result.error("PosthogFlutterException", e.getLocalizedMessage(), null);
    }
  }

  private void identify(MethodCall call, Result result) {
    try {
      int index = call.argument("index");
      String userId = call.argument("userId");
      HashMap<String, Object> propertiesData = call.argument("properties");
      HashMap<String, Object> options = call.argument("options");
      this.callIdentify(index, userId, propertiesData, options);
      result.success(true);
    } catch (Exception e) {
      result.error("PosthogFlutterException", e.getLocalizedMessage(), null);
    }
  }

  private void callIdentify(
    int index,
    String userId,
    HashMap<String, Object> propertiesData,
    HashMap<String, Object> optionsData
  ) {
    Properties properties = new Properties();
    Options options = this.buildOptions(optionsData);

    for(Map.Entry<String, Object> property : propertiesData.entrySet()) {
      String key = property.getKey();
      Object value = property.getValue();
      properties.putValue(key, value);
    }

    this.posthogList.get(index).identify(userId, properties, options);
  }

  private void capture(MethodCall call, Result result) {
    try {
      int index = call.argument("index");
      String eventName = call.argument("eventName");
      HashMap<String, Object> propertiesData = call.argument("properties");
      HashMap<String, Object> options = call.argument("options");
      this.callCapture(index, eventName, propertiesData, options);
      result.success(true);
    } catch (Exception e) {
      result.error("PosthogFlutterException", e.getLocalizedMessage(), null);
    }
  }

  private void callCapture(
    int index,
    String eventName,
    HashMap<String, Object> propertiesData,
    HashMap<String, Object> optionsData
  ) {
    Properties properties = new Properties();
    Options options = this.buildOptions(optionsData);

    for(Map.Entry<String, Object> property : propertiesData.entrySet()) {
      String key = property.getKey();
      Object value = property.getValue();
      properties.putValue(key, value);
    }

    this.posthogList.get(index).capture(eventName, properties, options);
  }

  private void screen(MethodCall call, Result result) {
    try {
      int index = call.argument("index");
      String screenName = call.argument("screenName");
      HashMap<String, Object> propertiesData = call.argument("properties");
      HashMap<String, Object> options = call.argument("options");
      this.callScreen(index, screenName, propertiesData, options);
      result.success(true);
    } catch (Exception e) {
      result.error("PosthogFlutterException", e.getLocalizedMessage(), null);
    }
  }

  private void callScreen(
    int index,
    String screenName,
    HashMap<String, Object> propertiesData,
    HashMap<String, Object> optionsData
  ) {
    Properties properties = new Properties();
    Options options = this.buildOptions(optionsData);

    for(Map.Entry<String, Object> property : propertiesData.entrySet()) {
      String key = property.getKey();
      Object value = property.getValue();
      properties.putValue(key, value);
    }

    this.posthogList.get(index).screen(screenName, properties, options);
  }

  private void alias(MethodCall call, Result result) {
    try {
      int index = call.argument("index");
      String alias = call.argument("alias");
      HashMap<String, Object> optionsData = call.argument("options");
      Options options = this.buildOptions(optionsData);
      this.posthogList.get(index).alias(alias, options);
      result.success(true);
    } catch (Exception e) {
      result.error("PosthogFlutterException", e.getLocalizedMessage(), null);
    }
  }

  private void anonymousId(MethodCall call, Result result) {
    try {
      int index = call.argument("index");
      String anonymousId = this.posthogList.get(index).getAnonymousId();
      result.success(anonymousId);
    } catch (Exception e) {
      result.error("PosthogFlutterException", e.getLocalizedMessage(), null);
    }
  }

  private void reset(MethodCall call, Result result) {
    try {
      int index = call.argument("index");
      this.posthogList.get(index).reset();
      result.success(true);
    } catch (Exception e) {
      result.error("PosthogFlutterException", e.getLocalizedMessage(), null);
    }
  }

  private void setContext(MethodCall call, Result result) {
    try {
      int index = call.argument("index");
      this.appendToContextMiddleware = call.argument("context");
      result.success(true);
    } catch (Exception e) {
      result.error("PosthogFlutterException", e.getLocalizedMessage(), null);
    }
  }

  // There is no enable method at this time for PostHog on Android.
  // Instead, we use optOut as a proxy to achieve the same result.
  private void enable(MethodCall call, Result result) {
    try {
      int index = call.argument("index");
      this.posthogList.get(index).optOut(false);
      result.success(true);
    } catch (Exception e) {
      result.error("PosthogFlutterException", e.getLocalizedMessage(), null);
    }
  }

  // There is no disable method at this time for PostHog on Android.
  // Instead, we use optOut as a proxy to achieve the same result.
  private void disable(MethodCall call, Result result) {
    try {
      int index = call.argument("index");
      this.posthogList.get(index).optOut(true);
      result.success(true);
    } catch (Exception e) {
      result.error("PosthogFlutterException", e.getLocalizedMessage(), null);
    }
  }

  /**
   * Enables / disables / sets custom integration properties so Posthog can properly
   * interact with 3rd parties, such as Amplitude.
   * @see https://posthog.com/docs/connections/sources/catalog/libraries/mobile/android/#selecting-destinations
   * @see https://github.com/posthogio/posthog-android/blob/master/posthog/src/main/java/com/posthog.android/Options.java
   */
  @SuppressWarnings("unchecked")
  private Options buildOptions(HashMap<String, Object> optionsData) {
    Options options = new Options();
    return options;
  }

  // Merges [newMap] into [original], *not* preserving [original]
  // keys (deep) in case of conflicts.
  private static Map deepMerge(Map original, Map newMap) {
    for (Object key : newMap.keySet()) {
      if (newMap.get(key) instanceof Map && original.get(key) instanceof Map) {
        Map originalChild = (Map) original.get(key);
        Map newChild = (Map) newMap.get(key);
        original.put(key, deepMerge(originalChild, newChild));
      } else {
        original.put(key, newMap.get(key));
      }
    }
    return original;
  }
}
