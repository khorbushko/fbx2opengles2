//
//  FBX2GLModel.m
//  testFBX
//
//  Created by Kirill Gorbushko on 10.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

#include <iostream>

#import "FBX2GLModel.h"
#import "main.h"
#import "Common.h"

@implementation FBX2GLModel

#pragma mark - LifeCycle

- (instancetype)initWithMesh:(FbxMesh *)pMesh
{
    self = [super init];
    if (self) {
        [self generateModelWith:pMesh];
    }
    return self;
}

- (void)destroyModel
{    
    if (_displayModel.vertices) {
        free(_displayModel.vertices);
    }
    if (_displayModel.normals) {
        free(_displayModel.normals);
    }
    if (_displayModel.indises) {
        free(_displayModel.indises);
    }
    if (_displayModel.texCoords) {
        free(_displayModel.texCoords);
    }
//    free(&(_displayModel));
}

#pragma mark - Public

- (void)printObjectWithDetails:(BOOL)details
{
    std::cout<<"\n----Indices----"<<_displayModel.numberOfIndises;
    if (details) {
        std::cout<<"\n";
        for (int i = 0; i < _displayModel.numberOfIndises; i++) {
            std::cout<<_displayModel.indises[i]<<"\n";
        }
    }
    std::cout<<"\n----Coordinates(Vertises)----"<<_displayModel.numberOfVertices;
    if (details) {
        std::cout<<"\n";
        for (int i = 0; i < _displayModel.numberOfVertices; i= i + 3) {
            std::cout<<_displayModel.vertices[i]<<" "<<_displayModel.vertices[i+1]<<" "<<_displayModel.vertices[i+2]<<" "<<"\n";
        }
    }
    std::cout<<"\n----Texture UV----"<<_displayModel.numberOfTextCoords;
    if (details) {
        std::cout<<"\n";
        for (int i = 0; i < _displayModel.numberOfTextCoords; i= i + 2) {
            std::cout<<_displayModel.texCoords[i]<<" "<<_displayModel.texCoords[i+1]<<"\n";
        }
    }
    std::cout<<"\n----Normal----"<<_displayModel.numberOfNormals;
    if (details) {
        std::cout<<"\n";
        for (int i = 0; i < _displayModel.numberOfNormals; i= i + 3) {
            std::cout<<_displayModel.normals[i]<<" "<<_displayModel.normals[i+1]<<" "<<_displayModel.normals[i+2]<<" "<<"\n";
        }
    }
}

#pragma mark - Private

- (void)generateModelWith:(FbxMesh *)pMesh
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
                if ((pairCounter % 1)) {
                    index++;
                    index++;
                    pairCounter = 0;
                }
                pairCounter++;
            }
        }
    }

    int indicessCount = index;
    _displayModel.indises = new int [indicessCount];
    
    index = 0;
    pairCounter = 0;
    int indexElement = 0;
    for (int i = 0; i < polygonCount; i++) {
        int lPolygonSize = pMesh->GetPolygonSize(i);
        for (int j = 0; j< lPolygonSize; j++) {
            _displayModel.indises[index++] = indexElement + j;
            if (j==2) {
                if ((pairCounter % 1)) {
                    int firstIndex = index-3;
                    int secondIndex = index-1;
                    _displayModel.indises[index++] = _displayModel.indises[secondIndex];
                    _displayModel.indises[index++] = _displayModel.indises[firstIndex];
                    pairCounter = 0;
                }
                pairCounter++;
            }
        }
        indexElement += lPolygonSize;
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
    
    _displayModel.vertices = new float[verticesOriginalCount];
    _displayModel.texCoords = new float[texturesUVCount];
    _displayModel.normals = new float[normalsOriginalCount];
    
    _displayModel.numberOfVertices = verticesOriginalCount;
    _displayModel.numberOfIndises = indicessCount;
    _displayModel.numberOfTextCoords = texturesUVCount;
    _displayModel.numberOfNormals = normalsOriginalCount;
    
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
            _displayModel.vertices[verticesOffset++] = lControlPoints[lControlPointIndex][0];
            _displayModel.vertices[verticesOffset++] = lControlPoints[lControlPointIndex][1];
            _displayModel.vertices[verticesOffset++] = lControlPoints[lControlPointIndex][2];
            
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
                                _displayModel.texCoords[texturesOffset++] = leUV->GetDirectArray().GetAt(lControlPointIndex)[0];
                                _displayModel.texCoords[texturesOffset++] = leUV->GetDirectArray().GetAt(lControlPointIndex)[1];
                                
                                break;
                            case FbxGeometryElement::eIndexToDirect: {
                                int id = leUV->GetIndexArray().GetAt(lControlPointIndex);
#ifdef PRINT_ENABLED
                                Display2DVector(header, leUV->GetDirectArray().GetAt(id));
#endif
                                _displayModel.texCoords[texturesOffset++] = leUV->GetDirectArray().GetAt(id)[0];
                                _displayModel.texCoords[texturesOffset++] = leUV->GetDirectArray().GetAt(id)[1];
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
                                _displayModel.texCoords[texturesOffset++] = leUV->GetDirectArray().GetAt(lTextureUVIndex)[0];
                                _displayModel.texCoords[texturesOffset++] = leUV->GetDirectArray().GetAt(lTextureUVIndex)[1];
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
                            _displayModel.normals[normalsOffset++] = leNormal->GetDirectArray().GetAt(vertexId)[0];
                            _displayModel.normals[normalsOffset++] = leNormal->GetDirectArray().GetAt(vertexId)[1];
                            _displayModel.normals[normalsOffset++] = leNormal->GetDirectArray().GetAt(vertexId)[2];
                            break;
                        case FbxGeometryElement::eIndexToDirect: {
                            int id = leNormal->GetIndexArray().GetAt(vertexId);
#ifdef PRINT_ENABLED
                            Display3DVector(header, leNormal->GetDirectArray().GetAt(id));
#endif
                            _displayModel.normals[normalsOffset++] = leNormal->GetDirectArray().GetAt(id)[0];
                            _displayModel.normals[normalsOffset++] = leNormal->GetDirectArray().GetAt(id)[1];
                            _displayModel.normals[normalsOffset++] = leNormal->GetDirectArray().GetAt(id)[2];
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
    std::cout<<"\n\n----------------\n"<<"\n----Indices----"<<_displayModel.numberOfIndises;
#ifdef PRINT_ENABLED
    std::cout<<"\n";
    for (int i = 0; i < _displayModel.numberOfIndises; i++) {
        std::cout<<_displayModel.indises[i]<<"\n";
    }
#endif
    std::cout<<"\n----Coordinates(Vertises)----"<<_displayModel.numberOfVertices;
#ifdef PRINT_ENABLED
    std::cout<<"\n";
    for (int i = 0; i < _displayModel.numberOfVertices; i= i + 3) {
        std::cout<<_displayModel.vertices[i]<<" "<<_displayModel.vertices[i+1]<<" "<<_displayModel.vertices[i+2]<<" "<<"\n";
    }
#endif
    std::cout<<"\n----Texture UV----"<<_displayModel.numberOfTextCoords;
#ifdef PRINT_ENABLED
    std::cout<<"\n";
    for (int i = 0; i < _displayModel.numberOfTextCoords; i= i + 2) {
        std::cout<<_displayModel.texCoords[i]<<" "<<_displayModel.texCoords[i+1]<<"\n";
    }
#endif
    std::cout<<"\n----Normal----"<<_displayModel.numberOfNormals;
#ifdef PRINT_ENABLED
    std::cout<<"\n";
    for (int i = 0; i < _displayModel.numberOfNormals; i= i + 3) {
        std::cout<<_displayModel.normals[i]<<" "<<_displayModel.normals[i+1]<<" "<<_displayModel.normals[i+2]<<" "<<"\n";
    }
#endif
}

#pragma mark - Override

- (NSString *)description
{
    NSDictionary *dic = @{
                          @"Indices" : @(_displayModel.numberOfIndises),
                          @"Coordinates(Vertises)" : @(_displayModel.numberOfVertices),
                          @"Texture UV" : @(_displayModel.numberOfTextCoords),
                          @"Normal" : @(_displayModel.numberOfNormals)
                          };
    
    return [NSString stringWithFormat:@"%@", dic];
}

@end
