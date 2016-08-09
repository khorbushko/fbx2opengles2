//
//  GLDrawer.m
//  testFBX
//
//  Created by Kirill Gorbushko on 07.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

#import <OpenGLES/ES2/glext.h>
#import "GLDrawer.h"
#import "TextureGL.h"

enum {
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_TEXTURE,
    UNIFORM_NORMALS,
    UNIFORM_COUNT
};

GLuint uniforms[UNIFORM_COUNT];

enum {
    ATTRIBUTES_TEXTURE_COORDINATE,
    ATTRIBUTES_COUNT
};

GLuint attributes[ATTRIBUTES_COUNT];

@interface GLDrawer()

@property (strong, nonatomic) GLKView *glView;
@property (weak, nonatomic) EAGLContext *glContext;

@property (assign, nonatomic) FBXModel drawModel;
@property (strong, nonatomic) TextureGL *texture;

@property (assign, nonatomic) CGPoint lastPanLocation;

@end

@implementation GLDrawer {
    GLuint _programm;
    
    GLuint _vertextArray;

    GLuint _vertexBuffer;
    GLuint _indexBuffer;
    GLuint _normalBuffer;
    GLuint _indisesBuffer;
    
    GLKMatrix4 _mvpMatrix;
    GLKMatrix3 _normalMatrix;
    
    GLfloat _rotationX;
    GLfloat _rotationY;
    GLfloat _scale;
}

#pragma mark - Lifecycle

- (instancetype)initWithContext:(EAGLContext *)context withinView:(GLKView *)glView model:(FBXModel)model
{
    self = [super init];
    if (self) {
        
        NSAssert(glView, @"glView cant be nil");
        _glView = glView;
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panInView:)];
        [_glView addGestureRecognizer:pan];
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchInView:)];
        [_glView addGestureRecognizer:pinch];
        
        NSAssert(context, @"glContextCant be nil");
        _glContext = context;
        
        NSAssert(model.numberOfIndises && model.numberOfNormals && model.numberOfVertices && model.numberOfTextCoords, @"glModel cant be empty");
        _drawModel = model;
        
        _texture = [[TextureGL alloc] initFromImageNamed:@"cube_map_distribution"];
        
        [self setupGL];
        
        [_texture setupTexture];
        NSAssert(_texture.name, @"glTexture cant be prepared");
    }
    
    return self;
}

- (void)tearDown
{
    [EAGLContext setCurrentContext:self.glContext];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteBuffers(1, &_normalBuffer);
    glDeleteBuffers(1, &_indisesBuffer);

    glDeleteVertexArraysOES(1, &_vertextArray);
    
    if (_programm) {
        glDeleteProgram(_programm);
        _programm = 0;
    }
}

- (void)updateGLView
{
    float aspect = self.glView.frame.size.width / self.glView.frame.size.height;
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100);
//
//    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(.0f, .0f, -6.0f);
//    projectionMatrix = GLKMatrix4Multiply(projectionMatrix, baseModelViewMatrix);

////    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotationX, 0.0f, 1.0f, 0.0f);
////    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotationY, 1.0f, 0.0f, 0.0f);
    
//    GLKMatrix4 rotationObjMatrix = GLKMatrix4Identity;
//    rotationObjMatrix = GLKMatrix4Rotate(rotationObjMatrix, -M_PI_4, 1.0f, 0.0f, 0.0f);
//    rotationObjMatrix = GLKMatrix4Rotate(rotationObjMatrix, _rotationX, 1.0f, 1.0f, 1.0f);
//
//    _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(baseModelViewMatrix), NULL);
//    _mvpMatrix = GLKMatrix4Multiply(projectionMatrix, rotationObjMatrix);
    
//    //scale
//    //rotate
//    //translate
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.5f);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, projectionMatrix);

    GLfloat scale = 0.5 *_scale;
    GLKMatrix4 scaleMatrix = GLKMatrix4MakeScale(scale, scale, scale);

    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, -1, -5);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotationX, 0.0f, 1.0f, 0.0f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotationY, 1.0f, 0.0f, 0.0f);

    modelViewMatrix = GLKMatrix4Multiply(scaleMatrix, modelViewMatrix);
    
    _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    _mvpMatrix = modelViewMatrix;
}

- (void)draw
{
    glEnable(GL_DEPTH_TEST);
    glDepthMask(GL_TRUE);
    glDisable(GL_CULL_FACE);

    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glUseProgram(_programm);
    
    glBindVertexArrayOES(_vertextArray);
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _mvpMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMALS], 1, 0, _normalMatrix.m);
    
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _texture.name);
    
//    glDrawArrays(GL_TRIANGLES, 0, _drawModel.numberOfVertices);
    glDrawElements(GL_TRIANGLES, _drawModel.numberOfIndises, GL_UNSIGNED_INT, 0);
//    glDrawElements(GL_LINE_STRIP, _drawModel.numberOfIndises, GL_UNSIGNED_INT, 0);
}

#pragma mark - Setup ES GL 2

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.glContext];
    
    [self loadShaders];
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
    
    //textures
    glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * _drawModel.numberOfTextCoords, _drawModel.texCoords, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(attributes[ATTRIBUTES_TEXTURE_COORDINATE]);
    glVertexAttribPointer(attributes[ATTRIBUTES_TEXTURE_COORDINATE], 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 2, NULL);
    
    //indices order
    glGenBuffers(1, &_indisesBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indisesBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLuint) * _drawModel.numberOfIndises, _drawModel.indises, GL_STATIC_DRAW);
    
    //normals
    glGenBuffers(1, &_normalBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _normalBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * _drawModel.numberOfNormals, _drawModel.normals, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, NULL);

    glBindVertexArrayOES(0);
}

#pragma mark - Interactions

- (void)pinchInView:(UIPinchGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            break;
        }
        case UIGestureRecognizerStateChanged: {
            _scale = gesture.scale;
            break;
        }
        case UIGestureRecognizerStateEnded: {

            break;
        }
        default:
            break;
    }

}

- (void)panInView:(UIPanGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            self.lastPanLocation = [gesture locationInView:gesture.view];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            
            CGPoint neLocation = [gesture locationInView:gesture.view];
            
            CGFloat deltaX = neLocation.x - self.lastPanLocation.x;
            CGFloat deltaY = neLocation.y - self.lastPanLocation.y;

            _rotationX += deltaX / 100;
            _rotationY += deltaY / 100;
            
            self.lastPanLocation = neLocation;
            break;
        }
        case UIGestureRecognizerStateEnded: {
            
            break;
        }
        default:
            break;
    }
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _programm = glCreateProgram();
    
    // Create and compile vertex shader.
    NSBundle *frameWorkBundle = [NSBundle bundleForClass:[self class]];
    
    vertShaderPathname = [frameWorkBundle pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [frameWorkBundle pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_programm, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_programm, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_programm, GLKVertexAttribPosition, "a_position");
    glBindAttribLocation(_programm, GLKVertexAttribNormal, "normal");
    
    // Link program.
    if (![self linkProgram:_programm]) {
        NSLog(@"Failed to link program: %d", _programm);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_programm) {
            glDeleteProgram(_programm);
            _programm = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_programm, "u_modelViewProjectionMatrix");
    uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(_programm, "u_texture");
    uniforms[UNIFORM_NORMALS] = glGetUniformLocation(_programm, "normalMatrix");
    
    //get attributes
    attributes[ATTRIBUTES_TEXTURE_COORDINATE] = glGetAttribLocation(_programm, "a_texCoordIn");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_programm, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_programm, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

@end