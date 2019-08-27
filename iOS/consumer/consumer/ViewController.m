//
//  ViewController.m
//  objC_consumer
//
//  Created by CUEAudio on 01/03/2018.
//  © CUEAudio, 2018 to the last syllable of recorded time, all rights reserved.
//

#import "ViewController.h"
#import <UserNotifications/UserNotifications.h>

#import <engine/CUEEngine.h>
#import <engine/CUETrigger.h>

@interface ViewController() <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextView *outputView;
@property (weak, nonatomic) IBOutlet UIPickerView *modePicker;
@property (weak, nonatomic) IBOutlet UITextField *textEntryField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UISwitch *fullOutputSwitch;
@property CUEEngineMode selectedMode;
@property NSArray *modes;
@property UIBarButtonItem *playButton;
@property UIBarButtonItem *pauseButton;

@end

@implementation ViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self setupKeyboardGesture];
    [self setupModesArray];
    [self setupTextEntryField];
    [self setupPickerView];
    [self setupPlayPauseButtons];
    [self registerForLocalNotifications];
    [self setupCUEEngineCallback];
}

- (void) setupCUEEngineCallback {
    [CUEEngine.sharedInstance setReceiverCallback:
     ^void( NSString* jsonString )
     {
         NSLog(@"CUEEngine viewDidLoad got-trigger-callback with JSON:\n%@", jsonString);
         CUETrigger *trigger = [[CUETrigger alloc] initWithJsonString:jsonString];
         
         /* * * * * * * * * * *
          * display output
          * * * * * * * * * * */
         
         dispatch_async( dispatch_get_main_queue(), ^{
             
             /* * * * * * * * * * * * *
              * Fill out output string
              * * * * * * * * * * * * */
             
             NSString *outputStr;
             if (self.fullOutputSwitch.isOn) {
                 outputStr = [CUETrigger formatFullData:trigger];
             } else {
                 outputStr = [CUETrigger formatPartialData:trigger];
             }
             
             // If running in background, check to send notification
             [self sendNotificationInBackground:trigger.rawIndices andMode:trigger.mode];
             
             self.outputView.text = [self.outputView.text stringByAppendingString:outputStr];
             
             /* Scroll to bottom */
             NSRange bottomLine = NSMakeRange(self.outputView.text.length - 1, 1);
             [self.outputView scrollRangeToVisible:bottomLine];
         } );
         
     }];
}

- (void) setupPlayPauseButtons {
    //disable send button until textEntryField has text
    self.sendButton.enabled = false;
    
    self.playButton = [[UIBarButtonItem alloc]
                       initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                       target:self action:@selector(playButtonTapped)];
    
    self.pauseButton = [[UIBarButtonItem alloc]
                        initWithBarButtonSystemItem:UIBarButtonSystemItemPause
                        target:self action:@selector(pauseButtonTapped)];
    
    
    self.navigationItem.rightBarButtonItem = self.pauseButton;
}

- (void) setupModesArray {
    self.modes = @[[NSNumber numberWithInteger:CUEEngineModeTrigger],
                   [NSNumber numberWithInteger:CUEEngineModeLive],
                   [NSNumber numberWithInteger:CUEEngineModeAscii]];
}

#pragma mark Notifications

- (void) registerForLocalNotifications {
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNNotificationPresentationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            NSLog(@"Notification Permission Granted");
        }
    }];
}

- (void) sendNotificationInBackground:(NSString *) trigger andMode: (CUEEngineMode) mode {
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.sound = [UNNotificationSound defaultSound];
    
    // For specific trigger, create pre-set local notification
    if ([trigger isEqualToString:@"1.2.3"]) {
        content.title = @"My Ultrasonic Notification";
        content.body = @"Hello World!";
        
    } else {
        content.title = trigger;
    }
    
    UNTimeIntervalNotificationTrigger *notificationTrigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
    NSString *identifier = @"CUELocalNotification";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier
                                                                          content:content trigger:notificationTrigger];
    
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Something went wrong: %@",error);
        }
    }];
}

#pragma mark Keyboard

- (void) setupKeyboardGesture {
    UITapGestureRecognizer * dismissGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:dismissGesture];
}

- (void) dismissKeyboard {
    [self.view endEditing:true];
}

- (IBAction)clearOutput:(id)sender {
    self.outputView.text = @"";
}

# pragma mark Buttons

- (void)playButtonTapped {
    [CUEEngine.sharedInstance startListening];
    self.navigationItem.rightBarButtonItem = self.pauseButton;
}

- (void)pauseButtonTapped {
    [CUEEngine.sharedInstance stopListening];
    self.navigationItem.rightBarButtonItem = self.playButton;
}

# pragma mark Transmit

- (IBAction)transmit:(id)sender {
    int validationResult = 0;

    [[self view] endEditing:YES];

    switch (self.selectedMode) {
        case CUEEngineModeTrigger: {
            NSString* decimalPoint = NSLocale.currentLocale.decimalSeparator;
            NSString* triggerStr = [self.textEntryField.text stringByReplacingOccurrencesOfString:decimalPoint withString:@"."];

            validationResult = [CUEEngine.sharedInstance queueTrigger:triggerStr];
            if(validationResult < 0) {
                //invalid format
                NSString* alertMsg = [
                    NSString stringWithFormat:@"Triggers must be of the format [0-461]%@[0-461]%@[0-461]",
                    decimalPoint, decimalPoint ];
                NSLog(@"Invalid Format");

                UIAlertController *alert = [ UIAlertController
                    alertControllerWithTitle:@"Invalid Format" message:alertMsg
                    preferredStyle:UIAlertControllerStyleAlert ];

                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:NULL]];
                [self presentViewController:alert animated:YES completion:NULL];
            }

            break;
        }
        case CUEEngineModeLive: {
            validationResult = [CUEEngine.sharedInstance queueLive:self.textEntryField.text];
            if(validationResult < 0) {
                //invalid format
                NSLog(@"Invalid Format");
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid Format" message:@"Live Triggers must be of the format [0-461]" preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:NULL]];
                [self presentViewController:alert animated:YES completion:NULL];
            }

            break;
        }
        case CUEEngineModeAscii: {
            validationResult = [CUEEngine.sharedInstance queueMessage:self.textEntryField.text];
            if(validationResult < 0) {
                //invalid format
                NSLog(@"Invalid Format");
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid Format" message:@"Ascii stream can not contain more then 10 symbols" preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:NULL]];
                [self presentViewController:alert animated:YES completion:NULL];
            }
            break;
        }
        default:
            break;
    }
}

# pragma mark UIPickerView

- (void) setupPickerView {
    self.modePicker.delegate = self;
    self.modePicker.dataSource = self;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.modes count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (row) {
        case 0:
            return @"Trigger";
        case 1:
            return @"Live";
        default:
            return @"Ascii";
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectedMode = [[self.modes objectAtIndex:row] integerValue];
    switch (self.selectedMode) {
        case CUEEngineModeTrigger:{
            NSString* decimalPoint = NSLocale.currentLocale.decimalSeparator;
            self.textEntryField.placeholder = [
                NSString stringWithFormat:@"1%@2%@34",
                decimalPoint, decimalPoint ];
            [self setKeyboardType:UIKeyboardTypeDecimalPad];
            break;
        }
        case CUEEngineModeLive:
            self.textEntryField.placeholder = @"34";
            [self setKeyboardType:UIKeyboardTypeNumberPad];
            break;
        case CUEEngineModeAscii:
            self.textEntryField.placeholder = @"Hello World";
            [self setKeyboardType:UIKeyboardTypeDefault];
            break;
        default:
            break;
    }
}

- (void)setKeyboardType:(UIKeyboardType)kbType
{
    self.textEntryField.keyboardType = kbType;
    [self.textEntryField reloadInputViews];
}

# pragma mark UITextField

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (string.length) {
        self.sendButton.enabled = true;
    } else self.sendButton.enabled = false;
    
    return true;
}

- (void) setupTextEntryField {
    self.textEntryField.delegate = self;
    NSString* decimalPoint = NSLocale.currentLocale.decimalSeparator;
    self.textEntryField.placeholder = [
        NSString stringWithFormat:@"1%@2%@34", decimalPoint, decimalPoint ];
    self.textEntryField.keyboardType = UIKeyboardTypeDecimalPad;
}

@end
