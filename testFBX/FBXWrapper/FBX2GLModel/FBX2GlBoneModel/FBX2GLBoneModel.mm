//
//  FBX2GLBoneModel.m
//  testFBX
//
//  Created by Kirill Gorbushko on 16.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

#import "FBX2GLBoneModel.h"

@implementation FBX2GLBoneModel

#pragma mark - Public

- (void)cleanUp
{
//    if (_indices) {
//        free(_indices);
//    }
    if (_rawMatrixData) {
        free(_rawMatrixData);
    }
}

@end
