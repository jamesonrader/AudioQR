//
//  CUEEngine.h
//  objC_consumer
//
//  Created by π on 12/03/2018.
//  Copyright © 2018 π. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>
#import "CUEErrno.h"

@interface CUEEngine : NSObject

typedef void(^ReceiverCallback)( NSString* _Nonnull json );
typedef void(^RefreshPayloadsCallback)( void );

+ (nonnull CUEEngine*) sharedInstance;

- (void) didEnterForeground;

// you can set the tone callback at any moment in the life-cycle of the object
- (void) setReceiverCallback: (nonnull ReceiverCallback) blk;

// NOTE: If you don't have microphone permission before you setup,
//         iOS will automatically request it.

- (void) setupWithAPIKey: (nonnull NSString*) apiKey; 

- (void) setupWithAPIKey: (nonnull NSString*) apiKey 
           andWithConfig: (nonnull NSString*) config;

// this will trigger an assertion failure if setup didn't complete
- (void) startListening;

- (void) feed:(null_unspecified float*) bufOfFloats
   withNSamps:(int) nSamps
 andWithSRate:(double) sRate;

- (void) stopListening;

- (BOOL) isListening;

- (BOOL) didSetup;

- (CUE_ENGINE_ERROR) queueLive:                 (nonnull NSString*) live;
- (CUE_ENGINE_ERROR) queueLL:                   (nonnull NSString*) message;
- (CUE_ENGINE_ERROR) queueTrigger:              (nonnull NSString*) trigger;
- (CUE_ENGINE_ERROR) queueTriggerAsNumber:      (unsigned long) n;
- (CUE_ENGINE_ERROR) queueMultiTrigger:         (nonnull NSString*) multiTrigger;
- (CUE_ENGINE_ERROR) queueMultiTriggerAsNumber: (const long long) n;
- (CUE_ENGINE_ERROR) queueData:                 (nonnull NSString*) data;
- (CUE_ENGINE_ERROR) queueMessage:              (nonnull NSString*) message;

- (nonnull NSString*) getEngineDeviceId;

- (void) setDefaultGeneration: (int) g;

- (void) refreshPayloads: (nonnull RefreshPayloadsCallback) blk;
- (nonnull NSDictionary*) getPayload: (nonnull NSString*) trigger;

@end
