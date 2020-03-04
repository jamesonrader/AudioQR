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

@property int generation;
@property CUEEngineMode mode;

@property double latencyMs;
@property double noise;
@property double power;

@property NSString *rawIndices;
@property (nullable) NSArray<NSNumber *> *rawCalibrations;
@property (nullable) NSArray<NSArray<NSNumber *>*> *rawTrigger;

@property NSString *winnerIndices;
@property unsigned long triggerAsNumber;

@property NSString *rawJsonString;

@property (nullable) NSString *message;

- (instancetype)initWithJsonString: (NSString *) jsonString;

+ (NSString *) modeAsString: (CUEEngineMode) mode;
+ (NSString *) formatFullData: (CUETrigger *) trigger;
+ (NSString *) formatPartialData: (CUETrigger *) trigger;

@end

NS_ASSUME_NONNULL_END
