//
//  FBX2GLAnimationStack.h
//  testFBX
//
//  Created by Kirill Gorbushko on 12.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

@class FBX2GlAnimationLayer;

#import <Foundation/Foundation.h>
#import "fbxsdk.h"

@interface FBX2GLAnimationStack : NSObject

@property (assign, nonatomic) NSInteger index;
@property (assign, nonatomic) NSInteger layersCount;
@property (strong, nonatomic) NSString *name;

@property (strong, nonatomic) NSArray <FBX2GlAnimationLayer *> *layers;

+ (NSArray <FBX2GLAnimationStack *> *)animationStacksFromScene:(FbxScene *)scene;

@end
