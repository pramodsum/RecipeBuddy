//
//  RecipePuppySearch.h
//  RecipeBuddy
//
//  Created by Sumedha Pramod on 4/18/14.
//  Copyright (c) 2014 Sumedha Pramod. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecipePuppySearch : NSObject

- (RecipePuppySearch *) initWithIngredients:(NSArray *) ingredients;
- (NSArray *) getRecipeResults;

@end
