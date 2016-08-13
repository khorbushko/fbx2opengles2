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

@property (assign, nonatomic) GLfloat startTime;
@property (assign, nonatomic) GLfloat endTime;
@property (assign, nonatomic) GLfloat duration;
@property (assign, nonatomic) GLfloat timeModeFPS;

@property (strong, nonatomic) NSArray <FBX2GLAnimationPose *> *itemsPoses;
@property (strong, nonatomic) NSArray <FBX2GLAnimationPose *> *charactersPoses;

@property (strong, nonatomic) NSArray <FBX2GLAnimationStack *> *animationStacks;

- (instancetype)initWithScene:(FbxScene *)fbxScene;

@end
