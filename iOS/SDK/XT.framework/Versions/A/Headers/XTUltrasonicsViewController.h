//
//  QRTUltrasonicsViewController.h
//  XT
//
//  Created by Jameson Rader on 12/2/16.
//  Copyright © 2016 Q Raider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZAudio.h"


@protocol XTUltrasonicsDelegate <NSObject>
- (void) didHearTriggerWithTitle: (NSString *) title andAmplitude: (float) mag;
- (void) logTriggerTitles;

@optional
- (void) microphonePermissionGranted;
- (BOOL) changeListeningLabelText: (NSString *) text;
- (BOOL) changeListeningLabelTextColor: (UIColor *) color;
- (BOOL) changeListeningActivityIndicatorColor: (UIColor *) color;
- (void) displayListeningLabel: (BOOL) display WithFadeTime: (float) t;
@end

@interface XTUltrasonicsViewController : UIViewController <EZMicrophoneDelegate, EZAudioFFTDelegate, XTUltrasonicsDelegate>

@property (nonatomic, strong) EZMicrophone *microphone;
@property (nonatomic, strong) EZAudioFFTRolling *fft;
@property (nonatomic, assign) id<XTUltrasonicsDelegate> XTdelegate;

@end
