//
//  AppDelegate.h
//  RecipeBuddy
//
//  Created by Sumedha Pramod on 4/17/14.
//  Copyright (c) 2014 Sumedha Pramod. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenEars/OpenEarsEventsObserver.h>
#import <OpenEars/LanguageModelGenerator.h>
#import <OpenEars/PocketsphinxController.h>
#import <OpenEars/AcousticModel.h>
#import <Slt/Slt.h>
#import <OpenEars/FliteController.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    OpenEarsEventsObserver *openEarsEventsObserver;
	Slt *slt;
    FliteController *fliteController;

	PocketsphinxController *pocketsphinxController; // The controller for Pocketsphinx (voice recognition).
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITableViewController *recipeView;
@property (strong, nonatomic) NSString *searchCompleted;

// These three are the important OpenEars objects that this class demonstrates the use of.
@property (nonatomic, strong) Slt *slt;
@property (strong, nonatomic) FliteController *fliteController;

@property (nonatomic, strong) OpenEarsEventsObserver *openEarsEventsObserver;
@property (nonatomic, strong) PocketsphinxController *pocketsphinxController;

@end
