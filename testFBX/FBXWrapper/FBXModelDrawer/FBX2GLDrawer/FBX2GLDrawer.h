//
//  GLDrawer.h
//  testFBX
//
//  Created by Kirill Gorbushko on 07.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

@class FBX2GLAnimationExtractor;

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "FBX2GLModel.h"

@interface FBX2GLDrawer : NSObject

@property (assign, nonatomic) GLfloat expectedFramerate;
@property (assign, nonatomic) GLuint drawMode;
@property (assign, nonatomic) GLboolean animate;

- (instancetype)initWithContext:(EAGLContext *)context withinView:(GLKView *)glView models:(NSArray <FBX2GLModel *> *)models;
- (instancetype)initWithContext:(EAGLContext *)context withinView:(GLKView *)glView models:(NSArray <FBX2GLModel *> *)models textureNamed:(NSString *)textureNamed;

- (void)attachAnimatorObject:(FBX2GLAnimationExtractor *)animator;

- (void)draw;
- (void)updateGLView;
- (void)tearDown;


@end
