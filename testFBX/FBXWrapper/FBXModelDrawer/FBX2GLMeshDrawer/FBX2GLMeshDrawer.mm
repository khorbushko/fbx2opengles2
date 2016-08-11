//
//  FBX2GLMeshDrawer.m
//  testFBX
//
//  Created by Kirill Gorbushko on 10.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

#import <OpenGLES/ES2/glext.h>

#import "FBX2GLMeshDrawer.h"
#import "FBX2GLTexture.h"
#import "FBX2GLProgram.h"
#import "FBX2GLModel.h"

@interface FBX2GLMeshDrawer()

@property (strong, nonatomic) FBX2GLProgram *glProgram;
@property (strong, nonatomic) FBX2GLTexture *texture;
@property (strong, nonatomic) FBX2GLModel *source;
@property (assign, nonatomic) FBXModel drawModel;

@end

@implementation FBX2GLMeshDrawer
{
    GLuint _vertextArray;
    
    GLuint _vertexBuffer;
    GLuint _indexBuffer;
    GLuint _normalBuffer;
    GLuint _indisesBuffer;

    GLKMatrix3 _normalMatrix;
    
    GLuint uniforms[UNIFORM_COUNT];
    GLuint attributes[ATTRIBUTES_COUNT];
}

#pragma mark - LifeCycle

- (instancetype)initWithMeshModel:(FBX2GLModel *)meshModel textureName:(NSString *)textureName
{
    self = [super self];
    if (self) {
        
        NSAssert(meshModel.displayModel.numberOfIndises && meshModel.displayModel.numberOfVertices, @"glModel cant be empty");
        _drawModel = meshModel.displayModel;
        _source = meshModel;
        
        [self setupGLMashine];
        
        _texture = [[FBX2GLTexture alloc] initFromImageNamed:textureName];
        [_texture setupTexture];
        
    }
    return self;
}

- (void)tearDownGLDrawer
{
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteBuffers(1, &_normalBuffer);
    glDeleteBuffers(1, &_indisesBuffer);
    
    glDeleteVertexArraysOES(1, &_vertextArray);
    
    [self.glProgram destroyProgram];
    [_source destroyModel];
    [_texture cleanUpTexture];
}

#pragma mark - Public

- (void)pefromMeshDraw
{
    glUseProgram(self.glProgram.program);
    
    glBindVertexArrayOES(_vertextArray);
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _mvpMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMALS], 1, 0, _normalMatrix.m);
    
    if (_drawModel.numberOfTextCoords) {
        glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, _texture.name);
    }
    
    glDrawElements(GL_TRIANGLES, _drawModel.numberOfIndises, GL_UNSIGNED_INT, 0);
//    glDrawElements(GL_TRIANGLE_STRIP, _drawModel.numberOfIndises, GL_UNSIGNED_INT, 0);
//    glDrawElements(GL_TRIANGLE_FAN, _drawModel.numberOfIndises, GL_UNSIGNED_INT, 0);
//    glDrawElements(GL_LINE_STRIP, _drawModel.numberOfIndises, GL_UNSIGNED_INT, 0);
}

- (void)performMeshUpdateWithBaseMVPMatrix:(GLKMatrix4)baseMatrix
{
    //scale
    //rotate
    //translate
    _mvpMatrix = GLKMatrix4Multiply(baseMatrix, _source.globalTransfrorm);
    _mvpMatrix = GLKMatrix4Multiply(_mvpMatrix, _source.localTransfrorm);

    _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(_mvpMatrix), NULL);
}

#pragma mark - Private

- (void)setupGLMashine
{
    self.glProgram = [[FBX2GLProgram alloc] init];
    [self.glProgram createProgram];
    [self.glProgram bindAttributeWithName:"a_position" type:GLKVertexAttribPosition];
    [self.glProgram bindAttributeWithName:"normal" type:GLKVertexAttribNormal];
    [self.glProgram linkProgram];
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = [self.glProgram uniformLocation:"u_modelViewProjectionMatrix"];
    uniforms[UNIFORM_TEXTURE] = [self.glProgram uniformLocation:"u_texture"];
    uniforms[UNIFORM_NORMALS] = [self.glProgram uniformLocation:"normalMatrix"];
    attributes[ATTRIBUTES_TEXTURE_COORDINATE] = [self.glProgram attributesLocation:"a_texCoordIn"];
    [self.glProgram releaseShaders];
    
    [self bindBuffer];
}

- (void)bindBuffer
{
    glGenVertexArraysOES(1, &_vertextArray);
    glBindVertexArrayOES(_vertextArray);
    
    //coordinates for vertices
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * _drawModel.numberOfVertices, _drawModel.vertices, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, NULL);
    
    if (_drawModel.numberOfTextCoords) {
        //textures
        glGenBuffers(1, &_indexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, _indexBuffer);
        glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * _drawModel.numberOfTextCoords, _drawModel.texCoords, GL_STATIC_DRAW);
        
        glEnableVertexAttribArray(attributes[ATTRIBUTES_TEXTURE_COORDINATE]);
        glVertexAttribPointer(attributes[ATTRIBUTES_TEXTURE_COORDINATE], 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 2, NULL);
    }
    
    //indices order
    glGenBuffers(1, &_indisesBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indisesBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLuint) * _drawModel.numberOfIndises, _drawModel.indises, GL_STATIC_DRAW);
    
    if (_drawModel.numberOfNormals) {
        //normals
        glGenBuffers(1, &_normalBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, _normalBuffer);
        glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * _drawModel.numberOfNormals, _drawModel.normals, GL_STATIC_DRAW);
        
        glEnableVertexAttribArray(GLKVertexAttribNormal);
        glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, NULL);
    }
    
    glBindVertexArrayOES(0);
}

@end
