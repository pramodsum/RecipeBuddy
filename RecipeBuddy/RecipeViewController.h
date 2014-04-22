//
//  RecipeViewController.h
//  RecipeBuddy
//
//  Created by Sumedha Pramod on 4/21/14.
//  Copyright (c) 2014 Sumedha Pramod. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Recipe.h"

@interface RecipeViewController : UIViewController

@property (strong, nonatomic) AVSpeechSynthesizer *synthesizer;

@property (strong, nonatomic) IBOutlet UIImageView *recipe_image;
@property (strong, nonatomic) IBOutlet UITextView *recipe_text;
@property (strong, nonatomic) Recipe *recipe;
@property (strong, nonatomic) IBOutlet UILabel *yields;
@property (strong, nonatomic) IBOutlet UILabel *time;

@end
