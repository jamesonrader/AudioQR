//
//  CUEEngine.h
//  objC_consumer
//
//  Created by π on 12/03/2018.
//  Copyright © 2018 π. All rights reserved.
//

#pragma once

typedef NS_ENUM(NSInteger, ECM) {
    MODE_NONE   = 0,
    MODE_LIVE   = 1,
    MODE_1_TONE = 2,
    MODE_3_TONE = 3,
    MODE_DATA   = 4
};

@interface CUEEngine : NSObject

typedef  void(^Callback)(NSString* toneOrTriggerId);

typedef void(^EngineCallback)(ECM mode, NSArray<NSNumber*>*);

+ (id) sharedInstance;

// you can set the tone callback at any moment in the life-cycle of the object
- (void) setToneCallback:    (Callback) toneCallback;
- (void) setTriggerCallback: (Callback) triggerCallback;
- (void) setEngineCallback:  (EngineCallback) EngineCallback;

// NOTE: If you don't have microphone permission before you setup,
//         iOS will automatically request it.

// uses default engine config
- (void) setup;

// It's ok to pass an empty string (or even NULL)
// The C++ engine will setup with default config.
- (void) setupWithConfig: (NSString*) configString andWithAPIKey:(NSString*) apiKey;

// this will trigger an assertion failure if setup didn't complete
- (void) startListening;

- (void) stopListening;

- (BOOL) isListening;

- (BOOL) didSetup;

- (NSString*) getEngineDeviceId;

@end

