//
//  FBX2GLAnimationExtractor.m
//  testFBX
//
//  Created by Kirill Gorbushko on 12.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

#import "FBX2GLAnimationExtractor.h"
#import "FBX2GLAnimationPose.h"
#import "FBX2GLAnimationStack.h"

@implementation FBX2GLAnimationExtractor

#pragma mark - LifeCycle

- (instancetype)initWithScene:(FbxScene *)fbxScene
{
    self = [super init];
    if (self) {
        [self extractPosesFromScene:fbxScene];
        [self extractAnimationStackFromScene:fbxScene];
        [self extractGlobalTimeSettingFromScene:fbxScene];
        [self calculateExpectedTimingsForFrame];
    }
    return self;
}

#pragma mark - Private

- (void)extractPosesFromScene:(FbxScene *)fbxScene
{
    int lPoseCount = fbxScene->GetPoseCount();
    NSMutableArray *itemsPoses = [NSMutableArray array];
    for (int i = 0; i < lPoseCount; i++) {
        FbxPose* lPose = fbxScene->GetPose(i);
        FBX2GLAnimationPose *pose = [[FBX2GLAnimationPose alloc] initItemPoseWithFbxPose:lPose];
        [itemsPoses addObject:pose];
    }
    self.itemsPoses = itemsPoses;
    
    NSMutableArray *characterPoses = [NSMutableArray array];
    lPoseCount = fbxScene->GetCharacterPoseCount();
    for (int i = 0; i < lPoseCount; i++) {
        FbxCharacterPose* lPose = fbxScene->GetCharacterPose(i);
        
        FBX2GLAnimationPose *pose = [[FBX2GLAnimationPose alloc] initCharacterPoseWithFbxPose:lPose];
        [characterPoses addObject:pose];
    }
    self.charactersPoses = characterPoses;
}

- (void)extractAnimationStackFromScene:(FbxScene *)fbxScene
{
    self.animationStacks = [FBX2GLAnimationStack animationStacksFromScene:fbxScene];
}

- (void)extractGlobalTimeSettingFromScene:(FbxScene *)fbxScene
{
    FbxGlobalSettings &pGlobalSettings = fbxScene->GetGlobalSettings();
    
    FbxTimeSpan lTs;
    FbxTime lStart, lEnd;
    pGlobalSettings.GetTimelineDefaultTimeSpan(lTs);
    lStart = lTs.GetStart();
    lEnd = lTs.GetStop();
    char lTimeString[256];

    _startTime = [[NSString stringWithUTF8String:lStart.GetTimeString(lTimeString, FbxUShort(256))] floatValue];
    _endTime = [[NSString stringWithUTF8String:lEnd.GetTimeString(lTimeString, FbxUShort(256))] floatValue];
    _duration = ABS(_startTime - _endTime);
    
    _timeModeFPS = [[NSString stringWithUTF8String:FbxGetTimeModeName(pGlobalSettings.GetTimeMode())] floatValue];
}

- (void)calculateExpectedTimingsForFrame
{
    NSInteger countOfLayers = [_animationStacks firstObject].layersCount;
    
}

@end
