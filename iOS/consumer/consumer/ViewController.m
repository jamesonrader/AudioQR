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
#import <engine/CUEErrno.h>

@interface ViewController() <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextView *outputView;
@property (weak, nonatomic) IBOutlet UIPickerView *modePicker;
@property (weak, nonatomic) IBOutlet UITextField *textEntryField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UISwitch *fullOutputSwitch;

@property CUEEngineMode selectedMode;
@property BOOL triggerAsNumber;

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
             
             /* * * * * * * * * * * * *
             * Get trigger as number
             * * * * * * * * * * * * */
             long triggerNum = [trigger triggerAsNumber];
             NSLog(@"%li", triggerNum);
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

- (void)issueAlertWithTitle: (NSString*)title
                 andMessage: (NSString*)message 
{
    UIAlertController *alert = [ UIAlertController
        alertControllerWithTitle:title 
                         message:message
                  preferredStyle:UIAlertControllerStyleAlert
    ];

    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:NULL]];
    [self presentViewController:alert animated:YES completion:NULL];
}

# pragma mark Transmit

- (IBAction)transmit:(id)sender {
    CUEEngineValidationResult validationResult = 0;

    [[self view] endEditing:YES];

    switch (self.selectedMode) {
        case CUEEngineModeTrigger: {
            if(self.triggerAsNumber) {
                NSString* num_s = [[self textEntryField] text];
                BOOL isNum = true;
                for( int i = 0; i < [num_s length]; i++) {
                    int c = [num_s characterAtIndex:i];
                    isNum = isdigit(c);
                    if(! isNum) {
                        [self issueAlertWithTitle:@"Invalid format" andMessage:@"Should be a number in a range: 0-98611127"];
                        return;
                    }
                }
                unsigned long number = (unsigned long) [num_s longLongValue];
                validationResult = [CUEEngine.sharedInstance queueTriggerAsNumber:number];
                if( validationResult == CUE_ENGINE_ERR_G1_TRIGGER_AS_NUMBER_UNSUPPORTED ) {
                    [ self issueAlertWithTitle:@"Unsupported"  
                                    andMessage:@"Triggers as number sending is unsupported for engine generation 1" ];
                }
                else if( validationResult == CUE_ENGINE_ERR_TRIGGER_AS_NUMBER_MAX_NUMBER_EXCEEDED ) {
                    [ self issueAlertWithTitle:@"Invalid Format"
                                    andMessage:@"Trigger us number can not exceed 98611127" ];
                }
            } else {
                NSString* decimalPoint = NSLocale.currentLocale.decimalSeparator;
                NSString* triggerStr = [self.textEntryField.text stringByReplacingOccurrencesOfString:decimalPoint withString:@"."];

                validationResult = [CUEEngine.sharedInstance queueTrigger:triggerStr];
                if(validationResult < 0) {
                    NSString* alertMsg = [
                        NSString stringWithFormat:@"Triggers must be of the format [0-461]%@[0-461]%@[0-461]",
                        decimalPoint, decimalPoint ];
     
                    [ self issueAlertWithTitle:@"Invalid Format"
                                    andMessage:alertMsg ];
                }
            }

            break;
        }
        case CUEEngineModeLive: {
            validationResult = [CUEEngine.sharedInstance queueLive:self.textEntryField.text];
            if(validationResult == CUE_ENGINE_ERR_G2_QUEUE_LIVE_UNSUPPORTED) {
                [ self issueAlertWithTitle:@"Unsupported"  
                                andMessage:@"Live triggers sending is unsupported for engine generation 2" ];
            }
            else if(validationResult < 0) {
                [ self issueAlertWithTitle:@"Invalid Format"
                                andMessage:@"Live Triggers must be of the format [0-461]" ];
            }

            break;
        }
        case CUEEngineModeAscii: {
            validationResult = [CUEEngine.sharedInstance queueMessage:self.textEntryField.text];
            if(validationResult == CUE_ENGINE_ERR_G2_QUEUE_MESSAGE_STRING_SIZE_IN_BYTES_EXCEEDED  ) {
                [ self issueAlertWithTitle:@"Invalid Format"
                                andMessage:@"Ascii stream can not containt more then 256 symbols" ];
            } else if( validationResult == CUE_ENGINE_ERR_G1_NUMBER_OF_SYMBOLS_EXCEEDED ) {
                [ self issueAlertWithTitle:@"Invalid Format"
                                andMessage:@"Ascii stream can not contain more then 10 symbols" ];
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
    return [self.modes count] + 1;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (row) {
        case 0:
            return @"Trigger";
        case 1:
            return @"Number";
        case 2:
            return @"Live";
        default:
            return @"Ascii";
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //self.selectedMode = [[self.modes objectAtIndex:row] integerValue];
    self.triggerAsNumber = NO;

    switch(row) {
        case 0:
            self.selectedMode = CUEEngineModeTrigger;
            break;
        case 1:
            self.selectedMode = CUEEngineModeTrigger;
            self.triggerAsNumber = YES;
            break;
        case 2:
            self.selectedMode = CUEEngineModeLive;
            break;
        default:
            self.selectedMode = CUEEngineModeAscii;
            break;
    }

    switch (self.selectedMode) {
        case CUEEngineModeTrigger:{
            if(self.triggerAsNumber) {
                self.textEntryField.placeholder = @"123123";
                [self setKeyboardType:UIKeyboardTypeNumberPad];
            } else {
                NSString* decimalPoint = NSLocale.currentLocale.decimalSeparator;
                self.textEntryField.placeholder = [
                    NSString stringWithFormat:@"1%@2%@34",
                    decimalPoint, decimalPoint ];
                [self setKeyboardType:UIKeyboardTypeDecimalPad];
            }
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

- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason {
    if (textField.text.length) {
        self.sendButton.enabled = true;
    } else self.sendButton.enabled = false;
}

- (void) setupTextEntryField {
    self.textEntryField.delegate = self;
    NSString* decimalPoint = NSLocale.currentLocale.decimalSeparator;
    self.textEntryField.placeholder = [
        NSString stringWithFormat:@"1%@2%@34", decimalPoint, decimalPoint ];
    self.textEntryField.keyboardType = UIKeyboardTypeDecimalPad;
}

@end
