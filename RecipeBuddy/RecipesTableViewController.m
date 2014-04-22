//
//  RecipesTableViewController.m
//  RecipeBuddy
//
//  Created by Sumedha Pramod on 4/18/14.
//  Copyright (c) 2014 Sumedha Pramod. All rights reserved.
//

#import "RecipesTableViewController.h"
#import "RecipeViewController.h"
#import "RecipeCell.h"
#import "AppDelegate.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface RecipesTableViewController ()

@end

@implementation RecipesTableViewController {
    NSString *lmPath;
    NSString *dicPath;
    AppDelegate *appDelegate;
    NSInteger selectedIndex;
    NSInteger page;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh setTintColor:UIColorFromRGB(0x60DFE5)];
    [refresh addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;

    [self createLanguageModel];
    appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
    [appDelegate.openEarsEventsObserver setDelegate:self];

    if(![appDelegate.pocketsphinxController isSuspended]) {
        [appDelegate.pocketsphinxController startListeningWithLanguageModelAtPath:lmPath dictionaryAtPath:dicPath acousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO];
    } else {
        [appDelegate.pocketsphinxController resumeRecognition];
    }
}

- (void)refreshData
{
    [self.tableView reloadData];
    [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:0.5];
}


- (void)stopRefresh
{
    [self.refreshControl endRefreshing];
}

- (void) viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
    page = 0;
//    NSLog(@"Recipes loaded from search: %lu", _recipes.count);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if((page*7) > [_recipes count] || ((page + 1)*7 - 1) > [_recipes count]) {
        return [_recipes count] % 7;
    }
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RecipeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recipe_cell"];
    if (cell == nil) {
        cell = [[RecipeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"recipe_cell"];
    }

    [cell configureCell:[_recipes objectAtIndex:(page*7 + indexPath.row)]:(indexPath.row + 1)];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedIndex = (page*7 + indexPath.row);
    [appDelegate.pocketsphinxController suspendRecognition];
}

#pragma mark Actions

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {

    NSMutableArray * words = [[NSMutableArray alloc] initWithArray:[hypothesis componentsSeparatedByString:@" "]];

    NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
    //    NSLog(@"Words: %@", words);

    if([words[0] isEqual:@"NEXT"]) {
        [self loadNextPage];
    } else if([words[0] isEqualToString:@"HELP"]) {
        [self help:self];
    } else if([words[0] isEqualToString:@"PREVIOUS"] || [words[0] isEqualToString:@"BACK"]) {
        [self loadPrevPage];
    } else if([words[0] isEqualToString:@"CHOOSE"] || [words[0] isEqualToString:@"SELECT"]) {
        if([words[1] isEqualToString:@"RECIPE"]) {
            [words removeObjectAtIndex:1];
        }

        NSLog(@"SELECTED INDEX: %@", words[1]);

        if([words[1] integerValue] > 0 && [words[1] integerValue] < 11) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:([words[1] integerValue] - 1)inSection:1];
            [self.tableView selectRowAtIndexPath:indexPath
                                        animated:YES
                                  scrollPosition:UITableViewScrollPositionNone];
            [appDelegate.pocketsphinxController stopListening];
            [self performSegueWithIdentifier:@"recipeSelected_segue" sender:self];
        }
    } else if([words[0] integerValue] > 0 && [words[0] integerValue] < 11) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:([words[0] integerValue] - 1) inSection:1];
        [self.tableView selectRowAtIndexPath:indexPath
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionNone];
        [appDelegate.pocketsphinxController stopListening];
        [self performSegueWithIdentifier:@"recipeSelected_segue" sender:self];
    }
}

- (void) loadNextPage {
    page++;
    [self.tableView reloadData];
}

- (void) loadPrevPage {
    page--;
    [self.tableView reloadData];
}

#pragma mark OpenEars Delegate Functions

- (void) createLanguageModel {
    LanguageModelGenerator *languageModelGenerator = [[LanguageModelGenerator alloc] init];
    NSString *urlString = [[NSBundle mainBundle] pathForResource:@"select_recipes" ofType:@"txt"];
    NSString *rawText = [NSString stringWithContentsOfFile:urlString encoding:NSUTF8StringEncoding error:nil];
    NSArray *select_recipes = [rawText componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSString *name = @"select_recipes";
    NSError *err = [languageModelGenerator generateLanguageModelFromArray:select_recipes withFilesNamed:name forAcousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"]];

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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"recipeSelected_segue"]) {
        RecipeViewController *vc = (RecipeViewController *)[segue destinationViewController];
        NSInteger index = (page * 7) + [self.tableView indexPathForSelectedRow].row;
        vc.recipe = [[Recipe alloc] init];
        vc.recipe = [[_recipes objectAtIndex:index] fetchRecipe];
        vc.recipe_image = vc.recipe.food_image_large;
    }
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

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([[alertView title] isEqualToString:@"Need Some Help?"]) {
        [appDelegate.pocketsphinxController resumeRecognition];
    }
}

@end
