# CUE Engine - iOS

## Accessing CUEEngine

1. Make sure you have `CocoaPods` and the `CocoaPods Artifactory` plugin installed. You can do so with the following commands using Homebrew:

```
brew install cocoapods
gem install cocoapods-art
```

2. Add credentials to allow you to use the CUEEngine CocoaPod. In ~/.netrc (create this file if necessary) insert your credentials:
```
machine cueaudio.jfrog.io
login <username>
password <pass>
```
3. To use this CocoaPod, execute the command `pod repo-art add cocoapods-local "https://cueaudio.jfrog.io/cueaudio/api/pods/cocoapods-local"` in your project's root directory via the command line.

4. Finally, run `pod install`

5. To update the engine version in the future, run: 

```
pod repo-art update cocoapods-local 
pod install
```

The engine version can then be updated in your `Podfile`. An example of such a podfile is:

```
# Uncomment the next line to define a global platform for your project
platform :ios, '10.3'

plugin 'cocoapods-art', :sources => [
  'cocoapods-local'
]

source 'https://github.com/CocoaPods/Specs.git'

target 'MyProj' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  use_frameworks!

  # Pods for consumer

  project 'MyProj.xcodeproj'
  pod "engine", '1.11.1-Debug'

end
```

## Using the Demo Project

To run CUE Audio's ultrasonic engine on iOS, simply follow these steps:

(1) Go into `iOS/consumer` and open `consumer.xcodeproj` in Xcode

(2) At the top of `AppDelegate.m`, insert your API Key into the following:

`#define API_KEY @"yourAPIKey"`

(3) Run the project. Transmit ultrasonic audio by playing a trigger from the `SampleTones` directory. Upon registering the tone, the device display the binary signal received.

(4) To customize the ultrasonic trigger response, simply modify the following callback within your `ViewController.m` file:

```objective-c
[CUEEngine.sharedInstance setReceiverCallback:
        ^void( NSString* jsonString )
        {
            //handle engine JSON here
        }
     ];
```

## Custom Implementation 

1. In your `Info.plist` file, make sure you set `Privacy - Microphone Usage Description`.

2. Make sure to enable microphone access in your app.

3. Configure the Audio Session:

`#import <engine/AudioSession.h>`

Then call the method `[AudioSession setup]`. The audio session should always be properly configured if the engine is to function as designed. A good place to call this is in `application didFinishLaunchingWithOptions:`. 

4. Next, setup the engine using your API key:

`[CUEEngine.sharedInstance setupWithAPIKey:API_KEY];`

You can start and stop listening with the methods:

```objective-c
[CUEEngine.sharedInstance startListening];
[CUEEngine.sharedInstance stopListening];
```

5. To decode data from the engine, set the engine's `ReceiverCallback`. This is the block of code that will execute each time an ultrasonic signal is detected. An example is:

```objective-c
[CUEEngine.sharedInstance setReceiverCallback:^(NSString *json) {
        NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        //get triggerID
        NSString *symbolString = [jsonDict objectForKey:@"winner-indices"];
        
        NSLog(@"Trigger Detected with SymbolString: %@", symbolString);
    }];
```

For details on the structure of the returned JSON, see [here](CUEEngine_JSON_Structure.md).
