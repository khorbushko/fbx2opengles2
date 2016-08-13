//
//  FBX2GlAnimationLayer.h
//  testFBX
//
//  Created by Kirill Gorbushko on 12.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

@class FBX2GlAnimationCurves;

#import <Foundation/Foundation.h>
#import "fbxsdk.h"

@interface FBX2GlAnimationLayer : NSObject

@property (strong, nonatomic) NSMutableArray *animationList;
@property (strong, nonatomic) NSMutableArray <FBX2GlAnimationCurves *> *curves;

+ (NSArray <FBX2GlAnimationLayer *> *)parseLayersFromStack:(FbxAnimStack *)pAnimStack rootNode:(FbxNode *)pNode scene:(FbxScene *)pScene;

@end
