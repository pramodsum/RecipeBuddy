//
//  RecipePuppySearch.m
//  RecipeBuddy
//
//  Created by Sumedha Pramod on 4/18/14.
//  Copyright (c) 2014 Sumedha Pramod. All rights reserved.
//

#import "RecipePuppySearch.h"
#import "Recipe.h"

@implementation RecipePuppySearch {
    NSMutableArray *recipes;
    NSString *ingredientList;
}

- (RecipePuppySearch *) initWithIngredients:(NSArray *) ingredients {
    ingredientList = [[ingredients componentsJoinedByString:@","] lowercaseString];
    NSLog(@"Ingredients: %@", ingredientList);

    [self searchRecipePuppy];
    return self;
}

- (void) searchRecipePuppy {
    NSString *recipeURL = [NSString stringWithFormat:@"http://www.recipepuppy.com/api/?i=%@&oi=1", ingredientList];

    NSURL *url = [NSURL URLWithString:recipeURL];

    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        recipes = [[NSMutableArray alloc] init];

        if (!error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSArray *results = [json objectForKey:@"results"];

            for (NSDictionary *result in results) {

                Recipe *recipe = [[Recipe alloc] init];
                [recipe setName:result[@"title"]];
                [recipe setRecipe_link:[[result objectForKey:@"href"] stringByReplacingOccurrencesOfString:@"\\" withString:@""]];
                [recipe setImage_link:[[result objectForKey:@"thumbnail"] stringByReplacingOccurrencesOfString:@"\\" withString:@""]];
                [recipes addObject:recipe];
            }
            NSLog(@"%lu recipes found for ingredients", (unsigned long)recipes.count);
            if(recipes.count == 0) {
                _noResults = @"TRUE";
            }

        } else {
            NSLog(@"ERROR: %@", error);
        }
    }];

}

- (NSArray *) getRecipeResults {
    return recipes;
}

- (NSInteger) getRecipeCount {
    return recipes.count;
}

@end
