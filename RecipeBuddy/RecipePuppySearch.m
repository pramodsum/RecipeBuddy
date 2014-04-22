//
//  RecipePuppySearch.m
//  RecipeBuddy
//
//  Created by Sumedha Pramod on 4/18/14.
//  Copyright (c) 2014 Sumedha Pramod. All rights reserved.
//

#import "RecipePuppySearch.h"
#import "Recipe.h"
#import "AppDelegate.h"
#import "RecipesTableViewController.h"

@implementation RecipePuppySearch {
    NSString *ingredientList;
    AppDelegate *appDelegate;
}

- (RecipePuppySearch *) initWithIngredients:(NSArray *) ingredients {
    ingredientList = [[ingredients componentsJoinedByString:@","] lowercaseString];
    NSLog(@"Ingredients: %@", ingredientList);

    if(_recipes == nil) {
        _recipes = [[NSMutableArray alloc] init];
    }

    [self searchRecipePuppy];
    return self;
}

- (void) searchRecipePuppy {
    for(int i = 1; i < 4; i++) {
        NSString *recipeURL = [NSString stringWithFormat:@"http://www.recipepuppy.com/api/?i=%@&p=%d", ingredientList, i];

        NSURL *url = [NSURL URLWithString:recipeURL];

        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData * data = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:url]
                                              returningResponse:&response
                                                          error:&error];

        if (error == nil) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSArray *results = [json objectForKey:@"results"];

            for (NSDictionary *result in results) {

                Recipe *recipe = [[Recipe alloc] init];
                [recipe setName:[result[@"title"] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
                [recipe setRecipe_link:[[result objectForKey:@"href"] stringByReplacingOccurrencesOfString:@"\\" withString:@""]];
                [recipe setImage_link:[[result objectForKey:@"thumbnail"] stringByReplacingOccurrencesOfString:@"\\" withString:@""]];
                [_recipes addObject:recipe];
            }
            NSLog(@"%lu recipes found for ingredients", (unsigned long)_recipes.count);
            if(_recipes.count == 0) {
                _noResults = @"TRUE";
            }
        } else {
            NSLog(@"ERROR: %@", error);
        }

//        [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//
//            if(_recipes == nil) {
//                _recipes = [[NSMutableArray alloc] init];
//            }
//
//            if (!error) {
//                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
//                NSArray *results = [json objectForKey:@"results"];
//
//                for (NSDictionary *result in results) {
//
//                    Recipe *recipe = [[Recipe alloc] init];
//                    [recipe setName:[result[@"title"] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
//                    [recipe setRecipe_link:[[result objectForKey:@"href"] stringByReplacingOccurrencesOfString:@"\\" withString:@""]];
//                    [recipe setImage_link:[[result objectForKey:@"thumbnail"] stringByReplacingOccurrencesOfString:@"\\" withString:@""]];
//                    [_recipes addObject:recipe];
//                }
//                NSLog(@"%lu recipes found for ingredients", (unsigned long)_recipes.count);
//                if(_recipes.count == 0) {
//                    _noResults = @"TRUE";
//                }
//                
//            } else {
//                NSLog(@"ERROR: %@", error);
//            }
//        }];
    }
}

- (NSArray *) getRecipeResults {
    return _recipes;
}

- (NSInteger) getRecipeCount {
    return _recipes.count;
}

@end
