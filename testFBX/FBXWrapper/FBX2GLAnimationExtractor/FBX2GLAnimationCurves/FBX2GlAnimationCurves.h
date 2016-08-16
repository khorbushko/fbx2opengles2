//
//  FBX2GlAnimationCurves.h
//  testFBX
//
//  Created by Kirill Gorbushko on 12.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

@class FBX2GLAnimationCurveItem;

#import <Foundation/Foundation.h>
#import "fbxsdk.h"
#import <GLKit/GLKit.h>

@interface FBX2GlAnimationCurves : NSObject

@property (strong, nonatomic) NSMutableArray <FBX2GLAnimationCurveItem *>* curvesItems;
@property (assign, nonatomic) NSInteger transformsCount;
@property (assign, nonatomic) NSInteger curveIndex;

- (instancetype)initFromNode:(FbxNode *)pNode onLayer:(FbxAnimLayer *)pAnimLayer;

- (GLKMatrix4)curveTransformForIndex:(NSInteger)transformIndex;

@end
