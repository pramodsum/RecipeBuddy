//
//  AppDelegate.h
//  RecipeBuddy
//
//  Created by Sumedha Pramod on 4/17/14.
//  Copyright (c) 2014 Sumedha Pramod. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITableViewController *recipeView;
@property (strong, nonatomic) NSString *searchCompleted;

@end
