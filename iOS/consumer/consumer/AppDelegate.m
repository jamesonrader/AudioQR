//
//  AppDelegate.m
//  objC_consumer
//
//  Created by CUEAudio on 01/03/2018.
//  © CUEAudio, 2018 to the last syllable of recorded time, all rights reserved.

//π. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import <engine/AudioSession.h>
#import <engine/CUEEngine.h>
#import <engine/Config.h>

#import "AppDelegate.h"

#define DEFAULT_CONFIG cfg_11C5x3
#define API_KEY @"N5H0HplaVJYXlqrQZhR1aL0qjp5PSY7U"

// = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

@implementation AppDelegate

- (BOOL)            application: (UIApplication *) application
  didFinishLaunchingWithOptions: (NSDictionary *) launchOptions
{
    if( ! [AudioSession setup] ) {
        NSLog( @"Error setting up AudioSession" );
        return NO;
    }
    
    // Request mic access
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        //if granted, set up engine
        if( granted == YES ) {
            [self setupEngine];
            [self startListening];
        }
    }];
    
    // Override point for customization after application launch.
    return YES;
}

- (void) setupEngine
{
    //run with valid API key or engine may take up to 5 minutes to re-authenticate
    [CUEEngine.sharedInstance setupWithConfig:DEFAULT_CONFIG andWithAPIKey:API_KEY];
}

- (void) startListening {
    [CUEEngine.sharedInstance startListening];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [CUEEngine.sharedInstance stopListening];
}
@end

// = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
