//
//  CUETrigger.h
//  engine
//
//  Created by Jameson Rader on 6/25/19.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CUEEngineMode) {
    CUEEngineModeUnknown = -1,
    CUEEngineModeTrigger = 0,
    CUEEngineModeLive = 1,
    CUEEngineModeAscii = 2,
};

NS_ASSUME_NONNULL_BEGIN

@interface CUETrigger : NSObject

@property CUEEngineMode mode;

@property double latencyMs;
@property double noise;
@property double power;

@property NSString *rawIndices;
@property NSArray<NSNumber *> *rawCalibrations;
@property NSArray<NSArray<NSNumber *>*> *rawTrigger;

@property NSString *winnerIndices;

@property NSString *rawJsonString;

@property NSString *message;

- (instancetype)initWithJsonString: (NSString *) jsonString;

+ (NSString *) modeAsString: (CUEEngineMode) mode;
+ (NSString *) formatFullData: (CUETrigger *) trigger;
+ (NSString *) formatPartialData: (CUETrigger *) trigger;

@end

NS_ASSUME_NONNULL_END
