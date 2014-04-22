//
//  Recipe.h
//  RecipeBuddy
//
//  Created by Sumedha Pramod on 4/18/14.
//  Copyright (c) 2014 Sumedha Pramod. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Recipe : NSObject

@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *name;

@property (strong, nonatomic) NSString *recipe_link;

@property (strong, nonatomic) NSString *image_link;
@property (strong, nonatomic) IBOutlet UIImageView *food_image;
@property (strong, nonatomic) IBOutlet UIImageView *food_image_large;

@property (strong, nonatomic) NSMutableArray *ingredients;
@property (strong, nonatomic) NSString *ingredient_list;

@property (strong, nonatomic) NSString *yields;
@property (strong, nonatomic) NSString *time;

- (Recipe *) initWithRecipePuppyResult:(NSDictionary *) recipe;
- (Recipe *) initWithYummlyResult:(NSDictionary *) recipe;
- (void) fetchRecipe;

@end
