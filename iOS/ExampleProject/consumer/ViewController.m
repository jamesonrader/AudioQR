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
@property (weak, nonatomic) IBOutlet UILabel *outputLabel;
@end

@implementation ViewController

- (void) viewDidLoad
{
    [super viewDidLoad];

    [CUEEngine.sharedInstance setReceiverCallback:
        ^void( NSString* jsonString )
        {
            NSLog(@"CUEEngine viewDidLoad got-trigger-callback with JSON:\n%@", jsonString);

            /* * * * * * * * *
             * string -> JSON
             * * * * * * * * */
            NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            /* * * * * * * * * * * *
             * get symbols from JSON
             */
            NSString *symbolString = [jsonObject objectForKey:@"winner-indices"];
            
            /* * * * * * * * * * *
             * display output
             * * * * * * * * * * */
            
            dispatch_async( dispatch_get_main_queue(), ^{
                self.outputLabel.text = symbolString;
            } );
        }];
}

@end
