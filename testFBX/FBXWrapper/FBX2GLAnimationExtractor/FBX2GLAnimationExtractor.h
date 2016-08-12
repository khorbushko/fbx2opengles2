//
//  FBX2GLAnimationExtractor.h
//  testFBX
//
//  Created by Kirill Gorbushko on 12.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

@class FBX2GLAnimationPose;
@class FBX2GLAnimationStack;

#import <Foundation/Foundation.h>
#import "fbxsdk.h"

@interface FBX2GLAnimationExtractor : NSObject

@property (strong, nonatomic) NSArray <FBX2GLAnimationPose *> *itemsPoses;
@property (strong, nonatomic) NSArray <FBX2GLAnimationPose *> *charactersPoses;

@property (strong, nonatomic) NSArray <FBX2GLAnimationStack *> *animationStacks;

- (instancetype)initWithScene:(FbxScene *)fbxScene;

@end
