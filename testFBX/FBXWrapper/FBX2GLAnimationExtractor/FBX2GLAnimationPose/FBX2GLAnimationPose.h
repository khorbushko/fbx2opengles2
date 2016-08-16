//
//  FBX2GLAnimationPose.h
//  testFBX
//
//  Created by Kirill Gorbushko on 12.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

@class FBX2GLAnimationPoseMatrix;

#import <Foundation/Foundation.h>
#import "fbxsdk.h"

typedef NS_ENUM(NSUInteger, PoseType) {
    PoseTypeItem,
    PoseTypeCharacter
};

@interface FBX2GLAnimationPose : NSObject

@property (strong, nonatomic) NSString *poseName;
@property (assign, nonatomic) BOOL isBinded;
@property (assign, nonatomic) NSInteger itemsCount;
@property (assign, nonatomic) PoseType type;

@property (strong, nonatomic) NSArray <FBX2GLAnimationPoseMatrix *> *transfroms;
@property (strong, nonatomic) NSMutableArray *acceptedTransformList;

- (instancetype)initItemPoseWithFbxPose:(FbxPose *)pose;
- (instancetype)initCharacterPoseWithFbxPose:(FbxCharacterPose *)pose;

@end
