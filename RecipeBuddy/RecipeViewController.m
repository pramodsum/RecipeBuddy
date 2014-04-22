//
//  RecipeViewController.m
//  RecipeBuddy
//
//  Created by Sumedha Pramod on 4/21/14.
//  Copyright (c) 2014 Sumedha Pramod. All rights reserved.
//

#import "RecipeViewController.h"
#import "AppDelegate.h"

@interface RecipeViewController ()

@end

@implementation RecipeViewController {
    NSString *lmPath;
    NSString *dicPath;
    AppDelegate *appDelegate;
}

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
    [self createLanguageModel];
    appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
    [appDelegate.openEarsEventsObserver setDelegate:self];

//    if(![appDelegate.pocketsphinxController isSuspended]) {
    [appDelegate.pocketsphinxController stopListening];
    [appDelegate.pocketsphinxController startListeningWithLanguageModelAtPath:lmPath dictionaryAtPath:dicPath acousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO];
//    } else {
//        [appDelegate.pocketsphinxController resumeRecognition];
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    _name.text = _recipe.name;
    _recipe_image = _recipe.food_image;
    _recipe_text.text = _recipe.ingredient_list;
    _yields.text = _recipe.yields;
    _time.text = _recipe.time;
}

#pragma mark Actions

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {

    NSMutableArray * words = [[NSMutableArray alloc] initWithArray:[hypothesis componentsSeparatedByString:@" "]];

    NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
//    NSLog(@"Words: %@", words);

    if([words[0] isEqual:@"OPEN"] || [words[0] isEqualToString:@"NEXT"]) {
        [self openRecipeInWeb];
    } else if([words[0] isEqualToString:@"HELP"]) {
        [self help:self];
    } else if([words[0] isEqualToString:@"BACK"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) openRecipeInWeb {
    [appDelegate.pocketsphinxController suspendRecognition];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.recipe.recipe_link]];
}

- (void) readIngredients {
    NSLog(@"Reading ingredients");
//    [appDelegate.pocketsphinxController suspendRecognition];
    [appDelegate.fliteController say:self.recipe.ingredient_list withVoice:appDelegate.slt];
//    [_synthesizer speakUtterance:utterance];
}

//- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance {
//    NSLog(@"Starting");
//}
//
//- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance {
//    NSLog(@"WILL SPEAK: %@", utterance.speechString);
//}
//
//- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
//    NSLog(@"Finishing");
//    [appDelegate.pocketsphinxController resumeRecognition];
//}

#pragma mark OpenEars Delegate Functions

- (void) createLanguageModel {
    LanguageModelGenerator *languageModelGenerator = [[LanguageModelGenerator alloc] init];
    NSString *urlString = [[NSBundle mainBundle] pathForResource:@"commands" ofType:@"txt"];
    NSString *rawText = [NSString stringWithContentsOfFile:urlString encoding:NSUTF8StringEncoding error:nil];
    NSArray *commands = [rawText componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSString *name = @"recipe";
    NSError *err = [languageModelGenerator generateLanguageModelFromArray:commands withFilesNamed:name forAcousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"]];

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)help:(id)sender {
    [appDelegate.pocketsphinxController suspendRecognition];
    NSString *message = @"Commands:\nOKAY: Wakes up Sous Chef\nCLEAR: Clears all ingredients\nHELP: Brings up help menu\nNEXT/FINISHED/DONE: Searches for recipes with your specified ingredients\nAnything else recognized will be added as ingredients!";
    [[[UIAlertView alloc] initWithTitle:@"Need Some Help?"
                                message:message
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([[alertView title] isEqualToString:@"Need Some Help?"]) {
        [appDelegate.pocketsphinxController resumeRecognition];
    }
}

@end
