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

- (Recipe *) initWithRecipePuppyResult:(NSDictionary *) recipe {
    _name = [recipe objectForKey:@"title"];
    _recipe_link = [[recipe objectForKey:@"href"] stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    NSLog(@"LINK: %@", _recipe_link);
    _image_link = [[recipe objectForKey:@"thumbnail"] stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    [_food_image setImageWithURL:[NSURL URLWithString:_image_link] placeholderImage:[UIImage imageNamed:@"placeholder"]];

    return self;
}

- (Recipe *) initWithYummlyResult:(NSDictionary *) recipe {
    _id = [recipe objectForKey:@"id"];
    _name = [recipe objectForKey:@"recipeName"];
    _image_link = [[[recipe objectForKey:@"smallImageUrls"] firstObject] stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    [_food_image setImageWithURL:[NSURL URLWithString:_image_link] placeholderImage:[UIImage imageNamed:@"placeholder"]];

    return self;
}

- (void) fetchRecipe {
    NSString *app_id = @"760ddeb5";
    NSString *app_key = @"e7140a04138a2d246e07710ee0d566b9";
    NSString *recipeURL = [NSString stringWithFormat:@"http://api.yummly.com/v1/api/recipe/%@?_app_id=%@&_app_key=%@", _id, app_id, app_key];

    NSURL *url = [NSURL URLWithString:recipeURL];

    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:url]
                                          returningResponse:&response
                                                      error:&error];

    if (error == nil) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        _ingredient_list = [NSString stringWithFormat:@"Ingredients:\n%@", [self formatIngredients:json[@"ingredientLines"]]];
        [_food_image_large setImageWithURL:[NSURL URLWithString:[json[@"images"] objectForKey:@"hostedLargeUrl"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        _recipe_link = [json[@"source"] objectForKey:@"sourceRecipeUrl"];
        _yields = json[@"yield"];
        _time = json[@"totalTime"];
    } else {
        NSLog(@"ERROR: %@", error);
    }

}

- (NSString *) formatIngredients: (NSDictionary *) result {
    NSString *formatted_text;
    for(NSString *ingredient in result) {
        [formatted_text stringByAppendingFormat:@"%@\n", ingredient];
    }
    return formatted_text;
}

@end
