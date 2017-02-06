//
//  ViewController.m
//  XTdemo
//
//  Created by Jameson Rader on 12/2/16.
//  Copyright © 2016 Q Raider. All rights reserved.
//

#import "ViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "btRippleButtton.h"

@interface ViewController () <UIWebViewDelegate, UNUserNotificationCenterDelegate>

//for pulling up web pages when triggered by ultrasonic fingerprint
@property UIWebView *webview;
@property NSString *webviewTitle;
@property UIBarButtonItem *xButton;
@property BOOL webviewIsShowing;

//for "Unlockable Content" demo (see method didHearUltrasonicTriggerWithTitle: AndAmplitude:)
@property UIButton *unlockableContentButton;
@property BOOL contentUnlocked;

//for UI of sound-beacon demo
@property NSTimer *proximityIndicatorTimer;
@property NSTimer *proximityResetTimer;
@property BTRippleButtton *proximityIndicatorView;
@property short int proximityLevel;

@end

@implementation ViewController 

#pragma mark Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set up unlockable content demo
    [self createPadlock];
    
    //set delegate
    self.XTdelegate = self;
    
    //customize "listening label"
    [self changeListeningLabelText:@"listening..."];
    [self changeListeningLabelTextColor:
     [UIColor colorWithRed:(170/255.0f) green:(170/255.0f) blue:(170/255.0f) alpha:1.0f]];
    [self changeListeningActivityIndicatorColor:[UIColor colorWithRed:(170/255.0f) green:(170/255.0f) blue:(170/255.0f) alpha:1.0f]];
    
    //navigation bar
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.title = @"XT Demo";
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //set up UI for sound-beacon demo
    if (_proximityIndicatorTimer == nil) {
        [self setUpSoundBeaconProximityIndicator];
    }
}

#pragma mark XTUltrasonicsDelegate Methods

- (void) didHearTriggerWithTitle:(NSString *)title andAmplitude:(float)mag
{
    /* ----------
    Amplitude can be used as a rough measure of proximity.
    
    For a list of trigger titles, simply call the method [self logTriggerTitles];
    
    Infinite triggers can be produced. For details or customized usage, contact info@qraider.com
     
     
    NOTE: Before publishing your app, make sure you've read the FAQ and terms and conditions located here: http://qraider.com/XT/FAQ/
    ----------- */
    
    //must call super
    [super didHearTriggerWithTitle:title andAmplitude:mag];
    
    
    //================================================================================
    // LIST OF DEMOS
    //================================================================================
    
    
    //each time trigger is heard, have proximity indicator shoot out red rings twice as fast, while page is loading

    //================================================================================
    // PRODUCT DISPLAY
    //================================================================================
    //link to commercial: http://qraider.com/XT/Demo/XTcommercial.html
    if ([title isEqualToString:@"C-400-96"]) {
        [self presentWebViewWithURL:@"http://www.coca-colaproductfacts.com/en/coca-cola-products/coca-cola-zero/" andTitle:@"Coke Zero"];
        
        //set proximity to green to signify loading
        _proximityLevel = 5;
    }
    
    
    //================================================================================
    // ERROR RECOGNITION AND RESPONSE
    //================================================================================
    //link to simulated error: http://qraider.com/XT/Demo/simulated_error.html
    if([title isEqualToString:@"C-300-96"]) {
        [self presentWebViewWithURL:@"https://support.directv.com/equipment/1609"
                           andTitle:@"DirectTV Error 771"];
        
        //set proximity to green to signify loading
        _proximityLevel = 5;
    }
    
    //================================================================================
    // SOUND BEACON
    //================================================================================
    
    /* sound-beacon demo. Rather than have beacon IDs, each sound-beacon emits a unique fingerprint, allowing beacon A to be distinguished from beacon B. Any ultrasonic fingerprint on loop can serve as a beacon track. */
    //link to example loop track: http://qraider.com/XT/Demo/soundBeaconLoop.wav
    if ([title isEqualToString:@"C-99-97"] || [title isEqualToString:@"C-97-99"]) //track is a loop, so order is variable
    {
        
        //set proximity level based on magnitude
        if (mag > 0.05f) {
            _proximityLevel = 4;
        } else if (mag > 0.001f) {
            _proximityLevel = 3;
        } else if (mag > 0.000025f) {
            _proximityLevel = 2;
        } else if (mag != 0.0f) {
            _proximityLevel = 1;
        } else {
            _proximityLevel = 0;
        }
        
        //lower proximity level if ultrasonic fingerprint not heard for 2.0 seconds
        if (_proximityResetTimer) {
            [_proximityResetTimer invalidate];
            _proximityResetTimer = nil;
        }
        
        _proximityResetTimer = [NSTimer
                                    scheduledTimerWithTimeInterval:2.0f
                                    target:self
                                    selector:@selector(resetProximity)
                                    userInfo:nil
                                    repeats:TRUE];
    }

    //================================================================================
    // ULTRASONIC "PUSH" NOTIFICATION (1)
    //================================================================================
    //link to trigger: http://qraider.com/XT/Demo/300-95.wav
    if ([title isEqualToString:@"C-300-95"]) {
        [self localNotificationWithText:@"REMINDER: 10% off all merchandise until the end of the third period."];
    }
    
    //================================================================================
    // ULTRASONIC "PUSH" NOTIFICATION (2)
    //================================================================================
    //link to trigger: http://qraider.com/XT/Demo/400-95.wav
    if ([title isEqualToString:@"C-400-95"]) {
        [self localNotificationWithText:@"Fans, the Thunder are back in town this Thursday night. Click here to purchase your tickets."];
    }
    
    
    //================================================================================
    // COUPON DIALOG
    //================================================================================
    //link to audio: http://qraider.com/XT/Demo/audio_only.wav
    if([title isEqualToString:@"C-400-100"]) {
        [self createAlertWithTitle:@"Thanks for listening!" AndBody:@"Click 'Proceed' to collect a coupon for $5 off a yearly subscription to the Wall Street Journal" AndURL:@"http://subscription.wsj.com/" AndURLTitle:@"The Wall Street Journal" WithPositiveText:@"Proceed" AndCancelOption:YES];
    }
    
    //================================================================================
    // UNLOCKABLE CONTENT
    //================================================================================
    //link to unlockable: http://qraider.com/XT/Demo/unlockable_content.html
    if([title isEqualToString:@"C-96-400"]) {
        [self switchContentLock];
    }
}

- (void) microphonePermissionGranted
{
    [super microphonePermissionGranted];
}

#pragma mark Sound-Beacon Proximity Indicator


- (void) setUpSoundBeaconProximityIndicator
{
    //set up proximity indicator for sound-beacon
    _proximityIndicatorView = [[BTRippleButtton alloc] initWithImage:[UIImage imageNamed:@"speaker.png"] andFrame:CGRectMake(0, 0, 60, 60) onCompletion:nil];
    _proximityIndicatorView.center = CGPointMake(self.view.center.x, self.view.center.y);
    
    [_proximityIndicatorView setRippeEffectEnabled:YES];
    _proximityIndicatorView.userInteractionEnabled = NO;
    [_proximityIndicatorView setRippleEffectWithColor: [UIColor lightGrayColor]];
    [self.view addSubview:_proximityIndicatorView];
    _proximityIndicatorTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                                target:self
                                                              selector:@selector(indicateProximity)
                                                              userInfo:nil
                                                               repeats:YES];
    [_proximityIndicatorTimer fire];
}

- (void) resetProximity
{
    if (_proximityLevel == 5) return;
    
    //lower proximityLevel
    if (_proximityLevel > 0)
        --_proximityLevel;
}

- (void) indicateProximity
{
    if (!_proximityIndicatorView ) return;
    
    //set ripple color and speed depending on proximity
    switch (_proximityLevel) {
        case 5:
            //color: green
            [_proximityIndicatorView setRippleEffectWithColor: [UIColor greenColor]];
            break;
        case 4:
            //color: red
            [_proximityIndicatorView setRippleEffectWithColor: [UIColor redColor]];
            break;
        case 3:
            //color: orange
            [_proximityIndicatorView setRippleEffectWithColor: [UIColor orangeColor]];
            break;
        case 2:
            //color: yellow
            [_proximityIndicatorView setRippleEffectWithColor: [UIColor yellowColor]];
            break;
        case 1:
            //color: blue
            [_proximityIndicatorView setRippleEffectWithColor: [UIColor blueColor]];
            break;
            
        default:
            //color: gray
            [_proximityIndicatorView setRippleEffectWithColor: [UIColor lightGrayColor]];
            break;
    }
    
    //pulse
    [_proximityIndicatorView handleTap:nil];
}

#pragma mark WebView Methods

- (void) presentWebViewWithURL: (NSString *) theURL andTitle:(NSString *) title
{
    UIWebView *webview=[[UIWebView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
    NSURL *nsurl=[NSURL URLWithString:theURL];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    [webview loadRequest:nsrequest];
    webview.delegate = self;
    _webview = webview;
    _webviewTitle = title;
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.title = _webviewTitle;
    if (!_webviewIsShowing) {
        [self.view addSubview:_webview];
        [self.microphone stopFetchingAudio];
        [self switchWebViewShowing];
        _xButton = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:(UIBarButtonSystemItemStop)
                                        target:self
                                        action:@selector(doneButtonTapped)];
        
        self.navigationItem.leftBarButtonItem = _xButton;

    }
}

- (void) doneButtonTapped
{
    if (_webview) {
        [self.microphone startFetchingAudio];
        [_webview performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
        self.navigationItem.leftBarButtonItem = NULL;
        _proximityLevel = 0;
        self.navigationItem.title = @"XT Demo";
        [self performSelector:@selector(switchWebViewShowing) withObject:nil afterDelay:1];
    }
}

- (void) switchWebViewShowing
{
    _webviewIsShowing = !_webviewIsShowing;
}

#pragma mark XTUltrasonic-trigged Local notifications

- (void) localNotificationWithText: (NSString *) text {
    
    if (([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)) {
        //Notification Content
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.body =  [NSString stringWithFormat:@"%@", text];
        content.sound = [UNNotificationSound defaultSound];
        
        //Set Badge Number
        //content.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);
        
        // Deliver the notification in five seconds.
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger
                                                      triggerWithTimeInterval:1.0f repeats:NO];
        
        //Notification Request
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"LocalNotification" content:content trigger:trigger];
        
        //schedule localNotification
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (!error) {
                NSLog(@"add Notification Request succeeded!");
            }
        }];
    } else {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = [[NSDate date] dateByAddingTimeInterval:1];
        notification.alertBody = text;
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    
    
}

#pragma mark - Padlock

- (void) switchContentLock
{
    if (!_contentUnlocked) {
        _contentUnlocked = YES;
        [_unlockableContentButton setImage:[UIImage imageNamed:@"padlock_open"] forState:UIControlStateNormal];
    } else {
        _contentUnlocked = NO;
        [_unlockableContentButton setImage:[UIImage imageNamed:@"padlock_closed"] forState:UIControlStateNormal];
    }
}

- (void) createPadlock
{
    UIButton *buttonview = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [buttonview setImage:[UIImage imageNamed:@"padlock_closed"] forState:UIControlStateNormal];
    buttonview.imageView.contentMode = UIViewContentModeScaleAspectFit;
    buttonview.backgroundColor = [UIColor clearColor];
    [buttonview addTarget:self action:@selector(padlockPressed) forControlEvents:UIControlEventTouchUpInside];
    _unlockableContentButton = buttonview;
    UIBarButtonItem *barbuttonitem =[[UIBarButtonItem alloc] initWithCustomView:buttonview];
    self.navigationItem.rightBarButtonItem = barbuttonitem;
}

- (void) padlockPressed
{
    if (_contentUnlocked) {
        [self createAlertWithTitle:@"Content Unlocked" AndBody:@"Good job." AndURL:@"https://www.youtube.com/watch?v=UkxqUhp2RCk" AndURLTitle:@"Content Unlocked" WithPositiveText:@"Proceed" AndCancelOption:YES];
    } else {
        [self createAlertWithTitle:@"Content Locked" AndBody:@"Unlock content by playing the \"Unlockable Content\" fingerprint." AndURL:NULL AndURLTitle:NULL WithPositiveText:@"OK" AndCancelOption:NO];
    }
}

#pragma mark - UIAlertController

- (void) createAlertWithTitle: (NSString *) title AndBody: (NSString *) body AndURL: (NSString *) theURL AndURLTitle: (NSString *) theURLTitle WithPositiveText: (NSString *) okText AndCancelOption: (BOOL) cancelable
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:body
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    if (cancelable) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
    }
    
    [alertController addAction:[UIAlertAction actionWithTitle:okText style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (theURL && theURLTitle) {
            [self presentWebViewWithURL:theURL andTitle:theURLTitle];
        }
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];

}

#pragma mark - User notification delegate
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    
    NSLog(@"willPresentNotification");
    NSLog(@"%@", notification.request.content.userInfo);
    completionHandler (UNNotificationPresentationOptionAlert);
}

@end
