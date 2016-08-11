//
//  FBX2GLModelMigrator.m
//  testFBX
//
//  Created by Kirill Gorbushko on 06.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

//#define PRINT_ENABLED

#import "FBX2GLModelMigrator.h"
#import "FBX2GLModel.h"

#import "fbxsdk.h"
#import "main.h"
#import "Common.h"

#include <iostream>
#include <vector>

@interface FBX2GLModelMigrator()

@property (assign, nonatomic) FbxManager *fbxManager;
@property (assign, nonatomic) FbxScene *fbxScene;

@property (assign, nonatomic) BOOL hasAnimationInStack;

@end

@implementation FBX2GLModelMigrator

#pragma mark - LifeCycle

- (instancetype)initWithModelNamed:(NSString *)fileNamed
{
    self = [super init];
    if (self) {
        _avaliableModels = [NSMutableArray array];
        _hasAnimationInStack = NO;
        
        [self prepareFBXObjects];
        if (![self loadObjectNamed:fileNamed]) {
            NSLog(@"Cant load model with name: %@", fileNamed);
        } else {
            [self parseDataFromModel];
        }
    }
    return self;
}

- (void)dealloc
{
    DestroySdkObjects(_fbxManager, true);
}

#pragma mark - Private

- (void)prepareFBXObjects
{
    InitializeSdkObjects(_fbxManager, _fbxScene);
}

- (BOOL)loadObjectNamed:(NSString *)objectName
{
    NSString *filePath =[[NSBundle mainBundle] pathForResource:[[objectName lastPathComponent] stringByDeletingPathExtension] ofType:[objectName pathExtension]];
    
    FbxString fbxSt([filePath cStringUsingEncoding:[NSString defaultCStringEncoding]]);
    bool bResult = LoadScene(_fbxManager, _fbxScene, fbxSt.Buffer());
    
    
//    lAnimStackCount = lImporter->GetAnimStackCount();

    
    
    return (bResult);
}

- (void)parseDataFromModel
{
    FbxNode* modelNode = _fbxScene->GetRootNode();
    int childCount = modelNode->GetChildCount();
    FbxNode *childNode = 0;
    
    for (int i = 0; i < childCount; i++) {
        childNode = modelNode->GetChild(i);
        FbxMesh *mesh = childNode->GetMesh();
        
        if (mesh != NULL) {
            FBX2GLModel *meshSubModel = [[FBX2GLModel alloc] initWithMesh:mesh];
            if (meshSubModel.displayModel.numberOfIndises && meshSubModel.displayModel.numberOfVertices) {
                
                meshSubModel.globalTransfrorm = [self globalTransformNodeMatrix];
                meshSubModel.localTransfrorm = [self localTransfromNodeMatrix:childNode];
                
                const char* nodeName = childNode->GetName();
                meshSubModel.nodeName = [NSString stringWithUTF8String:nodeName];
                
                [self.avaliableModels addObject:meshSubModel];
            }
          //  [self readTexturesNameFromNode:childNode];
        }
    }
}

- (GLKMatrix4)localTransfromNodeMatrix:(FbxNode *)childNode
{
    FbxAMatrix& lLocalTransform = childNode->EvaluateLocalTransform();
    GLKMatrix4 localTransform;
    CGFloat *srcPointer = (CGFloat *)&lLocalTransform;
    GLfloat *destPointer = localTransform.m;
    for (int i = 0; i < 16; i++) {
        destPointer[i] = srcPointer[i];
    }
    return localTransform;
}

- (GLKMatrix4)globalTransformNodeMatrix
{
    FbxNode* modelNode = _fbxScene->GetRootNode();
    
    FbxDouble3 translation = modelNode->LclTranslation.Get();
    FbxDouble3 rotation = modelNode->LclRotation.Get();
    FbxDouble3 scaling = modelNode->LclScaling.Get();
    GLfloat divider = 100;
    GLint x = 0;
    GLint y = 2;
    GLint z = 1;
    
    GLKMatrix4 nodeTranslate = GLKMatrix4MakeTranslation(translation[x]/divider, -translation[y]/divider, translation[z]/divider);
    GLKMatrix4 nodeRotate = GLKMatrix4MakeXRotation(GLKMathDegreesToRadians(rotation[x]));
    nodeRotate = GLKMatrix4RotateY(nodeRotate, -GLKMathDegreesToRadians(rotation[y]));
    nodeRotate = GLKMatrix4RotateZ(nodeRotate, GLKMathDegreesToRadians(rotation[z]));
    GLKMatrix4 nodeScale = GLKMatrix4MakeScale(scaling[x] /divider, -scaling[y]/divider, scaling[z]/divider);
    
    GLKMatrix4 globalTransformationMatrix = GLKMatrix4Identity;
    globalTransformationMatrix = GLKMatrix4Multiply(globalTransformationMatrix, nodeScale);
    globalTransformationMatrix = GLKMatrix4Multiply(globalTransformationMatrix, nodeRotate);
    globalTransformationMatrix = GLKMatrix4Multiply(globalTransformationMatrix, nodeTranslate);
    
    return globalTransformationMatrix;
}

- (void)readTexturesNameFromNode:(FbxNode *)childNode
{
    int mCount = childNode->GetSrcObjectCount<FbxSurfaceMaterial>();
    
    for (int index = 0; index < mCount; index++) {
        FbxSurfaceMaterial *material = (FbxSurfaceMaterial*)childNode->GetSrcObject<FbxSurfaceMaterial>(index);
        if (material) {
            FbxProperty prop = material->FindProperty(FbxSurfaceMaterial::sDiffuse);
            int layered_texture_count = prop.GetSrcObjectCount<FbxLayeredTexture>();
            if (layered_texture_count > 0) {
                for (int j = 0; j < layered_texture_count; j++) {
                    FbxLayeredTexture* layered_texture = FbxCast<FbxLayeredTexture>(prop.GetSrcObject<FbxLayeredTexture>(j));
                    int lcount = layered_texture->GetSrcObjectCount<FbxTexture>();
                    for (int k = 0; k < lcount; k++) {
                        FbxTexture* texture = FbxCast<FbxTexture>(layered_texture->GetSrcObject<FbxTexture>(k));
                        const char* texture_name = texture->GetName();
//                        NSString *textureName = [NSString stringWithUTF8String:texture_name];
                        std::cout<<texture_name;
                    }
                }
            } else {
                int texture_count = prop.GetSrcObjectCount<FbxTexture>();
                for (int j = 0; j < texture_count; j++) {
                    const FbxTexture* texture = FbxCast<FbxTexture>(prop.GetSrcObject<FbxTexture>(j));
                    const char* texture_name = texture->GetName();
//                    NSString *textureName = [NSString stringWithUTF8String:texture_name];
                    std::cout<<texture_name;
                    FbxProperty p = texture->RootProperty.Find("Filename");
                    std::cout<<p.Get<FbxString>();
                }
            }
        }
    }
}

@end
