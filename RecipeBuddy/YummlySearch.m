//
//  YummlySearch.m
//  RecipeBuddy
//
//  Created by Sumedha Pramod on 4/21/14.
//  Copyright (c) 2014 Sumedha Pramod. All rights reserved.
//

#import "YummlySearch.h"
#import "Recipe.h"

@implementation YummlySearch {
    NSString *ingredientList;
}

- (YummlySearch *) initWithIngredients:(NSArray *) ingredients {
    ingredientList = [NSString stringWithFormat:@"allowedIngredient[]=%@", [[ingredients componentsJoinedByString:@"&allowedIngredient[]="] lowercaseString]];
    NSLog(@"Ingredients: %@", ingredientList);

    if(_recipes == nil) {
        _recipes = [[NSMutableArray alloc] init];
    }

    [self searchRecipePuppy];
    return self;
}

//http://api.yummly.com/v1/api/recipes?_app_id=app-id&_app_key=app-key&your _search_parameters

- (void) searchRecipePuppy {
    for(int i = 1; i < 4; i++) {
        NSString *app_id = @"760ddeb5";
        NSString *app_key = @"e7140a04138a2d246e07710ee0d566b9";
        NSString *recipeURL = [NSString stringWithFormat:@"http://api.yummly.com/v1/api/recipes?_app_id=%@&_app_key=%@&%@", app_id, app_key, ingredientList];

        NSURL *url = [NSURL URLWithString:recipeURL];

        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData * data = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:url]
                                              returningResponse:&response
                                                          error:&error];

        if (error == nil) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSArray *results = [json objectForKey:@"matches"];

            for (NSDictionary *result in results) {

                Recipe *recipe = [[Recipe alloc] initWithYummlyResult:result];
                [_recipes addObject:recipe];
            }
            NSLog(@"%lu recipes found for ingredients", (unsigned long)_recipes.count);
            if(_recipes.count == 0) {
                _noResults = @"TRUE";
            }
        } else {
            NSLog(@"ERROR: %@", error);
        }
    }
}

- (NSArray *) getRecipeResults {
    return _recipes;
}

- (NSInteger) getRecipeCount {
    return _recipes.count;
}

@end
