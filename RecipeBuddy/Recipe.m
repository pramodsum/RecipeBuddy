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

- (Recipe *) fetchRecipe:(Recipe *)prev {
    NSLog(@"FETCHING RECIPE!");
    _name = prev.name;
    _id = prev.id;
    _image_link = prev.image_link;
    _food_image = prev.food_image;

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
        //        NSLog(@"RECIPE: %@", json);
        _name = json[@"name"];
        NSLog(@"%@", _name);
        _ingredient_list = [NSString stringWithFormat:@"Ingredients:\n%@", [self formatIngredients:json[@"ingredientLines"]]];
//        NSLog(@"%@", _ingredient_list);
//        NSString *url = [[json[@"images"] firstObject] objectForKey:@"hostedLargeUrl"];
//        [_food_image_large setImageWithURL:[NSURL URLWithString:url] placeholderImage:_food_image.image];
//        NSLog(@"link: %@", [NSURL URLWithString:[json[@"images"] objectForKey:@"hostedLargeUrl"]]);
        _recipe_link = [json[@"source"] objectForKey:@"sourceRecipeUrl"];
        NSLog(@"%@", _recipe_link);
        _yields = json[@"yield"];
//        NSLog(@"%@", _yields);
        _time = json[@"totalTime"];
//        NSLog(@"%@", _time);
    } else {
        NSLog(@"ERROR: %@", error);
    }
    return self;
}

- (Recipe *) fetchRecipe {
    NSLog(@"FETCHING RECIPE!");

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
        //        NSLog(@"RECIPE: %@", json);
        _name = json[@"name"];
        NSLog(@"%@", _name);
        _ingredient_list = [self formatIngredients:json[@"ingredientLines"]];

        NSDictionary *image = [json[@"images"] firstObject];
        NSLog(@"image: %@", image);
        [_food_image setImageWithURL:[NSURL URLWithString:image[@"hostedSmallUrl"]] placeholderImage:_food_image.image];
        [_food_image_large setImageWithURL:[NSURL URLWithString:image[@"hostedLargeUrl"]] placeholderImage:_food_image.image];
        //        NSLog(@"link: %@", [NSURL URLWithString:[json[@"images"] objectForKey:@"hostedLargeUrl"]]);
        _recipe_link = [json[@"source"] objectForKey:@"sourceRecipeUrl"];
        NSLog(@"%@", _recipe_link);

        if(json[@"yield"]) {
            _yields = json[@"yield"];
        } else {
            _yields = @"";
        }

        if(json[@"totalTime"]) {
            _time = json[@"totalTime"];
        } else {
            _time = @"";
        }
    } else {
        NSLog(@"ERROR: %@", error);
    }
    return self;
}

- (NSString *) formatIngredients: (NSDictionary *) result {
    NSString *formatted_text = @"";
    for(NSString *ingredient in result) {
        formatted_text = [formatted_text stringByAppendingFormat:@"%@\n", ingredient];
//        NSLog(@"%@ | %@", ingredient, formatted_text);
    }
    return formatted_text;
}

@end
