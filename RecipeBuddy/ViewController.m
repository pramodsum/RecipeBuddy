//
//  ViewController.m
//  RecipeBuddy
//
//  Created by Sumedha Pramod on 4/17/14.
//  Copyright (c) 2014 Sumedha Pramod. All rights reserved.
//

#import "ViewController.h"
#import <OpenEars/OpenEarsLogging.h>
#import "YummlySearch.h"
#import "RecipesTableViewController.h"
#import "AppDelegate.h"
#import "Recipe.h"

@interface ViewController ()

@end

@implementation ViewController {
    NSMutableArray *ingredients;
    AppDelegate *appDelegate;
    NSString *lmPath;
    NSString *dicPath;
    YummlySearch *search;
    BOOL wakeup;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [OpenEarsLogging startOpenEarsLogging];
    wakeup = false;
    ingredients = [[NSMutableArray alloc] init];

    appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);

    [appDelegate.openEarsEventsObserver setDelegate:self];
    [self createLanguageModel];

    if(![appDelegate.pocketsphinxController isSuspended]) {
        [appDelegate.pocketsphinxController startListeningWithLanguageModelAtPath:lmPath dictionaryAtPath:dicPath acousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO];
    } else {
        [appDelegate.pocketsphinxController resumeRecognition];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {

    NSMutableArray * words = [[NSMutableArray alloc] initWithArray:[hypothesis componentsSeparatedByString:@" "]];

    NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);

    if([words[0] isEqual:@"OKAY"] && !wakeup) {
        //Start listening for recipes
        NSLog(@"Starting to listen for ingredients");
        wakeup = true;

        //Check ingredients right after wake up command
        if([words count] > 2) {
            [self addIngredients:[words componentsJoinedByString:@" "]];
        }
    } else if(([words[0] isEqual:@"FINISHED"] || [words[0] isEqual:@"NEXT"] || [words[0] isEqual:@"DONE"]) && wakeup) {
        [appDelegate.pocketsphinxController suspendRecognition];
        if([ingredients count] > 0) {
            [self performSegueWithIdentifier:@"recipeSearch_segue" sender:self];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Uh Oh!"
                                        message:@"Looks like you haven't listed any ingredients. Please call Sous Chef again!"
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
    } else if([words[0] isEqual:@"CLEAR"])  {
        [ingredients removeAllObjects];
        NSLog(@"Cleared ingredient list");
        [_ingredientListView setText:[ingredients componentsJoinedByString:@", "]];
    } else if([words[0] isEqualToString:@"HELP"]) {
        [self help:self];
    } else if(wakeup){
        [self addIngredients:hypothesis];
    } else {
        NSString *message = [NSString stringWithFormat:@"Sounds like you said \"%@\". The Sous Chef couldn't understand you. Try again!", [[hypothesis lowercaseString] capitalizedString]];
        [[[UIAlertView alloc] initWithTitle:@"Huh? Try Again!"
                                    message:message
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (void) addIngredients:(NSString *)hypothesis {
    //Check if ingredient is already in list
    if([ingredients containsObject:hypothesis]) {
        NSLog(@"Ingredient already exists in list, ignoring");
    }
    else {
        [ingredients addObject:hypothesis];
        NSLog(@"Ingredients list so far: %@", ingredients);
        [_ingredientListView setText:[[[ingredients componentsJoinedByString:@", "] lowercaseString] capitalizedString]];
    }
}

 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
    {
    if ([[segue identifier] isEqualToString:@"recipeSearch_segue"]) {
        [appDelegate.pocketsphinxController stopListening];
        search = [[YummlySearch alloc] initWithIngredients:ingredients];

        RecipesTableViewController *vc = (RecipesTableViewController *)[segue destinationViewController];
        [vc setRecipes:[[NSArray alloc] initWithArray:[search getRecipeResults]]];
        [vc setSearch:search];
        [vc.tableView reloadData];
        NSLog(@"Recipes: %lu", (unsigned long)vc.recipes.count);
    }
 }

#pragma mark OpenEars Delegate Functions

- (void) createLanguageModel {
    LanguageModelGenerator *languageModelGenerator = [[LanguageModelGenerator alloc] init];
    NSString *urlString = [[NSBundle mainBundle] pathForResource:@"food_list" ofType:@"txt"];
    NSString *rawText = [NSString stringWithContentsOfFile:urlString encoding:NSUTF8StringEncoding error:nil];
    NSArray *food_list = [rawText componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSString *name = @"ingredients";
    NSError *err = [languageModelGenerator generateLanguageModelFromArray:food_list withFilesNamed:name forAcousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"]];

    NSDictionary *languageGeneratorResults = nil;
    NSLog(@"err %@", err);

    if([err code] == noErr) {
        NSLog(@"err %@", err);

        languageGeneratorResults = [err userInfo];

        lmPath = [languageGeneratorResults objectForKey:@"LMPath"];
        dicPath = [languageGeneratorResults objectForKey:@"DictionaryPath"];

        NSLog(@"languageGeneratorResults: %@", languageGeneratorResults);

    } else {
        NSLog(@"\n--------------------\n--------------------\nError: %@",[err localizedDescription]);
    }
}

- (void) pocketsphinxDidStartCalibration {
	NSLog(@"Pocketsphinx calibration has started.");
}

- (void) pocketsphinxDidCompleteCalibration {
	NSLog(@"Pocketsphinx calibration is complete.");
    [appDelegate.pocketsphinxController suspendRecognition];
    [[[UIAlertView alloc] initWithTitle:@"Your Sous Chef is Ready!" message:@"When you're ready to start listing, please say \"OK\" followed by the ingredients you want in your recipe!\nWhen finished just say \"Next\" or \"Finished\"!"
                               delegate:self
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([[alertView title] isEqualToString:@"Your Sous Chef is Ready!"] || [[alertView title] isEqualToString:@"Need Some Help?"] || [[alertView title] isEqualToString:@"Uh Oh!"]) {
        [appDelegate.pocketsphinxController resumeRecognition];
    }
}

- (void) pocketsphinxDidStartListening {
	NSLog(@"Pocketsphinx is now listening.");
}

- (void) pocketsphinxDidDetectSpeech {
	NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
	NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
//    [self.pocketsphinxController stopListening];
}

- (void) pocketsphinxDidStopListening {
	NSLog(@"Pocketsphinx has stopped listening.");
}

- (void) pocketsphinxDidSuspendRecognition {
	NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
	NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketSphinxContinuousSetupDidFail { // This can let you know that something went wrong with the recognition loop startup. Turn on OPENEARSLOGGING to learn why.
	NSLog(@"Setting up the continuous recognition loop has failed for some reason, please turn on OpenEarsLogging to learn more.");
    [[[UIAlertView alloc] initWithTitle:@"Setup Failed"
                                       message:@"Setting up the continuous recognition loop has failed for some reason, please turn on OpenEarsLogging to learn more. The application did not work at this time. "
                                      delegate:self
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil] show];
}

- (void) testRecognitionCompleted {
	NSLog(@"A test file that was submitted for recognition is now complete.");
}

- (IBAction)help:(id)sender {
    [appDelegate.pocketsphinxController suspendRecognition];
    NSString *message = @"Commands:\nOKAY: Wakes up Sous Chef\nCLEAR: Clears all ingredients\nHELP: Brings up help menu\nNEXT/FINISHED/DONE: Searches for recipes with your specified ingredients\nAnything else recognized will be added as ingredients!";
    [[[UIAlertView alloc] initWithTitle:@"Need Some Help?"
                                message:message
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

@end
