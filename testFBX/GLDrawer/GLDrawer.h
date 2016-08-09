//
//  GLDrawer.h
//  testFBX
//
//  Created by Kirill Gorbushko on 07.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "ObjectStucture.h"

@interface GLDrawer : NSObject

- (instancetype)initWithContext:(EAGLContext *)context withinView:(GLKView *)glView model:(FBXModel)model;
- (void)draw;
- (void)updateGLView;
- (void)tearDown;

@end
