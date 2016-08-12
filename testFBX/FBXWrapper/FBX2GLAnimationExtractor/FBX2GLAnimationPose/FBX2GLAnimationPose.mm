//
//  FBX2GLAnimationPose.m
//  testFBX
//
//  Created by Kirill Gorbushko on 12.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

#import "FBX2GLAnimationPose.h"
#import "FBX2GLAnimationPoseMatrix.h"

@implementation FBX2GLAnimationPose

#pragma mark - Lifecycle

- (instancetype)initItemPoseWithFbxPose:(FbxPose *)pose
{
    self = [super init];
    if (self) {
        [self parseItemsSourcePose:pose];
    }
    return self;
}

- (instancetype)initCharacterPoseWithFbxPose:(FbxCharacterPose *)pose
{
    self = [super init];
    if (self) {
        [self parseCharacterSourcePose:pose];
    }
    return self;
}

#pragma mark - Private

- (void)parseItemsSourcePose:(FbxPose *)lPose
{
    self.poseName = [NSString stringWithUTF8String:lPose->GetName()];
    self.isBinded = lPose->IsBindPose();

    self.itemsCount = lPose->GetCount();
    self.transfroms = [FBX2GLAnimationPoseMatrix extractItemPosesFromFBXPose:lPose];
}

- (void)parseCharacterSourcePose:(FbxCharacterPose *)lPose
{
    FbxCharacter* lCharacter = lPose->GetCharacter();
    if (!lCharacter) return;
    
    self.transfroms = [FBX2GLAnimationPoseMatrix extractCharactersPosesFromFBXCharacter:lCharacter];
    NSString *characterName = [NSString stringWithUTF8String:lCharacter->GetName()];
    self.poseName = characterName;
}

@end
