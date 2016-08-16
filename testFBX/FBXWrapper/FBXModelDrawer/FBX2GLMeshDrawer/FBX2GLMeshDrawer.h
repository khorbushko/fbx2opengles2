//
//  FBX2GLMeshDrawer.h
//  testFBX
//
//  Created by Kirill Gorbushko on 10.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

@class FBX2GLModel;

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "ObjectStucture.h"

@interface FBX2GLMeshDrawer : NSObject

@property (assign, nonatomic) GLuint drawElementsMode;
@property (strong, nonatomic) NSString *modelName;

- (instancetype)initWithMeshModel:(FBX2GLModel *)meshModel textureName:(NSString *)textureName;

- (void)pefromMeshDraw;
- (void)performMeshUpdateWithBaseMVPMatrix:(GLKMatrix4)baseMatrix;
- (void)performMeshUpdateWithBaseMVPMatrix:(GLKMatrix4)baseMatrix animMatrix:(GLKMatrix4)animMatrix;

- (void)tearDownGLDrawer;

@end
