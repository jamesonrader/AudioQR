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

typedef NS_ENUM(NSInteger, CUEEngineValidationResult) {
    SUCCESS                        =  0,
    ERR_NUMBER_OF_SYMBOLS_MISMATCH = -1,
    ERR_NUMBER_OF_SYMBOLS_EXCEEDED = -2,
    ERR_SYMBOL_NOT_A_NUMBER        = -3,
    ERR_INDEX_VALUE_EXCEEDED       = -4,
};

typedef void(^ReceiverCallback)( NSString* json );


+ (id) sharedInstance;

- (void) didEnterForeground;

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

- (void) feed:(float *) bufOfFloats
   withNSamps:(int) nSamps
 andWithSRate:(double) sRate;

- (void) stopListening;

- (BOOL) isListening;

- (BOOL) didSetup;

//- (void) setConfig: (NSString *) config;

- (CUEEngineValidationResult) queueLive:    (NSString *) live;
- (CUEEngineValidationResult) queueTrigger: (NSString *) trigger;
- (CUEEngineValidationResult) queueData:    (NSString *) data;
- (CUEEngineValidationResult) queueMessage: (NSString *) message;

- (NSString*) getEngineDeviceId;

//- (void) setTriggers: (NSArray<NSString*>*) triggerSet;

@end
