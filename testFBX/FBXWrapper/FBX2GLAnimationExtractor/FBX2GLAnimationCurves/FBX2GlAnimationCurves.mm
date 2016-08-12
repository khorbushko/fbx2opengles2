//
//  FBX2GlAnimationCurves.m
//  testFBX
//
//  Created by Kirill Gorbushko on 12.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

#import "FBX2GlAnimationCurves.h"
#import "FBX2GLAnimationCurveItem.h"

@implementation FBX2GlAnimationCurves

#pragma mark - LifeCycle

- (instancetype)initFromNode:(FbxNode *)pNode onLayer:(FbxAnimLayer *)pAnimLayer
{
    self = [super init];
    if (self) {
        
        _curvesItems = [NSMutableArray array];
        
        //general curver
        FbxAnimCurve* lAnimCurve = NULL;
        lAnimCurve = pNode->LclTranslation.GetCurve(pAnimLayer, FBXSDK_CURVENODE_COMPONENT_X);
        if (lAnimCurve) {
            [self readCurve:lAnimCurve forName:CurveItemNameTX];
        }
        lAnimCurve = pNode->LclTranslation.GetCurve(pAnimLayer, FBXSDK_CURVENODE_COMPONENT_Y);
        if (lAnimCurve) {
            [self readCurve:lAnimCurve forName:CurveItemNameTY];
        }
        lAnimCurve = pNode->LclTranslation.GetCurve(pAnimLayer, FBXSDK_CURVENODE_COMPONENT_Z);
        if (lAnimCurve) {
            [self readCurve:lAnimCurve forName:CurveItemNameTZ];
        }
        lAnimCurve = pNode->LclRotation.GetCurve(pAnimLayer, FBXSDK_CURVENODE_COMPONENT_X);
        if (lAnimCurve) {
            [self readCurve:lAnimCurve forName:CurveItemNameRX];
        }
        lAnimCurve = pNode->LclRotation.GetCurve(pAnimLayer, FBXSDK_CURVENODE_COMPONENT_Y);
        if (lAnimCurve) {
            [self readCurve:lAnimCurve forName:CurveItemNameRY];
        }
        lAnimCurve = pNode->LclRotation.GetCurve(pAnimLayer, FBXSDK_CURVENODE_COMPONENT_Z);
        if (lAnimCurve) {
            [self readCurve:lAnimCurve forName:CurveItemNameRZ];
        }
        lAnimCurve = pNode->LclScaling.GetCurve(pAnimLayer, FBXSDK_CURVENODE_COMPONENT_X);
        if (lAnimCurve) {
            [self readCurve:lAnimCurve forName:CurveItemNameSX];
        }
        lAnimCurve = pNode->LclScaling.GetCurve(pAnimLayer, FBXSDK_CURVENODE_COMPONENT_Y);
        if (lAnimCurve) {
            [self readCurve:lAnimCurve forName:CurveItemNameSY];
        }
        lAnimCurve = pNode->LclScaling.GetCurve(pAnimLayer, FBXSDK_CURVENODE_COMPONENT_Z);
        if (lAnimCurve) {
            [self readCurve:lAnimCurve forName:CurveItemNameSZ];
        }
    }
        
    return self;
}

//- (GLKMatrix4)curveMatrix
//{
//    GLKMatrix4 curveTranslate = GLKMatrix4Translate(GLKMatrix4Identity, _txValue, -_tyValue, _tzValue);
//    GLKMatrix4 curveScale = GLKMatrix4MakeScale(_sxValue, -_syValue, _szValue);
//    
//    GLKMatrix4 curveRotate = GLKMatrix4MakeXRotation(GLKMathDegreesToRadians(_rxValue));
//    curveRotate = GLKMatrix4RotateY(curveRotate, -GLKMathDegreesToRadians(_ryValue));
//    curveRotate = GLKMatrix4RotateZ(curveRotate, GLKMathDegreesToRadians(_rzValue));
//    
//    GLKMatrix4 curveMatrix = GLKMatrix4Identity;
//    curveMatrix = GLKMatrix4Multiply(curveMatrix, curveScale);
//    curveMatrix = GLKMatrix4Multiply(curveMatrix, curveRotate);
//    curveMatrix = GLKMatrix4Multiply(curveMatrix, curveTranslate);
//    
//    return curveMatrix;
//}

#pragma mark - Private

- (void)readCurve:(FbxAnimCurve *)curve forName:(CurveItemName)name
{
    int lKeyCount = curve->KeyGetCount();
    char lTimeString[256];
    for(int lCount = 0; lCount < lKeyCount; lCount++) {
        float key = static_cast<float>(curve->KeyGetValue(lCount));
        float value = [[NSString stringWithUTF8String:curve->KeyGetTime(lCount).GetTimeString(lTimeString, FbxUShort(256))] floatValue];
        
        FBX2GLAnimationCurveItem *item = [[FBX2GLAnimationCurveItem alloc] init];
        item.key = key;
        item.value = value;
        item.name = name;
        item.index = lCount;
        
        [self.curvesItems addObject:item];
    }
}

@end
