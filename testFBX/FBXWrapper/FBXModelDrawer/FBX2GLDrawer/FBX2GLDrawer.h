//
//  GLDrawer.h
//  testFBX
//
//  Created by Kirill Gorbushko on 07.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "FBX2GLModel.h"

@interface FBX2GLDrawer : NSObject

- (instancetype)initWithContext:(EAGLContext *)context withinView:(GLKView *)glView models:(NSArray <FBX2GLModel *> *)models;

- (void)draw;
- (void)updateGLView;
- (void)tearDown;

@end
