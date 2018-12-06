# CUE Audio -- iOS Demo

To run CUE Audio's ultrasonic engine on iOS, simply follow these steps:

(1) Go into `iOS/consumer` and open `consumer.xcodeproj` in Xcode

(2) At the top of `AppDelegate.m`, insert your API Key into the following:

`#define API_KEY @"yourAPIKey"`

(3) Run the project. Transmit ultrasonic audio by playing a trigger from the `SampleTones` directory. Upon registering the tone, the device display the binary signal received.

(4) To customize the ultrasonic trigger response, simply modify the following callback within your `ViewController.m` file:

```
[CUEEngine.sharedInstance setEngineCallback:^ void( ECM mode, NSArray<NSNumber*>* symbols) {
        NSString* trigger = NULL;
        
        switch (mode)
        {       
            case MODE_3_TONE:
                trigger = [NSString stringWithFormat:@"%@,%@,%@", symbols[0], symbols[1], symbols[2]];
                break;
            
            default:
                break;
        }
        
        if(trigger != NULL) {
            //modify UI on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [self myMethod: trigger];
            });
        }
    }];
```

## Custom Implementation Notes 

(1) Copy `engine.framework`, `Accelerate.framework`, and `libc++.tbd` into `Link Binary With Libraries` within the `Build Phases`  tab in your target.

(2) In your `Info.plist` file, make sure you set `Privacy - Microphone Usage Description`.

(3) Import the necessary header files:

```
#import <engine/AudioSession.h>
#import <engine/CUEEngine.h>
#import <engine/Config.h>
```

(3) Before you start listening in your project, make sure to configure the audio session by calling:

`[AudioSession setup]`

(4) Setup the engine using your API Key and start listening. 

(5) To stop listening in your project, simply call `[CUEEngine.sharedInstance stopListening]`.

(6) To check listening status, call `[CUEEngine.sharedInstance isListening]`.

(7) If you would like to have custom microphone on-boarding UI, display the custom component before setting up the engine. Otherwise, iOS will automatically request microphone permission upon engine setup. 