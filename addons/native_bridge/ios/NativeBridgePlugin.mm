#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

// Forward declaration for NativeBridge C++ class
void native_bridge_call_native(const char *action, const char *data_json, const char *tag);
void native_bridge_send_response(const char *action, const char *data_json, const char *tag);

#ifdef __cplusplus
}
#endif

@interface NativeBridgeIOS : NSObject

+ (instancetype)sharedInstance;
- (void)callNative:(NSString *)action data:(NSString *)dataJson tag:(NSString *)tag;
- (void)sendResponse:(NSString *)action data:(NSString *)dataJson tag:(NSString *)tag;

@end

@implementation NativeBridgeIOS

+ (instancetype)sharedInstance {
    static NativeBridgeIOS *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NativeBridgeIOS alloc] init];
    });
    return instance;
}

- (void)callNative:(NSString *)action data:(NSString *)dataJson tag:(NSString *)tag {
    NSLog(@"[NativeBridgeIOS : callNative] Received action: %@, tag: %@", action, tag);
    
    if ([action isEqualToString:@"echo"]) {
        [self handleEcho:action data:dataJson tag:tag];
    } else {
        [self handleUnknownAction:action data:dataJson tag:tag];
    }
}

- (void)handleEcho:(NSString *)action data:(NSString *)dataJson tag:(NSString *)tag {
    // Echo simply returns the same data
    [self sendResponse:action data:dataJson tag:tag];
}

- (void)handleUnknownAction:(NSString *)action data:(NSString *)dataJson tag:(NSString *)tag {
    NSDictionary *errorDict = @{
        @"error": @"unknown_action",
        @"message": [NSString stringWithFormat:@"Unknown action: %@", action]
    };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:errorDict options:0 error:nil];
    NSString *errorJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [self sendResponse:action data:errorJson tag:tag];
}

- (void)sendResponse:(NSString *)action data:(NSString *)dataJson tag:(NSString *)tag {
    NSLog(@"[NativeBridgeIOS : sendResponse] Send action: %@, tag: %@", action, tag);
    
    // Call back to Godot C++
    native_bridge_send_response(
        [action UTF8String],
        [dataJson UTF8String],
        [tag UTF8String]
    );
}

@end

#ifdef __cplusplus
extern "C" {
#endif

void ios_native_bridge_call_native(const char *action, const char *data_json, const char *tag) {
    NSString *actionStr = [NSString stringWithUTF8String:action];
    NSString *dataStr = [NSString stringWithUTF8String:data_json];
    NSString *tagStr = [NSString stringWithUTF8String:tag];
    
    [[NativeBridgeIOS sharedInstance] callNative:actionStr data:dataStr tag:tagStr];
}

#ifdef __cplusplus
}
#endif
