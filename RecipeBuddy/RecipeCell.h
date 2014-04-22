//
//  RecipeCell.h
//  RecipeBuddy
//
//  Created by Sumedha Pramod on 4/18/14.
//  Copyright (c) 2014 Sumedha Pramod. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Recipe.h"

@interface RecipeCell : UITableViewCell

- (void) configureCell: (Recipe *) recipe :(NSInteger) num;
- (Recipe *) getRecipe;
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *recipe_num;
@property (strong, nonatomic) IBOutlet UIImageView *food_image;

@end
