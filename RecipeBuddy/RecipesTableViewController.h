//
//  RecipesTableViewController.h
//  RecipeBuddy
//
//  Created by Sumedha Pramod on 4/18/14.
//  Copyright (c) 2014 Sumedha Pramod. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YummlySearch.h"

@interface RecipesTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *recipes;
@property (strong, nonatomic) YummlySearch *search;

@end
