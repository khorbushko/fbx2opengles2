//
//  FBX2GLModel.h
//  testFBX
//
//  Created by Kirill Gorbushko on 10.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

@class FBX2GLBoneModel;

#include "fbxsdk.h"

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "ObjectStucture.h"

@interface FBX2GLModel : NSObject

@property (assign, nonatomic, readonly) FBXModel displayModel;
@property (assign, nonatomic) GLuint glIndex;
@property (copy, nonatomic, readonly) NSString *textureFileName;

@property (assign, nonatomic) GLKMatrix4 globalTransfrorm;
@property (assign, nonatomic) GLKMatrix4 localTransfrorm;

@property (copy, nonatomic) NSString *nodeName;

@property (assign, nonatomic) float *animationTransforms;
@property (assign, nonatomic) GLuint animationTransformsCount;

@property (strong, nonatomic) NSMutableArray <FBX2GLBoneModel *> *bones;

- (instancetype)initWithMesh:(FbxMesh *)pMesh;

- (void)printObjectWithDetails:(BOOL)details;
- (void)destroyModel;

@end
