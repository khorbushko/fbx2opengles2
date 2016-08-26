//
//  FBX2GLBoneModel.h
//  testFBX
//
//  Created by Kirill Gorbushko on 16.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface FBX2GLBoneModel : NSObject

@property (strong, nonatomic) NSString *boneName;
@property (strong, nonatomic) NSString *parentStackName;

@property (assign, nonatomic) float *rawMatrixData;
@property (assign, nonatomic) int matrixCount;

@property (assign, nonatomic) int *indices;
@property (assign, nonatomic) int indicesCount;
@property (assign, nonatomic) GLuint indicesOffset;

- (void)cleanUp;

@end
