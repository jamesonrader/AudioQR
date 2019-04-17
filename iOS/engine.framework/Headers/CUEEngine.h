//
//  CUEEngine.h
//  objC_consumer
//
//  Created by π on 12/03/2018.
//  Copyright © 2018 π. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

@interface CUEEngine : NSObject

typedef void(^ReceiverCallback)( NSString* json );


+ (id) sharedInstance;

// you can set the tone callback at any moment in the life-cycle of the object
- (void) setReceiverCallback: (ReceiverCallback) blk;

// NOTE: If you don't have microphone permission before you setup,
//         iOS will automatically request it.

// uses default engine config
- (void) setup;

// It's ok to pass an empty string (or even NULL)
// The C++ engine will setup with default config.
- (void) setupWithAPIKey: (NSString*) apiKey; 

// this will trigger an assertion failure if setup didn't complete
- (void) startListening;

- (void) stopListening;

- (BOOL) isListening;

- (BOOL) didSetup;

//- (void) setConfig: (NSString *) config;

- (void) transmitMessage: (NSString *) message;

- (NSString*) getEngineDeviceId;

//- (void) setTriggers: (NSArray<NSString*>*) triggerSet;

@end
