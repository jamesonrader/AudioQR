# XT Audio Beacons

Use XT Audio Beacons to synchronize and relay data to mobile devices through speakers or a variety of broadcast media. This data-over-audio method utilizes sound waves in a similar way to how Bluetooth employs electromagnetic waves, offering an alternative method of relaying data for both iOS and Android.

##### Advantages include:

* No reliance on a data connection, including Wi-Fi, Bluetooth, or cellular service.
* Ability to relay data to devices through television broadcasts or any other sound-based media.
* Ability to synchronize devices to the nearest eighth of a second.

# Who’s using XT Audio Beacons?
###### XT Audio Beacons have been enjoyed by over 1,000,000 users across three continents. Some of our clients include the following:

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


# Demo

If the provided demo app is in open on your device, playing the following links from your desktop will trigger various events.


* [Error Recognition](http://qraider.com/XT/Demo/simulated_error.php)
* [Commercial Interaction](http://qraider.com/XT/Demo/product_link.php) (due to audio compression, [video version](http://qraider.com/XT/Demo/ProductPlacement.mov) must be downloaded)
* [Audio Beacon Sample Loop](http://qraider.com/XT/Demo/soundBeaconLoop.wav)
* [Unlockable Content](http://qraider.com/XT/Demo/unlockable_content.php)
* [Podcast](http://qraider.com/XT/Demo/audio_only.wav)
* [Location-Based Notification 1](http://qraider.com/XT/Demo/C-398-399.wav)
* [Location-Based Notification 2](http://qraider.com/XT/Demo/C-399-398.wav)

# Integration

## How it works

Any speaker can become an XT Audio Beacon. XT Audio Beacons are powered by ultrasonic fingerprints, each of which is composed of a permutation of inaudible tones lasting between 0.0005 and 0.002 seconds. The duration of the fingerprint is variable and depends on the amount of data relayed — typically a complete trigger lasts anywhere from 0.30 to 2.0 seconds. 

Data is extracted from a set of 2048 frequency/amplitude vectors derived from incoming audio using a Fast Fourier Transformation (FFT). Over the course of a second, thousands of bits of data can be relayed. Our triggers are concentrated between 16-22 kHz to minimize conflict with environmental noise and to remain human-inaudible. This means that any audio containing our triggers must be in a format that supports high-pitch frequencies (e.g., WAV) and should not be converted or compressed into a lesser format (e.g., MP3).

Ultrasonic fingerprints can be generated to the point where single-use/throwaway triggers can be utilized for authorization and validation purposes, such as check-ins, private keys, and even payment processing. 

##### To receive WAV files beyond those included in the starter pack, please email info@qraider.com. Unique WAV files for check-in and authorization purposes can also generated upon request. Please allow up to 24 hours for a response.

###### Note: before publishing an app containing the XT Ultrasonic Fingerprint framework, please make sure you’ve read the FAQ and terms & conditions located [here.](http://qraider.com/XT/FAQ/)

## iOS

(1) Add `#import <XT/XT.h>` to your header file and make your `UIViewController` a subclass of `XTUltrasonicsViewController`.

(2) Set the `XTdelegate` of the `XTUltrasonicsViewController`, typically `self`.

(3) Implement the method

	- (void) didHearTriggerWithTitle:(NSString *)title andAmplitude:(float) mag

The amplitude measure can be used as a rough indicator of proximity to the outputting speaker.

(4) To get a list of trigger titles, call the method `[self logTriggerTitles]` on the `XTUltrasonicsViewController` subclass. 
	
###### An unlimited number of triggers and trigger titles can be generated, even to the point of creating “throwaway” triggers for authorization and check-in purposes. If more triggers are needed than the default number listed by calling `logTriggerTitles`, simply contact info@qraider.com for customization.

(5) (optional) To control the `UILabel` and `UIActivityIndicator` at the bottom of the screen, use the methods 

* `- (BOOL) changeListeningLabelText: (NSString *) text`
* `- (BOOL) changeListeningLabelTextColor: (UIColor *) color`
* `- (BOOL) changeListeningActivityIndicatorColor: (UIColor *) color`
* `- (void) displayListeningLabel: (BOOL) display WithFadeTime: (float) t`

To stop the label and activity indicator from appearing when the view loads, overwrite the method `- (void) microphonePermissionGranted` and do not call `[super microphonePermissionGranted]`.



### Android

(1) Add the `xt.aar` file to `libs` in your `app` directory. [See here](http://qraider.com/XT/images/android_step_one.png "Android - Step 1")

(2) Add `flatDir { dirs 'libs' }` to repositories in your top-level build gradle. [See here](http://qraider.com/XT/images/android_step_two.png "Android - Step 2")

(3) Subclass `XTUltrasonicsActivity` and implement the method `public void didHearTriggerWithTitle(String title) andAmplitude:(float) mag`. The amplitude measure can be used as a rough indicator of proximity to the outputting speaker.

(4) To get a list of trigger titles, call the method `logTriggerTitles()` on the `XTUltrasonicsActivity` subclass. 

###### An unlimited number of triggers and trigger titles can be generated, even to the point of creating “throwaway” triggers for authorization and check-in purposes. If more triggers are needed than the default number listed by calling `logTriggerTitles()`, simply contact info@qraider.com for customization.

(5) Request microphone permission. This can be handled automatically for you by setting `handleRecordPermissionsForMe = true` in `OnCreate.` To handle recording permission yourself, set `handleRecordPermissionsForMe = false` in `OnCreate.` 

To change the text presented during the microphone permission request process, simply set the following (`public static`) strings in `OnCreate`:

* `kPrePermissionTitle` (Title for dialog that precedes permission request).
* `kPrePermissionBody` (Body for dialog that precedes permission request).
* `kPermissionBodyRejected` (Prompt that leads to app settings if mic permission is denied).
* `kMicPermissionDenyTitle` (If mic permission is denied, the subsequent time the app is opened a dialog is displayed with this title).
* `kMicPermissionDenyBody` (If mic permission is denied, the subsequent time the app is opened a dialog is displayed with this body).

Add to your manifest file:

* `<uses-permission android:name="android.permission.INTERNET" />` 
* `<uses-permission android:name="android.permission.RECORD_AUDIO" />`

(6) (optional) To control the `TextView` at the bottom of the screen, use the methods 

* `protected boolean changeListeningLabelText(String text)`
* `protected boolean changeListeningLabelTextColor(int c)`
* `protected void displayListeningLabelWithFadeTime(boolean display, int t)`

To stop the `TextView` from appearing when the view loads, overwrite the method `public void microphonePermissionGranted()` and do not call `super.microphonePermissionGranted()`.
