//
//  YummlySearch.h
//  RecipeBuddy
//
//  Created by Sumedha Pramod on 4/21/14.
//  Copyright (c) 2014 Sumedha Pramod. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YummlySearch : NSObject

- (YummlySearch *) initWithIngredients:(NSArray *) ingredients;
- (NSArray *) getRecipeResults;
- (NSInteger) getRecipeCount;

@property (strong, nonatomic) NSString *noResults;
@property (strong, nonatomic) NSMutableArray *recipes;

@end
