//
//  FBX2GLAnimationCurveItem.h
//  testFBX
//
//  Created by Kirill Gorbushko on 12.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "fbxsdk.h"
#import <GLKit/GLKit.h>

typedef NS_ENUM(NSUInteger, CurveItemName) {
    CurveItemNameTX,
    CurveItemNameTY,
    CurveItemNameTZ,
    CurveItemNameRX,
    CurveItemNameRY,
    CurveItemNameRZ,
    CurveItemNameSX,
    CurveItemNameSY,
    CurveItemNameSZ,
};

@interface FBX2GLAnimationCurveItem : NSObject

@property (assign, nonatomic) CGFloat actualValue;
@property (assign, nonatomic) CGFloat timingValue;
@property (assign, nonatomic) CGFloat index;

@property (assign, nonatomic) CurveItemName name;

@end
