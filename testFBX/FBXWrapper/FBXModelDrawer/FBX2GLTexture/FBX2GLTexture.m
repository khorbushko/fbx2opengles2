//
//  TextureProvider.m
//  testFBX
//
//  Created by Kirill Gorbushko on 07.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

#import "FBX2GLTexture.h"

@interface FBX2GLTexture()

@property (strong, nonatomic) UIImage *cachedImage;

@end

@implementation FBX2GLTexture

#pragma mark - LifeCycle

- (instancetype)initFromImageNamed:(NSString *)imageNamed
{
    self = [super init];
    if (self) {
        _cachedImage = [UIImage imageNamed:imageNamed];
    }
    return self;
}

- (void)cleanUpTexture
{
    if (self.name) {
        GLuint textureName = self.name;
        glDeleteTextures(1, &textureName);
    }
}

#pragma mark - Private

- (void)setupTexture
{
    CGImageRef texture;
    if (_cachedImage.CGImage) {
        texture = _cachedImage.CGImage;
    }
    
    if (!texture) {
        NSLog(@"Error - cant setup texture for hotSpot, nill image");
        _name = 0;
    }
    
    GLsizei width = (GLsizei)CGImageGetWidth(texture);
    GLsizei height = (GLsizei)CGImageGetHeight(texture);
    
    GLubyte *textureData = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));
    CGContextRef textureContext = CGBitmapContextCreate(textureData, width, height, 8, width *4, CGImageGetColorSpace(texture), kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(textureContext, CGRectMake(0, 0, width, height), texture);
    CGContextRelease(textureContext);
    
    GLuint textureName;
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glGenTextures(1, &textureName);
    
    glBindTexture(GL_TEXTURE_2D, textureName);
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
    
    free(textureData);
    _name = textureName;
    //    CGImageRelease(texture);
}

@end
