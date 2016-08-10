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

@end

@implementation FBX2GLModelMigrator

#pragma mark - LifeCycle

- (instancetype)initWithModelNamed:(NSString *)fileNamed
{
    self = [super init];
    if (self) {
        _avaliableModels = [NSMutableArray array];
        
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
    
    for (FBX2GLModel *model in self.avaliableModels) {
        [model destroyModel];
    }
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
                [self.avaliableModels addObject:meshSubModel];
            }
        }
    }
}

@end
