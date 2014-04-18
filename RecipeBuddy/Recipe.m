//
//  Recipe.m
//  RecipeBuddy
//
//  Created by Sumedha Pramod on 4/18/14.
//  Copyright (c) 2014 Sumedha Pramod. All rights reserved.
//

#import "Recipe.h"
#import "UIImageView+WebCache.h"

@implementation Recipe

@synthesize name = _name;
@synthesize recipe_link = _recipe_link;
@synthesize image_link = _image_link;
@synthesize food_image = _food_image;
@synthesize ingredients = _ingredients;

- (Recipe *) initWithResult:(NSDictionary *) recipe {
    _name = [recipe objectForKey:@"title"];
    _recipe_link = [[recipe objectForKey:@"href"] stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    NSLog(@"LINK: %@", _recipe_link);
    _image_link = [[recipe objectForKey:@"thumbnail"] stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    [_food_image setImageWithURL:[NSURL URLWithString:_image_link] placeholderImage:[UIImage imageNamed:@"placeholder"]];

    return self;
}

@end
