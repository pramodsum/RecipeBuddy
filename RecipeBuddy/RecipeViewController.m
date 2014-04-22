//
//  RecipeViewController.m
//  RecipeBuddy
//
//  Created by Sumedha Pramod on 4/21/14.
//  Copyright (c) 2014 Sumedha Pramod. All rights reserved.
//

#import "RecipeViewController.h"

@interface RecipeViewController ()

@end

@implementation RecipeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Read ingredients list out loud
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString: _recipe.ingredient_list];
    utterance.rate = AVSpeechUtteranceMinimumSpeechRate;
    [_synthesizer speakUtterance:utterance];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [self.navigationController setTitle:_recipe.name];
    _recipe_image = _recipe.food_image_large;
    _recipe_text.text = _recipe.ingredient_list;
    _yields.text = _recipe.yields;
    _time.text = _recipe.time;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
