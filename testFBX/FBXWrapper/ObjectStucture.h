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

#endif /* ObjectStucture_h */
