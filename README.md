
# High Reliability Acoustic Modem  

## CUE Audio

CUE Audio provides an extremely reliable acoustic modem, permitting data exchange between any two devices with a microphone or speaker. CUE typically operates in the near-ultrasonic frequency band (17.5-19.5kHz) in order to be inaudible to the majority of people but detectable by commonplace microphones. Trusted by many of the world's largest brands and deployed on over nine million devices, with CUE you will have access to the world's most advanced acoustic modem.

Unlike alternative data-over-audio solution, which work only in quiet environments over short distances (a few cm to 3 meters), we've utilized this solution to successfully broadcasted ultrasonic signals in indoor/outdoor environments to crowds of 80,000+ stadium attendees, with a propagation distance of over 150 meters and negligible latency above the speed of sound.

##### Advantages include:

* No reliance on a data connection, including Wi-Fi, Bluetooth, or cellular service.
* Ability to imperceptibly transmit data through online videos, television broadcasts, or any other sound-based media.
* Enhancing the second-screen experience by allowing mobile devices to be informed of not only of what you are watching, but exactly how far along you are in the program. This also allows second-screens to respond to live events, such as touchdowns or breaking news.
* Enabling proximity-awareness in slow zones and dead spots using existing speaker infrastructure.
* Ability to synchronize devices to the nearest eighth of a second.

# Who’s using CUE Audio's library?
###### CUE Audio have been enjoyed by over 5,000,000 users across three continents. Past and current clients include:

![Disney](https://d253ypm2x51cw3.cloudfront.net/jpegs/logos/cue-partner-disney.jpg "Disney")
![NCAA](https://d253ypm2x51cw3.cloudfront.net/jpegs/logos/cue-partner-ncaa.jpg "NCAA")
![Nissan](https://d253ypm2x51cw3.cloudfront.net/jpegs/logos/cue-partner-nissan.jpg "Nissan")
![Berkshire Hathaway](https://d253ypm2x51cw3.cloudfront.net/jpegs/logos/cue-partner-berkshire.jpg "Berkshire Hathaway")

![Coca Cola](https://d253ypm2x51cw3.cloudfront.net/jpegs/logos/cue-partner-coke.jpg)
![Genoa Healthcare](https://d253ypm2x51cw3.cloudfront.net/jpegs/logos/cue-partner-genoa.jpg)
![Purdue University](https://d253ypm2x51cw3.cloudfront.net/jpegs/logos/cue-partner-purdue.jpg)
![UNC](https://d253ypm2x51cw3.cloudfront.net/jpegs/logos/cue-partner-unc.jpg)

![Clemson](https://d253ypm2x51cw3.cloudfront.net/jpegs/logos/cue-partner-clemson.jpg)
![Daktronics](https://d253ypm2x51cw3.cloudfront.net/jpegs/logos/cue-partner-daktronics.jpg)
![Edmonton Oilers](https://d253ypm2x51cw3.cloudfront.net/jpegs/logos/cue-partner-oilers.jpg)
![Sherwin Williams](https://d253ypm2x51cw3.cloudfront.net/jpegs/logos/cue-partner-sherwinwilliams.jpg)

# Technical Overview
[See PDF here](./doc/cue-technical-overview.pdf)

# Licensing

Please only use the included API Key for applications in development. The public API Key included in this demo is liable to break at any time. Before pushing a product into production, please make sure you have your own API Key by contacting <hello+github@cueaudio.com>. Learn more at <https://cueaudio.com>.


# Example Use Cases

* Triggering commands on the smartphone through a television broadcast, online video, radio commercial, film and movies. Users can be rewarded for tuning in; products can be linked to during a featured commercial; coupons can be distributed, etc.

* Turn $10 household speakers into iBeacons. Any speaker emitting a unique fingerprint at regular intervals can be used to detect proximity and trigger events to achieve the same effect as traditional Bluetooth beacons.

* Location-based “push” notifications. Users can be segmented by proximity to various speakers.
 
* Smartphones in the same room or across the globe can be synchronized and given precisely timed commands in real-time, or minutes, hours, or even days after the trigger was detected.

<p align="center">
  <b>Arbitrary Device Synchronization</b><br>
  <a href="https://youtu.be/ork4Q4eoUg4">Villanova @ Purdue</a> |
  <a href="https://www.youtube.com/watch?v=UkxqUhp2RCk">Iowa @ Purdue</a> |
  <a href="https://www.youtube.com/watch?v=YZZp-idBDpM">Villanova @ Marquette</a>
  <br><br>
  <a href="https://youtu.be/ork4Q4eoUg4"><img src="http://qraider.com/XT/images/purdue.gif"> </a>
</p>
 
* Commands without a data connection. Because the software is triggered by sound, it can perform even where there is no data connection, Wi-Fi, or Bluetooth.
 
* Authorization/ticketing — triggers can be used to verify check-in at an event, or to unlock content on your app.
 
* Indoor location sensing — provide location services more accurate than GPS by making use of the existing speaker infrastructure.

# Integration Guide

For info on the Demo Project, please [view docs here](https://cueaudio.readme.io/docs/demo-project). An API key is not needed to use the demo project, although one is needed to integrate the library into your own project. 

## iOS
[See iOS Documentation](./doc/iOS_README.md)

## Android
[See Android Documentation](./doc/Android_README.md)

## Technical Details
[Engine Callback Structure](https://cueaudio.readme.io/docs/basic-use-cases#structure-of-a-cuetrigger) 

### Note

For testing the demo projects, since CUE is an ultrasonic communications platform, it is best to using two mobile devices (speaker of `device one` --> mic of `device two`) although you can technically test one one device (speaker of `device one` --> mic of `device one`). 
