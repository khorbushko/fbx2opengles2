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
        
        //general curves
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
    
    _transformsCount = _curvesItems.count / 9;
            
    return self;
}

- (GLKMatrix4)curveTransformForIndex:(NSInteger)transformIndex
{
    if (transformIndex >= _transformsCount) {
        return GLKMatrix4Identity;
    }
    
    float txValue = 0.0, tyValue = 0.0, tzValue = 0.0,
          rxValue = 0.0, ryValue = 0.0, rzValue = 0.0,
          sxValue = 0.0, syValue = 0.0, szValue = 0.0;
    
    int match = 0;
    for (int i = 0 ;i < _transformsCount * 9; i++) {
        FBX2GLAnimationCurveItem *item = self.curvesItems[i];
        
        if (item.index == transformIndex) {
            switch (item.name) {
                case CurveItemNameTX: {
                    txValue = item.actualValue;
                    match++;
                    break;
                }
                case CurveItemNameTY: {
                    tyValue = item.actualValue;
                    match++;
                    break;
                }
                case CurveItemNameTZ: {
                    tzValue = item.actualValue;
                    match++;
                    break;
                }
                case CurveItemNameRX: {
                    rxValue = item.actualValue;
                    match++;
                    break;
                }
                case CurveItemNameRY: {
                    ryValue = item.actualValue;
                    match++;
                    break;
                }
                case CurveItemNameRZ: {
                    rzValue = item.actualValue;
                    match++;
                    break;
                }
                case CurveItemNameSX: {
                    sxValue = item.actualValue;
                    match++;
                    break;
                }
                case CurveItemNameSY: {
                    syValue = item.actualValue;
                    match++;
                    break;
                }
                case CurveItemNameSZ: {
                    szValue = item.actualValue;
                    match++;
                    break;
                }

            }
        }
        if (match == 9) {
            break;
        }
    }
    
    GLfloat divider = 1;

    GLKMatrix4 curveTranslate = GLKMatrix4Translate(GLKMatrix4Identity, txValue / divider, tyValue/ divider, tzValue/ divider);
    GLKMatrix4 curveScale = GLKMatrix4MakeScale(sxValue/ divider, syValue/ divider, szValue/ divider);

    GLKMatrix4 curveRotate = GLKMatrix4MakeXRotation(GLKMathDegreesToRadians(rxValue));
    curveRotate = GLKMatrix4RotateY(curveRotate, GLKMathDegreesToRadians(ryValue));
    curveRotate = GLKMatrix4RotateZ(curveRotate, GLKMathDegreesToRadians(rzValue));

    GLKMatrix4 curveMatrix = GLKMatrix4Identity;
    curveMatrix = GLKMatrix4Multiply(curveMatrix, curveScale);
    curveMatrix = GLKMatrix4Multiply(curveMatrix, curveRotate);
    curveMatrix = GLKMatrix4Multiply(curveMatrix, curveTranslate);
    
    return curveMatrix;
}

#pragma mark - Private

- (void)readCurve:(FbxAnimCurve *)curve forName:(CurveItemName)name
{
    int lKeyCount = curve->KeyGetCount();

    for(int lCount = 0; lCount < lKeyCount; lCount++) {
        float actualValue = curve->KeyGetValue(lCount);
        float value = curve->KeyGetTime(lCount).GetSecondDouble();
        
        FBX2GLAnimationCurveItem *item = [[FBX2GLAnimationCurveItem alloc] init];
        item.actualValue = actualValue;
        item.timingValue = value;
        item.name = name;
        item.index = lCount;
        
        [self.curvesItems addObject:item];
    }
}

@end
