//
//  ViewController.h
//  RecipeBuddy
//
//  Created by Sumedha Pramod on 4/17/14.
//  Copyright (c) 2014 Sumedha Pramod. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <OpenEars/OpenEarsEventsObserver.h>
#import <OpenEars/LanguageModelGenerator.h>

@interface ViewController : UIViewController <OpenEarsEventsObserverDelegate>

@property (strong, nonatomic) IBOutlet UITextView *ingredientListView;
- (IBAction)help:(id)sender;

@end
