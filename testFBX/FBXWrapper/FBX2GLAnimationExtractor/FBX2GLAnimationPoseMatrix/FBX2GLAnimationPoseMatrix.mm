//
//  FBX2GLAnimationPoseMatrix.m
//  testFBX
//
//  Created by Kirill Gorbushko on 12.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

#import "FBX2GLAnimationPoseMatrix.h"
#import "FBX2GLAnimationPose.h"

@implementation FBX2GLAnimationPoseMatrix

#pragma mark - LifeCycle

- (instancetype)initWithFbxMatrix:(FbxMatrix)source
{
    self = [super init];
    if (self) {
        CGFloat *srcPointer = (CGFloat *)&source;
        GLfloat *destPointer = _poseTransform.m;
        for (int i = 0; i < 16; i++) {
            destPointer[i] = srcPointer[i];
        }
    }
    return self;
}

#pragma mark - Public

+ (NSArray <FBX2GLAnimationPoseMatrix *> *)extractItemPosesFromFBXPose:(FbxPose *)lPose
{
    NSMutableArray *poses = [NSMutableArray array];

    for (int j = 0; j < lPose->GetCount(); j++) {
        FbxString lName = lPose->GetNodeName(j).GetCurrentName();
        bool isLocal = false;
        if (!lPose->IsBindPose()) {
            isLocal = lPose->IsLocalMatrix(j);
        }
        
        FbxMatrix  lMatrix = lPose->GetMatrix(j);
        FBX2GLAnimationPoseMatrix *matrix = [[FBX2GLAnimationPoseMatrix alloc] initWithFbxMatrix:lMatrix];
        matrix.isLocalTransform = isLocal;
        matrix.itemName = [NSString stringWithUTF8String:lName.Buffer()];
        matrix.poseIndex = j;
        
        [poses addObject:matrix];
    }
    
    return poses;
}

+ (NSArray <FBX2GLAnimationPoseMatrix *> *)extractCharactersPosesFromFBXCharacter:(FbxCharacter *)lCharacter
{
    FbxCharacterLink lCharacterLink;
    FbxCharacter::ENodeId  lNodeId = FbxCharacter::eHips;
    
    NSMutableArray *poses = [NSMutableArray array];
    while (lCharacter->GetCharacterLink(lNodeId, &lCharacterLink)) {
        FbxAMatrix& lGlobalPosition = lCharacterLink.mNode->EvaluateGlobalTransform(FBXSDK_TIME_ZERO);
        FBX2GLAnimationPoseMatrix *matrix = [[FBX2GLAnimationPoseMatrix alloc] initWithFbxMatrix:lGlobalPosition];
        [poses addObject:matrix];
        lNodeId = FbxCharacter::ENodeId(int(lNodeId) + 1);
    }

    return poses;
}

@end
