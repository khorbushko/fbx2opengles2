//
//  FBX2GLAnimationPoseMatrix.h
//  testFBX
//
//  Created by Kirill Gorbushko on 12.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

@class FBX2GLAnimationPose;

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "fbxsdk.h"

@interface FBX2GLAnimationPoseMatrix : NSObject

@property (strong, nonatomic) NSString *itemName;
@property (assign, nonatomic) BOOL isLocalTransform;

@property (assign, nonatomic) GLuint poseIndex;

@property (assign, nonatomic) GLKMatrix4 poseTransform;

+ (NSArray <FBX2GLAnimationPoseMatrix *> *)extractItemPosesFromFBXPose:(FbxPose *)pose;
+ (NSArray <FBX2GLAnimationPoseMatrix *> *)extractCharactersPosesFromFBXCharacter:(FbxCharacter *)character;

@end
