//
//  FBX2GLModelMigrator.m
//  testFBX
//
//  Created by Kirill Gorbushko on 06.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

//#define PRINT_ENABLED

#import "FBX2GLModelMigrator.h"

#import "fbxsdk.h"
#import "main.h"
#import "Common.h"

#include <iostream>

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
        [self prepareFBXObjects];
        if (![self loadObjectNamed:fileNamed]) {
            NSLog(@"Cant load model with name: %@", fileNamed);
        } else {
            [self parseDataFromModel];
        }
    }
    return self;
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
            [self displaySelectedPolygons:mesh];
#warning to make for multy mesh in model
        }
    }
}

- (void)displaySelectedPolygons:(FbxMesh *)pMesh
{
    int polygonCount = pMesh->GetPolygonCount();
    int totalObjSize = 0;
    for (int i = 0; i < polygonCount; ++i) {
        totalObjSize += pMesh->GetPolygonSize(i);
    }
    
    int index = 0;
    int pairCounter = 0;
    for (int i = 0; i < polygonCount; i++) {
        int lPolygonSize = pMesh->GetPolygonSize(i);
        for (int j = 0; j< lPolygonSize; j++) {
            index++;
            if (j==2) {
                pairCounter++;
                if ((pairCounter % 2)) {
                    index++;
                    index++;
                    pairCounter = 0;
                }
            }
        }
    }
    
    int indicessCount = index;
    int *testIndices = new int [indicessCount]; //workaround - need to find solution
    
    index = 0;
    pairCounter = 0;
    for (int i = 0; i < polygonCount; i++) {
        int lPolygonSize = pMesh->GetPolygonSize(i);
        for (int j = 0; j< lPolygonSize; j++) {
            testIndices[index++] = i*4 + j;
            //  std::cout<<testIndices[index-1]<<"\n";
            if (j==2) {
                pairCounter++;
                if ((pairCounter % 2)) {
                    int firstIndex = index-3;
                    int secondIndex = index-1;
                    testIndices[index++] = testIndices[firstIndex];
                    //    std::cout<<testIndices[index-1]<<"\n";
                    testIndices[index++] = testIndices[secondIndex];
                    //  std::cout<<testIndices[index-1]<<"\n";
                    pairCounter = 0;
                }
            }
        }
    }
    
    int texturesUVCount = 0;
    int verticesOriginalCount = 0;
    int normalsOriginalCount = 0;
    
    for (int i = 0; i < pMesh->GetPolygonCount(); i++) {
        int lPolygonSize = pMesh->GetPolygonSize(i) ;
        verticesOriginalCount += 3*lPolygonSize;
        for (int k = 0; k < lPolygonSize; k ++) {
            for (int l = 0; l < pMesh->GetElementUVCount(); ++l) {
                texturesUVCount += 2;
            }
            for(int l = 0; l < pMesh->GetElementNormalCount(); ++l) {
                normalsOriginalCount += 3;
            }
        }
    }
    
    _model.vertices = new float[verticesOriginalCount];
    _model.texCoords = new float[texturesUVCount];
    _model.normals = new float[normalsOriginalCount];
    _model.indises = testIndices;
    
    _model.numberOfVertices = verticesOriginalCount;
    _model.numberOfIndises = indicessCount;
    _model.numberOfTextCoords = texturesUVCount;
    _model.numberOfNormals = normalsOriginalCount;
    
    int i, j, lPolygonCount = pMesh->GetPolygonCount();
    FbxVector4* lControlPoints = pMesh->GetControlPoints();

    
#ifdef PRINT_ENABLED
    char header[100];
    DisplayString("    Polygons");
#endif
    int vertexId = 0;
    int verticesOffset = 0;
    int texturesOffset = 0;
    int normalsOffset = 0;
    
    for (i = 0; i < lPolygonCount; i++) {
#ifdef PRINT_ENABLED
        DisplayInt("        Polygon ", i);
#endif
        int l;
        int lPolygonSize = pMesh->GetPolygonSize(i);
        for (j = 0; j < lPolygonSize; j++) {
            int lControlPointIndex = pMesh->GetPolygonVertex(i, j);
#ifdef PRINT_ENABLED
            Display3DVector("            Coordinates: ", lControlPoints[lControlPointIndex]);
#endif
            _model.vertices[verticesOffset++] = lControlPoints[lControlPointIndex][0];
            _model.vertices[verticesOffset++] = lControlPoints[lControlPointIndex][1];
            _model.vertices[verticesOffset++] = lControlPoints[lControlPointIndex][2];
            
            for (l = 0; l < pMesh->GetElementVertexColorCount(); l++) {
                FbxGeometryElementVertexColor* leVtxc = pMesh->GetElementVertexColor( l);
#ifdef PRINT_ENABLED
                FBXSDK_sprintf(header, 100, "            Color vertex: ");
#endif
                switch (leVtxc->GetMappingMode()) {
                    default:
                        break;
                    case FbxGeometryElement::eByControlPoint:
                        switch (leVtxc->GetReferenceMode()) {
                            case FbxGeometryElement::eDirect:
#ifdef PRINT_ENABLED
                                DisplayColor(header, leVtxc->GetDirectArray().GetAt(lControlPointIndex));
#endif
                                break;
                            case FbxGeometryElement::eIndexToDirect: {
#ifdef PRINT_ENABLED
                                int id = leVtxc->GetIndexArray().GetAt(lControlPointIndex);
                                DisplayColor(header, leVtxc->GetDirectArray().GetAt(id));
#endif
                            }
                                break;
                            default:
                                break; // other reference modes not shown here!
                        }
                        break;
                    case FbxGeometryElement::eByPolygonVertex: {
                        switch (leVtxc->GetReferenceMode()) {
                            case FbxGeometryElement::eDirect:
#ifdef PRINT_ENABLED
                                DisplayColor(header, leVtxc->GetDirectArray().GetAt(vertexId));
#endif
                                break;
                            case FbxGeometryElement::eIndexToDirect: {
#ifdef PRINT_ENABLED
                                int id = leVtxc->GetIndexArray().GetAt(vertexId);
                                DisplayColor(header, leVtxc->GetDirectArray().GetAt(id));
#endif
                            }
                                break;
                            default:
                                break; // other reference modes not shown here!
                        }
                    }
                        break;
                    case FbxGeometryElement::eByPolygon: // doesn't make much sense for UVs
                    case FbxGeometryElement::eAllSame:   // doesn't make much sense for UVs
                    case FbxGeometryElement::eNone:       // doesn't make much sense for UVs
                        break;
                }
            }
            for (l = 0; l < pMesh->GetElementUVCount(); ++l) {
                FbxGeometryElementUV* leUV = pMesh->GetElementUV( l);
#ifdef PRINT_ENABLED
                FBXSDK_sprintf(header, 100, "            Texture UV: ");
#endif
                switch (leUV->GetMappingMode()) {
                    default:
                        break;
                    case FbxGeometryElement::eByControlPoint:
                        switch (leUV->GetReferenceMode()) {
                            case FbxGeometryElement::eDirect:
#ifdef PRINT_ENABLED
                                Display2DVector(header, leUV->GetDirectArray().GetAt(lControlPointIndex));
#endif
                                _model.texCoords[texturesOffset++] = leUV->GetDirectArray().GetAt(lControlPointIndex)[0];
                                _model.texCoords[texturesOffset++] = leUV->GetDirectArray().GetAt(lControlPointIndex)[1];
                                
                                break;
                            case FbxGeometryElement::eIndexToDirect: {
                                int id = leUV->GetIndexArray().GetAt(lControlPointIndex);
#ifdef PRINT_ENABLED
                                Display2DVector(header, leUV->GetDirectArray().GetAt(id));
#endif
                                _model.texCoords[texturesOffset++] = leUV->GetDirectArray().GetAt(id)[0];
                                _model.texCoords[texturesOffset++] = leUV->GetDirectArray().GetAt(id)[1];
                                
                            }
                                break;
                            default:
                                break; // other reference modes not shown here!
                        }
                        break;
                    case FbxGeometryElement::eByPolygonVertex: {
                        int lTextureUVIndex = pMesh->GetTextureUVIndex(i, j);
                        switch (leUV->GetReferenceMode()) {
                            case FbxGeometryElement::eDirect:
                            case FbxGeometryElement::eIndexToDirect: {
#ifdef PRINT_ENABLED
                                Display2DVector(header, leUV->GetDirectArray().GetAt(lTextureUVIndex));
#endif
                                _model.texCoords[texturesOffset++] = leUV->GetDirectArray().GetAt(lTextureUVIndex)[0];
                                _model.texCoords[texturesOffset++] = leUV->GetDirectArray().GetAt(lTextureUVIndex)[1];
                                
                            }
                                break;
                            default:
                                break; // other reference modes not shown here!
                        }
                    }
                        break;
                    case FbxGeometryElement::eByPolygon: // doesn't make much sense for UVs
                    case FbxGeometryElement::eAllSame:   // doesn't make much sense for UVs
                    case FbxGeometryElement::eNone:       // doesn't make much sense for UVs
                        break;
                }
            }
            for( l = 0; l < pMesh->GetElementNormalCount(); ++l) {
                FbxGeometryElementNormal* leNormal = pMesh->GetElementNormal( l);
#ifdef PRINT_ENABLED
                FBXSDK_sprintf(header, 100, "            Normal: ");
#endif
                if(leNormal->GetMappingMode() == FbxGeometryElement::eByPolygonVertex) {
                    switch (leNormal->GetReferenceMode()) {
                        case FbxGeometryElement::eDirect:
#ifdef PRINT_ENABLED
                            Display3DVector(header, leNormal->GetDirectArray().GetAt(vertexId));
#endif
                            _model.normals[normalsOffset++] = leNormal->GetDirectArray().GetAt(vertexId)[0];
                            _model.normals[normalsOffset++] = leNormal->GetDirectArray().GetAt(vertexId)[1];
                            _model.normals[normalsOffset++] = leNormal->GetDirectArray().GetAt(vertexId)[2];
                            
                            break;
                        case FbxGeometryElement::eIndexToDirect: {
                            int id = leNormal->GetIndexArray().GetAt(vertexId);
#ifdef PRINT_ENABLED
                            Display3DVector(header, leNormal->GetDirectArray().GetAt(id));
#endif
                            _model.normals[normalsOffset++] = leNormal->GetDirectArray().GetAt(id)[0];
                            _model.normals[normalsOffset++] = leNormal->GetDirectArray().GetAt(id)[1];
                            _model.normals[normalsOffset++] = leNormal->GetDirectArray().GetAt(id)[2];
                            
                        }
                            break;
                        default:
                            break; // other reference modes not shown here!
                    }
                }
            }
            for( l = 0; l < pMesh->GetElementTangentCount(); ++l) {
                FbxGeometryElementTangent* leTangent = pMesh->GetElementTangent( l);
#ifdef PRINT_ENABLED
                FBXSDK_sprintf(header, 100, "            Tangent: ");
#endif
                if(leTangent->GetMappingMode() == FbxGeometryElement::eByPolygonVertex) {
                    switch (leTangent->GetReferenceMode()) {
                        case FbxGeometryElement::eDirect:
#ifdef PRINT_ENABLED
                            Display3DVector(header, leTangent->GetDirectArray().GetAt(vertexId));
#endif
                            break;
                        case FbxGeometryElement::eIndexToDirect: {
#ifdef PRINT_ENABLED
                            int id = leTangent->GetIndexArray().GetAt(vertexId);
                            Display3DVector(header, leTangent->GetDirectArray().GetAt(id));
#endif
                        }
                            break;
                        default:
                            break; // other reference modes not shown here!
                    }
                }
            }
            for( l = 0; l < pMesh->GetElementBinormalCount(); ++l) {
                FbxGeometryElementBinormal* leBinormal = pMesh->GetElementBinormal( l);
#ifdef PRINT_ENABLED
                FBXSDK_sprintf(header, 100, "            Binormal: ");
#endif
                if(leBinormal->GetMappingMode() == FbxGeometryElement::eByPolygonVertex) {
                    switch (leBinormal->GetReferenceMode()) {
                        case FbxGeometryElement::eDirect:
#ifdef PRINT_ENABLED
                            Display3DVector(header, leBinormal->GetDirectArray().GetAt(vertexId));
#endif
                            break;
                        case FbxGeometryElement::eIndexToDirect: {
#ifdef PRINT_ENABLED
                            int id = leBinormal->GetIndexArray().GetAt(vertexId);
                            Display3DVector(header, leBinormal->GetDirectArray().GetAt(id));
#endif
                        }
                            break;
                        default:
                            break; // other reference modes not shown here!
                    }
                }
            }
            vertexId++;
        } // for polygonSize
    } // for polygonCount
    
    //check visibility for the edges of the mesh
    for(int l = 0; l < pMesh->GetElementVisibilityCount(); ++l) {
        FbxGeometryElementVisibility* leVisibility=pMesh->GetElementVisibility(l);
#ifdef PRINT_ENABLED
        FBXSDK_sprintf(header, 100, "    Edge Visibility : ");
        DisplayString(header);
#endif
        switch(leVisibility->GetMappingMode()) {
            default:
                break;
                //should be eByEdge
            case FbxGeometryElement::eByEdge:
                //should be eDirect
                for(int j=0; j!=pMesh->GetMeshEdgeCount();++j) {
#ifdef PRINT_ENABLED
                    DisplayInt("        Edge ", j);
                    DisplayBool("              Edge visibility: ", leVisibility->GetDirectArray().GetAt(j));
#endif
                }
                break;
        }
    }
#ifdef PRINT_ENABLED
    DisplayString("");
#endif
    [self printObject];
}

- (void)printObject
{
    std::cout<<"\n----Indices----"<<_model.numberOfIndises;
#ifdef PRINT_ENABLED
    std::cout<<"\n";
    for (int i = 0; i < _model.numberOfIndises; i++) {
        std::cout<<_model.indises[i]<<"\n";
    }
#endif
    std::cout<<"\n----Coordinates(Vertises)----"<<_model.numberOfVertices;
#ifdef PRINT_ENABLED
    std::cout<<"\n";
    for (int i = 0; i < _model.numberOfVertices; i= i + 3) {
        std::cout<<_model.vertices[i]<<" "<<_model.vertices[i+1]<<" "<<_model.vertices[i+2]<<" "<<"\n";
    }
#endif
    std::cout<<"\n----Texture UV----"<<_model.numberOfTextCoords;
#ifdef PRINT_ENABLED
    std::cout<<"\n";
    for (int i = 0; i < _model.numberOfTextCoords; i= i + 2) {
        std::cout<<_model.texCoords[i]<<" "<<_model.texCoords[i+1]<<"\n";
    }
#endif
    std::cout<<"\n----Normal----"<<_model.numberOfNormals;
#ifdef PRINT_ENABLED
    std::cout<<"\n";
    for (int i = 0; i < _model.numberOfNormals; i= i + 3) {
        std::cout<<_model.normals[i]<<" "<<_model.normals[i+1]<<" "<<_model.normals[i+2]<<" "<<"\n";
    }
#endif
}

@end
