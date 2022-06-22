#import "PosthogFlutterPlugin.h"
#import <PostHog/PHGPostHog.h>
#import <PostHog/PHGPostHogIntegration.h>
#import <PostHog/PHGContext.h>
#import <PostHog/PHGMiddleware.h>

@implementation PosthogFlutterPlugin
// Contents to be appended to the context
static NSDictionary *_appendToContextMiddleware;
static NSMutableArray *_posthogList = [[NSMutableArray alloc] init];

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  @try {
    FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"posthogflutter"
      binaryMessenger:[registrar messenger]];
    PosthogFlutterPlugin* instance = [[PosthogFlutterPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
  }
  @catch (NSException *exception) {
    NSLog(@"%@", [exception reason]);
  }
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"init" isEqualToString:call.method]) {
    [self init:call result:result];
  } else if ([@"identify" isEqualToString:call.method]) {
    [self identify:call result:result];
  } else if ([@"capture" isEqualToString:call.method]) {
    [self capture:call result:result];
  } else if ([@"screen" isEqualToString:call.method]) {
    [self screen:call result:result];
  } else if ([@"alias" isEqualToString:call.method]) {
    [self alias:call result:result];
  } else if ([@"getAnonymousId" isEqualToString:call.method]) {
    [self anonymousId:call result:result];
  } else if ([@"reset" isEqualToString:call.method]) {
    [self reset:call result:result];
  } else if ([@"disable" isEqualToString:call.method]) {
    [self disable:call result:result];
  } else if ([@"enable" isEqualToString:call.method]) {
    [self enable:call result:result];
  } else if ([@"debug" isEqualToString:call.method]) {
    [self debug:call result:result];
  } else if ([@"setContext" isEqualToString:call.method]) {
    [self setContext:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)setContext:(FlutterMethodCall*)call result:(FlutterResult)result {
  @try {
    NSDictionary *context = call.arguments[@"context"];
    _appendToContextMiddleware = context;
    result([NSNumber numberWithBool:YES]);
  }
  @catch (NSException *exception) {
    result([FlutterError
      errorWithCode:@"PosthogFlutterException"
      message:[exception reason]
      details: nil]);
  }

}

- (void)init:(FlutterMethodCall*)call result:(FlutterResult)result {
  @try {
    NSString *writeKey = call.arguments[@"writeKey"];
    NSString *posthogHost = call.arguments[@"posthogHost"];
    BOOL captureApplicationLifecycleEvents = call.arguments[@"captureApplicationLifecycleEvents"];
    BOOL debug = call.arguments[@"debug"];

    PHGPostHogConfiguration *configuration = [PHGPostHogConfiguration configurationWithApiKey:writeKey host:posthogHost];

    // This middleware is responsible for manipulating only the context part of the request,
    // leaving all other fields as is.
    PHGMiddlewareBlock contextMiddleware = ^(PHGContext *_Nonnull context, PHGMiddlewareNext _Nonnull next) {
      // Do not execute if there is nothing to append
      if (_appendToContextMiddleware == nil) {
        next(context);
        return;
      }

      // Avoid overriding the context if there is none to override
      // (see different payload types here: https://github.com/posthogio/analytics-ios/tree/master/PostHog/Classes/Integrations)
      if (![context.payload isKindOfClass:[PHGCapturePayload class]]
        && ![context.payload isKindOfClass:[PHGScreenPayload class]]
        && ![context.payload isKindOfClass:[PHGIdentifyPayload class]]) {
        next(context);
        return;
      }

      next([context
        modify: ^(id<PHGMutableContext> _Nonnull ctx) {
          if (_appendToContextMiddleware == nil) {
            return;
          }

          // do not touch it if no payload is present
          if (ctx.payload == nil) {
            NSLog(@"Cannot update posthog context when the current context payload is empty.");
            return;
          }

          @try {
            // PHGPayload does not offer copyWith* methods, so we have to
            // manually test and re-create it for each of its type.
            if ([ctx.payload isKindOfClass:[PHGCapturePayload class]]) {
              ctx.payload = [[PHGCapturePayload alloc]
                initWithEvent: ((PHGCapturePayload*)ctx.payload).event
                properties: ((PHGCapturePayload*)ctx.payload).properties
              ];
            } else if ([ctx.payload isKindOfClass:[PHGScreenPayload class]]) {
              ctx.payload = [[PHGScreenPayload alloc]
                initWithName: ((PHGScreenPayload*)ctx.payload).name
                properties: ((PHGScreenPayload*)ctx.payload).properties
              ];
            } else if ([ctx.payload isKindOfClass:[PHGIdentifyPayload class]]) {
              ctx.payload = [[PHGIdentifyPayload alloc]
                initWithDistinctId: ((PHGIdentifyPayload*)ctx.payload).distinctId
                anonymousId: ((PHGIdentifyPayload*)ctx.payload).anonymousId
                properties: ((PHGIdentifyPayload*)ctx.payload).properties
              ];
            }
          }
          @catch (NSException *exception) {
            NSLog(@"Could not update posthog context: %@", [exception reason]);
          }
        }]
      );
    };

    configuration.middlewares = @[
      [[PHGBlockMiddleware alloc] initWithBlock:contextMiddleware]
    ];

    configuration.captureApplicationLifecycleEvents = captureApplicationLifecycleEvents;

    [_posthogList addObject: [[PHGPostHog alloc] initWithConfiguration:configuration]];
    result([NSNumber numberWithBool:YES]);
  }
  @catch (NSException *exception) {
    result([FlutterError
      errorWithCode:@"PosthogFlutterException"
      message:[exception reason]
      details: nil]);
  }
}

- (void)identify:(FlutterMethodCall*)call result:(FlutterResult)result {
  @try {
    NSNumber *index = call.arguments[@"index"];
    NSString *userId = call.arguments[@"userId"];
    NSDictionary *properties = call.arguments[@"properties"];
    NSDictionary *options = call.arguments[@"options"];
    [[_posthogList objectAtIndex: index] identify: userId
                      properties: properties
                     options: options];
    result([NSNumber numberWithBool:YES]);
  }
  @catch (NSException *exception) {
    result([FlutterError
      errorWithCode:@"PosthogFlutterException"
      message:[exception reason]
      details: nil]);
  }
}

- (void)capture:(FlutterMethodCall*)call result:(FlutterResult)result {
  @try {
    NSNumber *index = call.arguments[@"index"];
    NSString *eventName = call.arguments[@"eventName"];
    NSDictionary *properties = call.arguments[@"properties"];
    NSDictionary *options = call.arguments[@"options"];
    [[_posthogList objectAtIndex: index] capture: eventName
                    properties: properties];
    result([NSNumber numberWithBool:YES]);
  }
  @catch (NSException *exception) {
    result([FlutterError errorWithCode:@"PosthogFlutterException" message:[exception reason] details: nil]);
  }
}

- (void)screen:(FlutterMethodCall*)call result:(FlutterResult)result {
  @try {
    NSNumber *index = call.arguments[@"index"];
    NSString *screenName = call.arguments[@"screenName"];
    NSDictionary *properties = call.arguments[@"properties"];
    NSDictionary *options = call.arguments[@"options"];
    [[_posthogList objectAtIndex: index] screen: screenName
                  properties: properties];
    result([NSNumber numberWithBool:YES]);
  }
  @catch (NSException *exception) {
    result([FlutterError errorWithCode:@"PosthogFlutterException" message:[exception reason] details: nil]);
  }
}

- (void)alias:(FlutterMethodCall*)call result:(FlutterResult)result {
  @try {
    NSNumber *index = call.arguments[@"index"];
    NSString *alias = call.arguments[@"alias"];
    NSDictionary *options = call.arguments[@"options"];
    [[_posthogList objectAtIndex: index] alias: alias];
    result([NSNumber numberWithBool:YES]);
  }
  @catch (NSException *exception) {
    result([FlutterError errorWithCode:@"PosthogFlutterException" message:[exception reason] details: nil]);
  }
}

- (void)anonymousId:(FlutterMethodCall*)call result:(FlutterResult)result {
  @try {
    NSNumber *index = call.arguments[@"index"];
    NSString *anonymousId = [[_posthogList objectAtIndex: index] getAnonymousId];
    result(anonymousId);
  }
  @catch (NSException *exception) {
    result([FlutterError errorWithCode:@"PosthogFlutterException" message:[exception reason] details: nil]);
  }
}

- (void)reset:(FlutterMethodCall*)call result:(FlutterResult)result {
  @try {
     NSNumber *index = call.arguments[@"index"];
    [[_posthogList objectAtIndex: index] reset];
    result([NSNumber numberWithBool:YES]);
  }
  @catch (NSException *exception) {
    result([FlutterError errorWithCode:@"PosthogFlutterException" message:[exception reason] details: nil]);
  }
}

- (void)disable:(FlutterMethodCall*)call result:(FlutterResult)result {
  @try {
    NSNumber *index = call.arguments[@"index"];
    [[_posthogList objectAtIndex: index] disable];
    result([NSNumber numberWithBool:YES]);
  }
  @catch (NSException *exception) {
    result([FlutterError errorWithCode:@"PosthogFlutterException" message:[exception reason] details: nil]);
  }
}

- (void)enable:(FlutterMethodCall*)call result:(FlutterResult)result {
  @try {
    NSNumber *index = call.arguments[@"index"];
    [[_posthogList objectAtIndex: index] enable];
    result([NSNumber numberWithBool:YES]);
  }
  @catch (NSException *exception) {
    result([FlutterError errorWithCode:@"PosthogFlutterException" message:[exception reason] details: nil]);
  }
}

- (void)debug:(FlutterMethodCall*)call result:(FlutterResult)result {
  @try {
    BOOL enabled = call.arguments[@"debug"];
    [PHGPostHog debug: enabled];
    result([NSNumber numberWithBool:YES]);
  }
  @catch (NSException *exception) {
    result([FlutterError errorWithCode:@"PosthogFlutterException" message:[exception reason] details: nil]);
  }
}

+ (NSDictionary *) mergeDictionary: (NSDictionary *) first with: (NSDictionary *) second {
  NSMutableDictionary *result = [first mutableCopy];
  [second enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
    id contained = [result objectForKey:key];
    if (!contained) {
      [result setObject:value forKey:key];
    } else if ([value isKindOfClass:[NSDictionary class]]) {
      [result setObject:[PosthogFlutterPlugin mergeDictionary:result[key] with:value]
        forKey:key];
    }
  }];
  return result;
}

@end
