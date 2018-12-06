//
//  AudioSession.h
//  PiDetector
//
//  Created by Pi on 09/11/2010.
//

#include <CoreAudio/CoreAudioTypes.h>
// ^ for AudioStreamBasicDescription (digging thru AudioToolbox/AudioToolbox.h)

// Must be power-of-2
#define POT_AUDIOBUFLEN 256

@interface AudioSession : NSObject

+ (bool) setup;

@end
