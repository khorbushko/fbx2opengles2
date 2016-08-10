//
//  FBX2GLModel.h
//  testFBX
//
//  Created by Kirill Gorbushko on 10.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

#include "fbxsdk.h"

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "ObjectStucture.h"

@interface FBX2GLModel : NSObject

@property (assign, nonatomic, readonly) FBXModel displayModel;
@property (assign, nonatomic) GLuint glIndex;
@property (copy, nonatomic, readonly) NSString *textureFileName;

- (instancetype)initWithMesh:(FbxMesh *)pMesh;

- (void)printObjectWithDetails:(BOOL)details;
- (void)destroyModel;

@end
