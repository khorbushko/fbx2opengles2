//
//  ObjectStucture.h
//  testFBX
//
//  Created by Kirill Gorbushko on 06.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//


#ifndef ObjectStucture_h
#define ObjectStucture_h

struct VisualFBXObjectModel {
    float * vertices;
    float * texCoords;
    float *normals;
    int *indises;
    
    int numberOfVertices;
    int numberOfTextCoords;
    int numberOfNormals;
    int numberOfIndises;
};

typedef struct VisualFBXObjectModel FBXModel;

enum {
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_TEXTURE,
    UNIFORM_NORMALS,
    UNIFORM_COUNT
};

enum {
    ATTRIBUTES_TEXTURE_COORDINATE,
    ATTRIBUTES_COUNT
};

#endif /* ObjectStucture_h */
