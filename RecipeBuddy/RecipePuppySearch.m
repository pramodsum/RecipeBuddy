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
    NSLog(@"Ingredients: %@", ingredients);
    ingredientList = [[ingredients componentsJoinedByString:@","] lowercaseString];

    [self searchRecipePuppy];
    return self;
}

- (void) searchRecipePuppy {
    NSString *recipeURL = [NSString stringWithFormat:@"http://www.recipepuppy.com/api/?i=%@&oi=1", ingredientList];

    NSURL *url = [NSURL URLWithString:recipeURL];

    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        recipes = [[NSMutableArray alloc] init];

        NSLog(@"DATA: %@", data);

        if (!error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSLog(@"JSON: %@", json);
            NSArray *results = [json objectForKey:@"results"];

            NSLog(@"Results: %@", results);

            for (NSDictionary *result in results) {
                [recipes addObject:[[Recipe alloc] initWithResult:result]];

            }
            NSLog(@"%lu recipes found for ingredients", (unsigned long)results.count);

        } else {
            NSLog(@"ERROR: %@", error);
        }
    }];

}

- (NSArray *) getRecipeResults {
    return recipes;
}

@end
