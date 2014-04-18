//
//  Recipe.h
//  RecipeBuddy
//
//  Created by Sumedha Pramod on 4/18/14.
//  Copyright (c) 2014 Sumedha Pramod. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Recipe : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *recipe_link;
@property (strong, nonatomic) NSString *image_link;
@property (strong, nonatomic) NSMutableArray *ingredients;

- (Recipe *) initWithResult:(NSDictionary *) recipe;

@end
