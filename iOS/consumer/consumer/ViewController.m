//
//  ViewController.m
//  objC_consumer
//
//  Created by CUEAudio on 01/03/2018.
//  © CUEAudio, 2018 to the last syllable of recorded time, all rights reserved.
//

#import "ViewController.h"

#import <engine/CUEEngine.h>

@interface ViewController()
@property (weak, nonatomic) IBOutlet UILabel *ultrasonicDisplayLabel;

@end

// = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

@implementation ViewController

- (void) myMethod: (NSString *) binaryString
{
    self.ultrasonicDisplayLabel.text = binaryString;
}

// - - - - - - - - - - - - - - - - - - - - - - - - -

- (void) viewDidLoad
{
    [super viewDidLoad];
    
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
}

@end

// = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
