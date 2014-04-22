//
//  RecipeViewController.h
//  RecipeBuddy
//
//  Created by Sumedha Pramod on 4/21/14.
//  Copyright (c) 2014 Sumedha Pramod. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <OpenEars/OpenEarsEventsObserver.h>
#import <OpenEars/LanguageModelGenerator.h>
#import "Recipe.h"

@interface RecipeViewController : UIViewController <OpenEarsEventsObserverDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *recipe_image;
@property (strong, nonatomic) IBOutlet UITextView *recipe_text;
@property (strong, nonatomic) IBOutlet UILabel *yields;
@property (strong, nonatomic) IBOutlet UILabel *time;
@property (strong, nonatomic) IBOutlet UILabel *name;

@property (strong, nonatomic) Recipe *recipe;
- (IBAction)help:(id)sender;

@end
