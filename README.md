
## Welcome to the world's fastest, longest-range data-over-audio solution. 

Transmit data through inaudible, high-frequency sound waves. Unlike any competing data-over-audio solution, which work only in quiet environments over short distances (a few cm to 3 meters), CUE Audio's solution has successfully broadcasted ultrasonic signals in outdoor environments to crowds of 80,000+ stadium attendees, with a propogation distance of over 150 meters and negligible latency above the speed of sound.  

# CUE Audio

This is a protocol for relaying data through inaudible, ultrasonic sound waves, essentially converting any speaker into an “Audio-Beacon.” This communications protocol utilizes sound waves in a similar way to how Bluetooth employs electromagnetic waves, offering an alternative method for transmitting data for both iOS and Android. 

##### Advantages include:

* No reliance on a data connection, including Wi-Fi, Bluetooth, or cellular service.
* Ability to imperceptibly transmit data through online videos, television broadcasts, or any other sound-based media.
* Enhancing the second-screen experience by allowing mobile devices to be informed of not only of what you are watching, but exactly how far along you are in the program. This also allows second-screens to respond to live events, such as touchdowns or breaking news.
* Enabling proximity-awareness in slow zones and dead spots using existing speaker infrastructure.
* Ability to synchronize devices to the nearest eighth of a second.

# Who’s using CUE Audio?
###### CUE Audio have been enjoyed by over 5,000,000 users across three continents. Some of our clients include the following:

![Purdue University](http://qraider.com/images/clientssmall/purdue.png "Purdue University")
![Maquette University](http://qraider.com/images/clientssmall/marquette.png "Maquette University")
![University of Michigan](http://qraider.com/images/clientssmall/michiganwolverines.png "University of Michigan")
![University of Alabama](http://qraider.com/images/clientssmall/alabama.png "University of Alabama")

![University of Notre Dame](http://qraider.com/images/clientssmall/notredame.png "University of Notre Dame")
![University of Wisconsin](http://qraider.com/images/clientssmall/wisconsin.png "University of Wisconsin")
![Clemson University](http://qraider.com/images/clientssmall/clemson.png "Clemson University")
![University of Nebraska](http://qraider.com/images/clientssmall/nebraska.png "University of Nebraska")

![University of North Carolina](http://qraider.com/images/clientssmall/northcarolina.png "University of North Carolina")
![Oklahoma City Thunder](http://qraider.com/images/clientssmall/thunderokc.png "Oklahoma City Thunder")
![Atlanta Hawks](http://qraider.com/images/clientssmall/atlantahawks.png "Atlanta Hawks")
![Florida Panthers](http://qraider.com/images/clientssmall/floridapanthers.png "Florida Panthers")

[More clients can be viewed here.](https://www.cueaudio.com/)

# Possible uses

* Triggering commands on the smartphone through a television broadcast, online video, radio commercial, film and movies. Users can be rewarded for tuning in; products can be linked to during a featured commercial; coupons can be distributed, etc.

* Turn $10 household speakers into iBeacons. Any speaker emitting a unique fingerprint at regular intervals can be used to detect proximity and trigger events to achieve the same effect as traditional Bluetooth beacons.

* Location-based “push” notifications. Users can be segmented by proximity to various speakers.
 
* Smartphones in the same room or across the globe can be synchronized and given precisely timed commands in real-time, or minutes, hours, or even days after the trigger was detected.

<p align="center">
  <b>Synchronization</b><br>
  <a href="https://youtu.be/ork4Q4eoUg4">Villanova @ Purdue</a> |
  <a href="https://www.youtube.com/watch?v=UkxqUhp2RCk">Iowa @ Purdue</a> |
  <a href="https://www.youtube.com/watch?v=YZZp-idBDpM">Villanova @ Marquette</a>
  <br><br>
  <a href="https://youtu.be/ork4Q4eoUg4"><img src="http://qraider.com/XT/images/purdue.gif"> </a>
</p>
 
* Commands without a data connection. Because the software is triggered by sound, it can perform even where there is no data connection, Wi-Fi, or Bluetooth.
 
* Authorization/ticketing — triggers can be used to verify check-in at an event, or to unlock content on your app.
 
* Indoor location sensing — provide location services more accurate than GPS by making use of the existing speaker infrastructure.

* Wherever your imagination takes you.

## How it works

Any speaker can become CUE-compatible. CUE Audio is powered by ultrasonic fingerprints, each of which is composed of a permutation of inaudible tones lasting between 0.0005 and 0.002 seconds. The duration of the fingerprint is variable and depends on the amount of data relayed — typically a complete trigger lasts anywhere from 0.30 to 2.0 seconds. Over the course of a second, thousands of bits of data can be relayed. Our ultrasonic signals are concentrated between 18-20 kHz to minimize conflict with environmental noise and to remain human-inaudible. This means that any audio containing our triggers must be in a format that supports high-pitch frequencies (e.g., WAV) and should not be converted or compressed into a lesser format (e.g., MP3).

Ultrasonic fingerprints can be generated to the point where single-use/throwaway triggers can be utilized for authorization and validation purposes, such as check-ins, private keys, and even payment processing. 

##### To receive WAV files beyond those included in the starter pack, please contact [hello@cueaudio.com](https://www.cueaudio.com/contact/).


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

# CUE Audio -- Android Demo

To run CUE Audio's ultrasonic engine on Android, simply follow these steps:

(1) Open the `Android/consumer` directory, then open the `consumer` application in Android Studio. 

(2) At the top of `MainActivity.java`, insert your API Key into the following:

`private static final String API_KEY = "myAPIKey"`

(3) Run the project. If your Android Studio gradle settings are not configured, it may be necessary to re-sync your project by selecting `File --> Sync Project with Gradle Files`. 

Now, transmit ultrasonic audio by playing a trigger from the `SampleTones` directory. Upon registering the tone, the device display the binary signal received.

(4) To customize the ultrasonic trigger response, simply modify the following callback within  `MainActivity.java`:

```
CUEEngine.getInstance().setTriggerCallback(new CUEEngineCallbackInterface() {
                @Override
                public void engineCallback(ECM mode, final int[] symbols) {
                    String trigger = null;

                    switch (mode) {
                        case MODE_3_TONE:
                            trigger = String.format("%d,%d,%d", symbols[0], symbols[1], symbols[2]);
                            break;

                        default:
                            break;
                    }

                    if(trigger != null) {
                        final String constTrigger = trigger;
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                mTextView.setText(constTrigger);
                            }
                        });
                    }
                }
            });
```

## Custom Implementation Notes

(1) Make sure you add the cue `engine` AAR library to your project structure:

> Hint: the easiest way to add AARs is to import them as modules. In Android Studio's goto menu `File > New > New Module > Import JAR / ARR`, select AAR to import library files one-by-one. 

(2) After AARs are imported, don't forget to add the dependencies to your `app` project:

```groovy
dependencies {
implementation project(':engine')
...
}
``` 

(3) Setup the engine using your API Key and start listening. 

(4) To stop listening in your project, simply call `CUEEngine.getInstance().stopListening()`.

(5) To check listening status, call `CUEEngine.getInstance().isListening()`.

# API Key
Please only use the included API Key for applications in development, as it is a shared, public API Key and is liable to break at any time. Before pushing a product into production, plaease make sure you have your own API Key by contacting [hello@cueaudio.com](https://www.cueaudio.com/contact/).
