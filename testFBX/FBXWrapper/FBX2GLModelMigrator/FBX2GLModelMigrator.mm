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
#import "FBX2GLAnimationExtractor.h"
#import "FBX2GLBoneModel.h"

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
            _fbxAnimator = [[FBX2GLAnimationExtractor alloc] initWithScene:_fbxScene];
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

    
    return (bResult);
}

- (void)parseDataFromModel
{
    FbxGeometryConverter converter(_fbxManager);
    converter.Triangulate(_fbxScene, true);
    
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
                
                [self extractAnimFromMesh:mesh inModel:meshSubModel];
                [self.avaliableModels addObject:meshSubModel];
            }
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

/*- (void)readTexturesNameFromNode:(FbxNode *)childNode
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
}*/

- (void)extractAnimFromMesh:(FbxMesh *)mesh inModel:(FBX2GLModel *)parentModel
{
    unsigned int numOfDeformers = mesh->GetDeformerCount();

    FbxNode* modelNode = _fbxScene->GetRootNode();
    FbxAMatrix geometryTransform = GetGeometryTransformation(modelNode);
    
    for (unsigned int deformerIndex = 0; deformerIndex < numOfDeformers; ++deformerIndex) {
        FbxSkin* currSkin = reinterpret_cast<FbxSkin*>(mesh->GetDeformer(deformerIndex, FbxDeformer::eSkin));
        if (!currSkin) {
            continue;
        }
        unsigned int numOfClusters = currSkin->GetClusterCount();
        float dur = 0;
        
        for (unsigned int clusterIndex = 0; clusterIndex < numOfClusters; ++clusterIndex) {
            FbxCluster* currCluster = currSkin->GetCluster(clusterIndex);
            const char* boneName = currCluster->GetLink()->GetName();

            FbxNode* boneNode = currCluster->GetLink();
            int childCount = modelNode->GetChildCount();
            const char* nodeName = boneNode->GetName();
            
            FBX2GLBoneModel *bone = [[FBX2GLBoneModel alloc] init];
            bone.indices = currCluster->GetControlPointIndices();
            bone.indicesCount = currCluster->GetControlPointIndicesCount();
            bone.boneName = [NSString stringWithUTF8String:boneName];
            
            [parentModel.bones addObject:bone];
            
//            for (int i = 0; i < bone.indicesCount; i++) {
//                std::cout<<bone.indices[i]<<"\n";
//            }
        
            FbxAMatrix transformMatrix;
            FbxAMatrix transformLinkMatrix;
            FbxAMatrix globalBindposeInverseMatrix;
            
            currCluster->GetTransformMatrix(transformMatrix);	// The transformation of the mesh at binding time
            currCluster->GetTransformLinkMatrix(transformLinkMatrix);	// The transformation of the cluster(joint) at binding time from joint space to world space
            globalBindposeInverseMatrix = transformLinkMatrix.Inverse() * transformMatrix * geometryTransform;
            
            // Get animation information
            // Now only supports one take
            FbxAnimStack* currAnimStack = _fbxScene->GetSrcObject<FbxAnimStack>(0);
            FbxString animStackName = currAnimStack->GetName();
            char *mAnimationName = animStackName.Buffer();
            bone.parentStackName = [NSString stringWithUTF8String:mAnimationName];
            
            
            FbxTakeInfo* takeInfo = _fbxScene->GetTakeInfo(animStackName);
            FbxTime start = takeInfo->mLocalTimeSpan.GetStart();
            FbxTime end = takeInfo->mLocalTimeSpan.GetStop();
            FbxLongLong mAnimationLength = end.GetFrameCount(FbxTime::eFrames24) - start.GetFrameCount(FbxTime::eFrames24) + 1;

            dur = end.GetSecondDouble() - start.GetSecondDouble();
            
            bone.matrixCount = mAnimationLength;
            bone.rawMatrixData = new float [mAnimationLength * 16];
            for (FbxLongLong i = start.GetFrameCount(FbxTime::eFrames24); i <= end.GetFrameCount(FbxTime::eFrames24); ++i) {
                FbxTime currTime;
                currTime.SetFrame(i, FbxTime::eFrames24);

                FbxAMatrix currentTransformOffset = modelNode->EvaluateGlobalTransform(currTime) * geometryTransform;
                FbxAMatrix mat = currentTransformOffset.Inverse() * currCluster->GetLink()->EvaluateGlobalTransform(currTime);
                
                FbxVector4 translation = mat.GetT();
                
                CGFloat kof = 1;
                
                translation[0] /= kof;
                translation[1] /= kof;
                translation[2] /= kof;
                
                float buf = translation[1];
                translation[1] = translation[2];
                translation[2] = buf;
                
                FbxVector4 rotation = mat.GetR();
                
                buf = rotation[1];
                rotation[1] = rotation[2];
                rotation[2] = buf;

                FbxVector4 scale = mat.GetS();

                scale[0] /= kof;
                scale[1] /= kof;
                scale[2] /= kof;
                
                buf = scale[1];
                scale[1] = scale[2];
                scale[2] = buf;
                
                FbxAMatrix matrix = FbxAMatrix(translation, rotation, scale);
                
                mat.SetT(translation);
                mat.SetR(rotation);
                mat.SetS(scale);
                
                GLKMatrix4 localTransformGLK;
                CGFloat *srcPointer = (CGFloat *)&mat;
                GLfloat *destPointer = localTransformGLK.m;
                
                int offcet = (int)i * 16;
                for (int j = 0 + offcet; j < 16 + offcet; j++) {
                    destPointer[i] = srcPointer[i];
                    bone.rawMatrixData[i] = srcPointer[i];
                }
            }
            
        }
    }
    
    //JUST SAMPLE NOT AFFECT ANY LOGIC (FROM POST)
    
    //
    // Get Mesh Data
    FbxNode* currNode = mesh->GetNode();
    
//     Node Geomtric Transformation
    /*FbxAMatrix*/ geometryTransform = GetGeometryTransformation( currNode );
    
    // Get Number of Deformers
//    unsigned int numOfDeformers = inMesh->GetDeformerCount();
    
    // Loop through Node Deformers for Skins to get Cluster Data
    for( unsigned int deformerIndex = 0; deformerIndex < numOfDeformers; ++deformerIndex )
    {
        // Check if Deformer is a Skin
        FbxSkin* currSkin = reinterpret_cast<FbxSkin*>( mesh->GetDeformer( deformerIndex, FbxDeformer::eSkin ) );
        if( !currSkin )
        {
            continue;
        }
        
        // Get Number of Clusters in Skin
        unsigned int numOfClusters = currSkin->GetClusterCount();
        
        // Process Cluster Data
        for( unsigned int clusterIndex = 0; clusterIndex < numOfClusters; ++clusterIndex )
        {
            // Get Cluster from Skin
            FbxCluster* currCluster = currSkin->GetCluster( clusterIndex );
            
            // Get Joint Name
            std::string currJointName = currCluster->GetLink()->GetName();
            
            // Get Joint and Joint Index from Name
//            ModelObject::Joint* joint = nullptr;
//            unsigned int jointIdx = FindJointIndexUsingName( currJointName, &joint );
            
            // Matrices
            // 行列
            FbxAMatrix transformMatrix;                 // Mesh Tranformation at Binding Time
            FbxAMatrix transformLinkMatrix;             // The Transformation of the Cluster(joint) at Binding Time from Joint Space to World Space
            FbxAMatrix globalBindposeInverseMatrix;     // Bindpose Inverse Matrix
            
            // Get Matrix Data
            currCluster->GetTransformMatrix( transformMatrix );
            currCluster->GetTransformLinkMatrix( transformLinkMatrix );
            globalBindposeInverseMatrix = transformLinkMatrix.Inverse() * transformMatrix * geometryTransform;
            
            // Update Joint Matrix Data
//            joint->globalBindposeInverse = FbxAMatrixToMatrix44( globalBindposeInverseMatrix );
            
            // Associate Each Joint with the Control Points it Affects
            unsigned int numOfIndices = currCluster->GetControlPointIndicesCount();
            for( unsigned int idxCount = 0; idxCount < numOfIndices; ++idxCount )
            {
//                ModelObject::BlendingIndexWeightPair currBlendingIndexWeightPair;
//                currBlendingIndexWeightPair.blendingIndex = jointIdx;
//                currBlendingIndexWeightPair.blendingWeight = currCluster->GetControlPointWeights()[ idxCount ];
                
                // If Blending Weight is Above Minimum Value
//                if( currBlendingIndexWeightPair.blendingWeight > 0.1f )
//                {
                    // Get Control Index
                    int ctrlIdx = currCluster->GetControlPointIndices()[ idxCount ];
//
//                    // Get Model Blend Data Index
//                    int blendIdx = 0;
//                    for( blendIdx = 0; blendIdx < 4; blendIdx++ )
//                    {
//                        if( m_meshHold.ctrl.data[ ctrlIdx ].blendingInfo[ blendIdx ].blendingWeight == 0 )
//                        {
//                            // Add Blending Data to Control Point
//                            m_meshHold.ctrl.data[ ctrlIdx ].blendingInfo[ blendIdx ] = currBlendingIndexWeightPair;
//                            break;
//                        }
//                    }
//                }
            }
            
            // Get Animation Data
            // ( Currently only Supports one Take )
            FbxAnimStack* currAnimStack = _fbxScene->GetSrcObject<FbxAnimStack>( 0 );
            
            // Get Animation Name
            FbxString animStackName = currAnimStack->GetName();
            char *animName = animStackName.Buffer();
            
            // Get Take Info using Animation Name
            FbxTakeInfo* takeInfo = _fbxScene->GetTakeInfo( animStackName );
            
            // Get Animation Length
            FbxTime start = takeInfo->mLocalTimeSpan.GetStart();
            FbxTime end = takeInfo->mLocalTimeSpan.GetStop();
            long m_animationLength = end.GetFrameCount( FbxTime::eFrames24 ) - start.GetFrameCount( FbxTime::eFrames24 ) + 1;
            
            // Create Frames Based on Animation Length
//            joint->animation = new ModelObject::Frame[ ( int )m_animationLength ];
            
            // Process Animation Data
            int animCount = 0;
            for( FbxLongLong frameCount = start.GetFrameCount( FbxTime::eFrames24 ); frameCount <= end.GetFrameCount( FbxTime::eFrames24 ); ++frameCount )
            {
                // Set Frame Time
                FbxTime currTime;
                currTime.SetFrame( frameCount, FbxTime::eFrames24 );
                
                // Save Frame Number
//                joint->animation[ animCount ].curFrameNum = ( int )frameCount;
                
                // Get Global Transform Matrix
                FbxAMatrix currentTransformOffset = currNode->EvaluateGlobalTransform( currTime ) * geometryTransform;
                FbxAMatrix globalMtx = currentTransformOffset.Inverse() * currCluster->GetLink()->EvaluateGlobalTransform( currTime );
//                joint->animation[ animCount ].globalTransform = FbxAMatrixToMatrix44( globalMtx );
                
                // Increase Animation Array Count
                animCount++;
            }
        }
    }

    
}

FbxAMatrix GetGeometryTransformation(FbxNode* inNode)
{
    const FbxVector4 lT = inNode->GetGeometricTranslation(FbxNode::eSourcePivot);
    const FbxVector4 lR = inNode->GetGeometricRotation(FbxNode::eSourcePivot);
    const FbxVector4 lS = inNode->GetGeometricScaling(FbxNode::eSourcePivot);
    
    return FbxAMatrix(lT, lR, lS);
}

@end
