//
//  FBX2GlAnimationLayer.m
//  testFBX
//
//  Created by Kirill Gorbushko on 12.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

#import "FBX2GlAnimationLayer.h"
#import "FBX2GlAnimationCurves.h"

@implementation FBX2GlAnimationLayer

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        _animationList = [NSMutableArray array];
        _curves = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Private

- (void)fetchAnimationNameFromLayer:(FbxAnimLayer *)lAnimLayer rootNode:(FbxNode *)pNode
{
    NSString *name = [NSString stringWithUTF8String:pNode->GetName()];
    [self.animationList addObject:name];

    FBX2GlAnimationCurves *curve = [[FBX2GlAnimationCurves alloc] initFromNode:pNode onLayer:lAnimLayer];
    curve.curveIndex = self.curves.count;
    [self.curves addObject:curve];
    
    for (int i = 0; i < pNode->GetChildCount(); i++) {
        [self fetchAnimationNameFromLayer:lAnimLayer rootNode:pNode->GetChild(i)];
    }
}

#pragma mark - Public

+ (NSArray <FBX2GlAnimationLayer *> *)parseLayersFromStack:(FbxAnimStack *)pAnimStack rootNode:(FbxNode *)pNode scene:(FbxScene *)pScene
{
    NSMutableArray *layers = [NSMutableArray array];
    
    FbxArray<FbxString*> mAnimStackNameArray;
    pScene->FillAnimStackNameArray(mAnimStackNameArray);
    
    int nbAnimLayers = pAnimStack->GetMemberCount<FbxAnimLayer>();
    for (int l = 0; l < nbAnimLayers; l++) {
        FbxAnimLayer* lAnimLayer = pAnimStack->GetMember<FbxAnimLayer>(l);
        
        FbxTime mStart;
        FbxTime mStop;
        FbxTakeInfo* lCurrentTakeInfo = pScene->GetTakeInfo(*(mAnimStackNameArray[l]));
        if (lCurrentTakeInfo) {
           mStart = lCurrentTakeInfo->mLocalTimeSpan.GetStart();
           mStop = lCurrentTakeInfo->mLocalTimeSpan.GetStop();
        } else {
            FbxTimeSpan lTimeLineTimeSpan;
            pScene->GetGlobalSettings().GetTimelineDefaultTimeSpan(lTimeLineTimeSpan);
            mStart = lTimeLineTimeSpan.GetStart();
            mStop  = lTimeLineTimeSpan.GetStop();
        }
        
        FBX2GlAnimationLayer *layer = [[FBX2GlAnimationLayer alloc] init];
        [layer fetchAnimationNameFromLayer:lAnimLayer rootNode:pNode];
        
        layer.animationStartSeconds = mStart.GetSecondDouble();
        layer.animationEndSeconds = mStop.GetSecondDouble();
        layer.animationDurationSeconds = ABS(layer.animationStartSeconds - layer.animationEndSeconds);
        
        [layers addObject:layer];
    }
    
    return layers;
}

@end
