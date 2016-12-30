# QRT Ultrasonic Fingerprints

Use "ultrasonic fingerprints" to synchronize and/or relay data to devices through a variety of broadcast media. This data-over-audio method uses sound waves analogously to how Bluetooth employs electromagnetic waves, offering an alternative method of relaying data for both iOS and Android.

##### Advantages include:

* No reliance on a data connection, including Wi-Fi, Bluetooth, or cellular service.
* Ability to relay data to devices through television broadcasts or any other sound-based media.
* Ability to synchronize devices to the nearest eighth of a second.

# Who’s using QRT Ultrasonic Fingerprints?
###### So far we’ve used our SDK for several organizations, including:

![Purdue University](http://qraider.com/images/clientssmall/purdue.png "Purdue University")
![Maquette University](http://qraider.com/images/clientssmall/marquette.png "Maquette University")
![University of Michigan](http://qraider.com/images/clientssmall/michiganwolverines.png "")
![University of Alabama](http://qraider.com/images/clientssmall/alabama.png "University of Alabama")

![University of Notre Dame](http://qraider.com/images/clientssmall/notredame.png "")
![University of Wisconsin](http://qraider.com/images/clientssmall/wisconsin.png "University of Wisconsin")
![Clemson University](http://qraider.com/images/clientssmall/clemson.png "")
![University of Nebraska](http://qraider.com/images/clientssmall/nebraska.png "University of Nebraska")

![University of North Carolina](http://qraider.com/images/clientssmall/northcarolina.png "University of North Carolina")
![Oklahoma City Thunder](http://qraider.com/images/clientssmall/thunderokc.png "Oklahoma City Thunder")
![Atlanta Hawks](http://qraider.com/images/clientssmall/atlantahawks.png "")
![Florida Panthers](http://qraider.com/images/clientssmall/floridapanthers.png "Florida Panthers")


# Possible uses

* Triggering commands on the smartphone through a television broadcast, online video, radio commercial, film and movies. Users can be rewarded for tuning in; products can be linked to during a featured commercial; coupons can be distributed, etc.
 
* Smartphones in the same room or across the globe can be synchronized and given precisely timed commands in real-time, or minutes, hours, or even days after the trigger was detected.
 
* Concerts, sporting events, and live shows — make the crowd your canvas.

<p align="center">
  <b>Synchronization</b><br>
  <a href="https://youtu.be/ork4Q4eoUg4">Villanova @ Purdue</a> |
  <a href="https://www.youtube.com/watch?v=UkxqUhp2RCk">Iowa @ Purdue</a> |
  <a href="https://www.youtube.com/watch?v=YZZp-idBDpM">Villanova @ Marquette</a>
  <br><br>
  <img src="http://qraider.com/XT/images/purdue.gif">
</p>
 
* Commands without a data connection. Because the software is triggered by sound, it can perform even where there is no data connection, WIFI, or Bluetooth.
 
* Authorization — triggers can be used to verify check-in at an event, or to unlock content on your app.
 
* Beacon alternative — anything accomplished by an iBeacon can be accomplished simply with a speaker emitting one of our triggers at regular intervals.
 
* Indoor location sensing — provide location services more accurate than GPS with just making use of the existing speaker infrastructure.

* Anything else you put your mind to.

# Demo

If the provided demo app is in open on your device, playing the following links from your desktop will trigger various events.

* [Televison Interaction](http://qraider.com/XT/Demo/product_link.php)
* [Unlockable Content](http://qraider.com/XT/Demo/unlockable_content.php)
* [Error Recognition](http://qraider.com/XT/Demo/simulated_error.php)
* [Podcast](http://qraider.com/XT/Demo/audio_only.wav)
* [Ultrasonic “Push” Notification 1](http://qraider.com/XT/Demo/300-95.wav)
* [Ultrasonic “Push” Notification 2](http://qraider.com/XT/Demo/400-95.wav)

# Integration

## iOS

(1) Add `#import <XT/XT.h>` to your header file and make your `UIViewController` a subclass of `QRTUltrasonicsViewController`.

(2) Set the `QRTdelegate` of the `QRTUltrasonicsViewController`, typically `self`.

(3) Implement the method

	- (void) didHearTriggerWithTitle:(NSString *)title

(4) To get a list of trigger titles, call the method `[self logTriggerTitles]` on the `QRTUltrasonicsViewController` subclass. 
	
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

(3) Subclass `QRTUltrasonicsActivity` and implement the method `public void didHearTriggerWithTitle(String title)`. 

(4) To get a list of trigger titles, call the method `logTriggerTitles()` on the `QRTUltrasonicsActivity` subclass. 

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
