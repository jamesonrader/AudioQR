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

#import "AppDelegate.h"

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
    
    return YES;
}

- (void) setupEngine
{
    [CUEEngine.sharedInstance setupWithAPIKey:API_KEY];
    [CUEEngine.sharedInstance setDefaultGeneration:2];
}

- (void) startListening {
    [CUEEngine.sharedInstance startListening];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    //to not listen in the background
    [CUEEngine.sharedInstance stopListening];
}

@end

// = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
