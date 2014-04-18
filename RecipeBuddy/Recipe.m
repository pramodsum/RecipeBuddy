//
//  Recipe.m
//  RecipeBuddy
//
//  Created by Sumedha Pramod on 4/18/14.
//  Copyright (c) 2014 Sumedha Pramod. All rights reserved.
//

#import "Recipe.h"

@implementation Recipe

@synthesize name = _name;
@synthesize recipe_link = _recipe_link;
@synthesize image_link = _image_link;
@synthesize ingredients = _ingredients;

- (Recipe *) initWithResult:(NSDictionary *) recipe {
    _name = recipe[@"name"];
    _recipe_link = recipe[@"href"];
    _image_link = recipe[@"thumbnail"];

    _ingredients = [[NSMutableArray alloc] init];
    for(NSString *ingredient in recipe[@"ingredients"]) {
        [_ingredients addObject:ingredient];
    }

    return self;
}

@end
