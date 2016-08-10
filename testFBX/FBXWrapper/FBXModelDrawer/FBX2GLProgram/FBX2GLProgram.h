//
//  FBX2GLProgram.h
//  testFBX
//
//  Created by Kirill Gorbushko on 10.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface FBX2GLProgram : NSObject

@property (assign, nonatomic) GLuint program;

- (GLuint)createProgram; //1 create programm - will be ready but not setuped yet (only after 6 step)
- (void)bindAttributeWithName:(const GLchar*)attributeName type:(GLKVertexAttrib)attrType; //2 bidna all needed attribute for shaders
- (BOOL)linkProgram; //3 link shaders within program
- (GLuint)uniformLocation:(const GLchar*)uniformName; //4 get all required uniform locations after linking
- (GLuint)attributesLocation:(const GLchar*)attributeName; //5 get all required attributes locations after linking
- (void)releaseShaders; //6 release shaders when u get all uniforms

- (void)destroyProgram; //free memory when programm not needed any more

@end
