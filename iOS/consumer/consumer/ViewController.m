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

typedef NS_ENUM(NSInteger, CUEEngineMode) {
    CUEEngineModeTrigger = 0,
    CUEEngineModeLive = 1,
    CUEEngineModeAscii = 2,
    CUEEngineModeRaw = 3,
};


@interface ViewController() <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextView *outputView;
@property (weak, nonatomic) IBOutlet UIPickerView *modePicker;
@property (weak, nonatomic) IBOutlet UITextField *textEntryField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UISwitch *fullOutputSwitch;
@property CUEEngineMode selectedMode;
@property NSArray *modes;

//@property (weak, nonatomic) IBOutlet UITextView *outputView;
@end

@implementation ViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self setupKeyboardGesture];
    //[self setupViewKeyboardResponse];
    [self setupModesArray];
    [self setupTextEntryField];
    [self setupPickerView];
    [self registerForLocalNotifications];
    
    //disable send button until textEntryField has text
    self.sendButton.enabled = false;
    
    [CUEEngine.sharedInstance setReceiverCallback:
     ^void( NSString* jsonString )
     {
         NSLog(@"CUEEngine viewDidLoad got-trigger-callback with JSON:\n%@", jsonString);
         
         /* * * * * * * * *
          * string -> JSON
          * * * * * * * * */
         NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
         NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
         
         /* * * * * * * * * * *
          * display output
          * * * * * * * * * * */
         
         dispatch_async( dispatch_get_main_queue(), ^{
             
             /* * * * * * * * * * * * *
              * Fill out output string
              * * * * * * * * * * * * */
             
             NSString *outputStr;
             if (self.fullOutputSwitch.isOn) {
                 outputStr = [self formatFullData:jsonObject];
             } else {
                 outputStr = [self formatPartialData:jsonObject];
             }
             
             // If running in background, check to send notification
             [self sendNotificationInBackground:[self getTriggerIndices:jsonObject] andMode:[self getTriggerMode:jsonObject]];
             
             //self.outputLabel.text = symbolString;
             self.outputView.text = [NSString stringWithFormat:@"%@%@", self.outputView.text, outputStr];
         } );
         
     }];
}

- (void) setupModesArray {
    self.modes = @[[NSNumber numberWithInteger:CUEEngineModeTrigger], [NSNumber numberWithInteger:CUEEngineModeLive],[NSNumber numberWithInteger:CUEEngineModeAscii],[NSNumber numberWithInteger:CUEEngineModeRaw]];
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

- (void) setupViewKeyboardResponse {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

- (void) keyboardWillShow {
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 300, self.view.frame.size.width, self.view.frame.size.height);
}

- (void) keyboardWillHide {
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 300, self.view.frame.size.width, self.view.frame.size.height);
}

- (void) dismissKeyboard {
    [self.view endEditing:true];
}

# pragma mark Buttons

- (IBAction)transmit:(id)sender {
    switch (self.selectedMode) {
        case CUEEngineModeTrigger: {
            // Check to see if input is valid "trigger" format of "[0-461].[0-461].[0-461]"
            NSError *error = NULL;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^(([0-9]|[1-8][0-9]|9[0-9]|[1-3][0-9]{2}|4[0-5][0-9]|46[01]).([0-9]|[1-8][0-9]|9[0-9]|[1-3][0-9]{2}|4[0-5][0-9]|46[01]).([0-9]|[1-8][0-9]|9[0-9]|[1-3][0-9]{2}|4[0-5][0-9]|46[01]))$"
                                          options:NSRegularExpressionCaseInsensitive
                                          error:&error];
            
            if ([regex numberOfMatchesInString:self.textEntryField.text options:0 range:NSMakeRange(0, [self.textEntryField.text length])]) {
                //valid Trigger format
                [CUEEngine.sharedInstance queueTrigger:self.textEntryField.text];
            } else {
                //invalid format
                NSLog(@"Invalid Format");
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid Format" message:@"Triggers must be of the format [0-461].[0-461].[0-461]" preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:NULL]];
                [self presentViewController:alert animated:YES completion:NULL];
            }
            break;
        }
        case CUEEngineModeLive: {
            // !!! Engine currently does not have Live output method
            // Check to see if input is valid "live" format of "[0-461]"
            NSError *error = NULL;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^([0-9]|[1-8][0-9]|9[0-9]|[1-3][0-9]{2}|4[0-5][0-9]|46[01])$" options:NSRegularExpressionCaseInsensitive error:&error];
            
            if ([regex numberOfMatchesInString:self.textEntryField.text options:0 range:NSMakeRange(0, [self.textEntryField.text length])]) {
                //valid Trigger format
                [CUEEngine.sharedInstance queueTrigger:self.textEntryField.text];
            } else {
                //invalid format
                NSLog(@"Invalid Format");
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid Format" message:@"Live Triggers must be of the format [0-461]" preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:NULL]];
                [self presentViewController:alert animated:YES completion:NULL];
            }
            //[CUEEngine.sharedInstance queue];
            break;
        }
        case CUEEngineModeAscii:
            [CUEEngine.sharedInstance queueMessage:self.textEntryField.text];
            break;
        case CUEEngineModeRaw:
            [CUEEngine.sharedInstance queueData:self.textEntryField.text];
            break;
        default:
            break;
    }
}

- (IBAction)clearOutput:(id)sender {
    self.outputView.text = @"";
}

# pragma mark UIPickerView

- (void) setupPickerView {
    self.modePicker.delegate = self;
    self.modePicker.dataSource = self;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 4;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (row) {
        case 0:
            return @"Trigger";
            break;
        case 1:
            return @"Live";
            break;
        case 2:
            return @"Ascii";
            break;
        default:
            return @"Raw";
            break;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectedMode = [[self.modes objectAtIndex:row] integerValue];
    
    switch (self.selectedMode) {
        case CUEEngineModeTrigger:
            self.textEntryField.placeholder = @"1.2.34";
            self.textEntryField.keyboardType = UIKeyboardTypeDecimalPad;
            break;
        case CUEEngineModeLive:
            self.textEntryField.placeholder = @"34";
            self.textEntryField.keyboardType = UIKeyboardTypeNumberPad;
            break;
        case CUEEngineModeAscii:
            self.textEntryField.placeholder = @"Hello World";
            self.textEntryField.keyboardType = UIKeyboardTypeDefault;
            break;
        case CUEEngineModeRaw:
            self.textEntryField.placeholder = @"1.23.45.310.418";
            self.textEntryField.keyboardType = UIKeyboardTypeDefault;
            break;
        default:
            break;
    }
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
    self.textEntryField.placeholder = @"1.2.34";
    self.textEntryField.keyboardType = UIKeyboardTypeDecimalPad;
}

#pragma mark Output

- (NSString *) formatFullData: (NSDictionary *) jsonObject {
    NSMutableString* outputStr = [NSMutableString new];
    
    [outputStr setString:@"CUESymbols {\n"];
    
    // mode
    NSString* mode = [jsonObject objectForKey:@"mode"];
    [outputStr appendFormat:@"  mode: %@\n", mode];
    
    // indices
    [outputStr appendFormat:@"  indices: %@\n",
     (NSString*)[jsonObject objectForKey:@"raw-indices"]];
    
    // latency
    NSNumber* latency = [jsonObject objectForKey:@"latency_ms"];
    [outputStr appendFormat:@"  latency: %.2f\n",
     [latency doubleValue]];
    
    // noise
    NSNumber* noise = [jsonObject objectForKey:@"noise"];
    [outputStr appendFormat:@"  noise: %.2f\n",
     [noise doubleValue]];
    
    // power
    NSNumber* power = [jsonObject objectForKey:@"power"];
    [outputStr appendFormat:@"  power: %.2f\n",
     [power doubleValue]];
    
    NSArray* rawCalib = [jsonObject objectForKey:@"raw-calib"];
    [ outputStr appendString:@"  rawCalib: [\n" ];
    for (int i = 0; i < [rawCalib count]; i++) {
        [outputStr appendFormat:@"    %@\n", rawCalib[i] ];
    }
    [outputStr appendString:@"  ]\n"];
    
    NSArray* rawTrigger = [jsonObject objectForKey:@"raw-trigger"];
    [ outputStr appendString:@"  rawTrigger: [\n" ];
    for (int i = 0; i < [rawTrigger count]; i++) {
        [outputStr appendString:@"    [\n"];
        for(int j = 0; j < [rawTrigger[i] count]; j++)
            [outputStr appendFormat:@"      %@\n", rawTrigger[i][j] ];
        
        [outputStr appendString:@"    ]\n"];
    }
    [outputStr appendString:@"  ]\n"];
    
    // winnerIndices
    NSString* winnerIndices = [jsonObject objectForKey:@"winner-indices"];
    [outputStr appendFormat:@"  winnerIndices: %@\n", winnerIndices];
    
    [outputStr appendString:@"}\n\n"];
    
    return outputStr;
}

- (NSString *) formatPartialData: (NSDictionary *) jsonObject {
    NSMutableString* outputStr = [NSMutableString new];
    
    [outputStr setString:@"CUESymbols {\n"];
    
    // mode
    NSString* mode = [jsonObject objectForKey:@"mode"];
    [outputStr appendFormat:@"  mode: %@\n", mode];
    
    // winnerIndices
    NSString* winnerIndices = [jsonObject objectForKey:@"winner-indices"];
    [outputStr appendFormat:@"  winnerIndices: %@\n", winnerIndices];
    
    [outputStr appendString:@"}\n\n"];
    
    return outputStr;
}

- (CUEEngineMode) getTriggerMode: (NSDictionary *) jsonObject {
    NSString* mode = [jsonObject objectForKey:@"mode"];
    if ([mode.lowercaseString isEqualToString:@"trigger"]) {
        return CUEEngineModeTrigger;
    } else if ([mode.lowercaseString isEqualToString:@"live"]) {
        return CUEEngineModeLive;
    } else if ([mode.lowercaseString isEqualToString:@"raw"]) {
        return CUEEngineModeRaw;
    } else return CUEEngineModeAscii;
}

- (NSString *) getTriggerIndices: (NSDictionary *) jsonObject {
    return [jsonObject objectForKey:@"winner-indices"];
}

@end
