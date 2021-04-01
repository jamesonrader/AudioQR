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
    CUEEngineModeMultiTrigger = 1,
    CUEEngineModeLive = 2,
    CUEEngineModeLL = 3,
    CUEEngineModeData = 4
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
@property long long triggerAsNumber;

@property NSString *rawJsonString;

@property (nullable) NSString *message;

@property NSDictionary *payload;

- (instancetype)initWithJsonString: (NSString *) jsonString;

+ (NSString *) modeAsString: (CUEEngineMode) mode;
+ (NSString *) formatFullData: (CUETrigger *) trigger;
+ (NSString *) formatPartialData: (CUETrigger *) trigger;

@end

NS_ASSUME_NONNULL_END
