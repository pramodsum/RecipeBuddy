//
//  ViewController.m
//  RecipeBuddy
//
//  Created by Sumedha Pramod on 4/17/14.
//  Copyright (c) 2014 Sumedha Pramod. All rights reserved.
//

#import "ViewController.h"
#import <OpenEars/OpenEarsLogging.h>
#import "RecipePuppySearch.h"
#import "RecipesTableViewController.h"

@interface ViewController ()

@end

@implementation ViewController {
    NSMutableArray *ingredients;
    NSString *lmPath;
    NSString *dicPath;
    RecipePuppySearch *search;
}

@synthesize openEarsEventsObserver;

@synthesize pocketsphinxController;
@synthesize fliteController;
@synthesize usingStartLanguageModel;
@synthesize slt;
@synthesize restartAttemptsDueToPermissionRequests;
@synthesize startupFailedDueToLackOfPermissions;
@synthesize heardText;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [OpenEarsLogging startOpenEarsLogging];
    ingredients = [[NSMutableArray alloc] init];
    [self.openEarsEventsObserver setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [self createLanguageModel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {

	NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);

    //Check if ingredient is already in list
    if([ingredients containsObject:hypothesis]) {
        NSLog(@"Ingredient already exists in list, ignoring");
    }
    else {
        [ingredients addObject:hypothesis];
        NSLog(@"Ingredients list so far: %@", ingredients);
        [[[UIAlertView alloc] initWithTitle:@"Ingredient Added" message:hypothesis
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (IBAction)startListingIngredients:(id)sender {
    [self.pocketsphinxController startListeningWithLanguageModelAtPath:lmPath dictionaryAtPath:dicPath acousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO];
}

- (IBAction)startSearch:(id)sender {
//    [self performSegueWithIdentifier:@"recipeSearch_segue" sender:self];
}

 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
    {
    if ([[segue identifier] isEqualToString:@"recipeSearch_segue"]) {
        [self.pocketsphinxController stopListening];
        search = [[RecipePuppySearch alloc] initWithIngredients:ingredients];
        RecipesTableViewController *vc = (RecipesTableViewController *)[segue destinationViewController];
        [vc setIngredients:[search getRecipeResults]];
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
    [[[UIAlertView alloc] initWithTitle:@"Start Listing!" message:@""
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

- (void) pocketsphinxDidCompleteCalibration {
	NSLog(@"Pocketsphinx calibration is complete.");
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
                                       message:@"Setting up the continuous recognition loop has failed for some reason, please turn on OpenEarsLogging to learn more."
                                      delegate:self
                             cancelButtonTitle:nil
                             otherButtonTitles:nil] show];
}

- (void) testRecognitionCompleted {
	NSLog(@"A test file that was submitted for recognition is now complete.");
}

#pragma mark - OpenEars Allocations

- (OpenEarsEventsObserver *)openEarsEventsObserver {
	if (openEarsEventsObserver == nil) {
		openEarsEventsObserver = [[OpenEarsEventsObserver alloc] init];
	}
	return openEarsEventsObserver;
}

// Lazily allocated PocketsphinxController.
- (PocketsphinxController *)pocketsphinxController {
	if (pocketsphinxController == nil) {
		pocketsphinxController = [[PocketsphinxController alloc] init];
        pocketsphinxController.verbosePocketSphinx = TRUE; // Uncomment me for verbose debug output
        pocketsphinxController.outputAudio = TRUE;
#ifdef kGetNbest
        pocketsphinxController.returnNbest = TRUE;
        pocketsphinxController.nBestNumber = 5;
#endif
	}
	return pocketsphinxController;
}

// Lazily allocated slt voice.
- (Slt *)slt {
	if (slt == nil) {
		slt = [[Slt alloc] init];
	}
	return slt;
}

// Lazily allocated FliteController.
- (FliteController *)fliteController {
	if (fliteController == nil) {
		fliteController = [[FliteController alloc] init];

	}
	return fliteController;
}

@end
