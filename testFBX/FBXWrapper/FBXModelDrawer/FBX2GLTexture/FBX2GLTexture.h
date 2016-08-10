//
//  TextureProvider.h
//  testFBX
//
//  Created by Kirill Gorbushko on 07.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface FBX2GLTexture : NSObject

@property (assign, nonatomic, readonly) GLuint name;

- (instancetype)initFromImageNamed:(NSString *)imageNamed;

- (void)setupTexture; //call this method only after preparing glMashine
- (void)cleanUpTexture;

@end
