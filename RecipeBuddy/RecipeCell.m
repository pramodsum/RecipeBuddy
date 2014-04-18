//
//  RecipeCell.m
//  RecipeBuddy
//
//  Created by Sumedha Pramod on 4/18/14.
//  Copyright (c) 2014 Sumedha Pramod. All rights reserved.
//

#import "RecipeCell.h"
#import "UIImageView+WebCache.h"

@implementation RecipeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) configureCell: (Recipe *) recipe {
    _name.text = recipe.name;
    _ingredients.text = recipe.recipe_link;
    [_food_image setImageWithURL:[NSURL URLWithString:recipe.image_link] placeholderImage:[UIImage imageNamed:@"placeholder"]];
}

@end
