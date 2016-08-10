//
//  GLDrawer.m
//  testFBX
//
//  Created by Kirill Gorbushko on 07.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

#import <OpenGLES/ES2/glext.h>
#import "FBX2GLDrawer.h"
#import "FBX2GLMeshDrawer.h"

@interface FBX2GLDrawer()

@property (strong, nonatomic) GLKView *glView;
@property (weak, nonatomic) EAGLContext *glContext;

@property (assign, nonatomic) CGPoint lastPanLocation;
@property (assign, nonatomic) CGPoint lastDoublePanLocation;
@property (assign, nonatomic) CGFloat prevScale;

@property (strong, nonatomic) NSMutableArray <FBX2GLMeshDrawer *> *glMeshDrawers;

@end

@implementation FBX2GLDrawer
{
    GLKMatrix3 _normalMatrix;
    
    GLfloat _rotationX;
    GLfloat _rotationY;
    GLfloat _scale;
    GLfloat _positionY;
    GLfloat _positionX;
    
    GLuint uniforms[UNIFORM_COUNT];
    GLuint attributes[ATTRIBUTES_COUNT];
}

#pragma mark - Lifecycle

- (instancetype)initWithContext:(EAGLContext *)context withinView:(GLKView *)glView models:(NSArray <FBX2GLModel *> *)models
{
    self = [super init];
    if (self) {
        NSAssert(glView, @"glView cant be nil");
        _glView = glView;
        [self setupViewInteractions];
        
        NSAssert(context, @"glContextCant be nil");
        _glContext = context;
        
        _glMeshDrawers = [NSMutableArray array];
        
        [EAGLContext setCurrentContext:self.glContext];
        for (FBX2GLModel *meshModel in models) {
            FBX2GLMeshDrawer *drawer = [[FBX2GLMeshDrawer alloc] initWithMeshModel:meshModel textureName:@"semtex texture.png"];
            [_glMeshDrawers addObject:drawer];
        }
        
        _scale = 1;
        _rotationX = 1;
        _rotationY = 1;
        _positionY = 0;
        _positionX = 0;
    }
    
    return self;
}

- (void)tearDown
{
    [EAGLContext setCurrentContext:self.glContext];
    
    for (FBX2GLMeshDrawer *meshGlDrawer in _glMeshDrawers) {
        [meshGlDrawer tearDownGLDrawer];
    }
}

- (void)updateGLView
{
    float aspect = self.glView.frame.size.width / self.glView.frame.size.height;
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100);
//    //scale
//    //rotate
//    //translate
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.5f);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, projectionMatrix);

    GLfloat scale = 0.5 *_scale;
    GLKMatrix4 scaleMatrix = GLKMatrix4MakeScale(scale, scale, scale);

    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, _positionX, _positionY, -5);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotationX, 0.0f, 1.0f, 0.0f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotationY, 1.0f, 0.0f, 0.0f);

    modelViewMatrix = GLKMatrix4Multiply(scaleMatrix, modelViewMatrix);
    
//    _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
//    _mvpMatrix = modelViewMatrix;

    for (FBX2GLMeshDrawer *meshGlDrawer in _glMeshDrawers) {
        [meshGlDrawer performMeshUpdateWithBaseMVPMatrix:modelViewMatrix];
    }
}

- (void)draw
{
    glEnable(GL_DEPTH_TEST);
    glDepthMask(GL_TRUE);
    glDisable(GL_CULL_FACE);

    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    for (FBX2GLMeshDrawer *meshGlDrawer in _glMeshDrawers) {
        [meshGlDrawer pefromMeshDraw];
    }
}


#pragma mark - Private

- (void)setupViewInteractions
{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panInView:)];
    [_glView addGestureRecognizer:pan];
    
    UIPanGestureRecognizer *doublePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(doublePanInView:)];
    doublePan.minimumNumberOfTouches = 2;
    [_glView addGestureRecognizer:doublePan];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchInView:)];
    [_glView addGestureRecognizer:pinch];
}

#pragma mark - Interactions

- (void)pinchInView:(UIPinchGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            self.prevScale = gesture.scale;
            break;
        }

        case UIGestureRecognizerStateChanged: {
            float delta = gesture.scale - self.prevScale;
            _scale += delta;
            self.prevScale = gesture.scale;
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
        default:
            break;
    }
}

- (void)doublePanInView:(UIPanGestureRecognizer *)doublePan
{
    switch (doublePan.state) {
        case UIGestureRecognizerStateBegan: {
            self.lastDoublePanLocation = [doublePan locationInView:doublePan.view];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint neLocation = [doublePan locationInView:doublePan.view];
            CGFloat deltaY = self.lastDoublePanLocation.y - neLocation.y;
            CGFloat deltaX = self.lastDoublePanLocation.x - neLocation.x;
            
            _positionY += deltaY / 100;
            _positionX += deltaX / 100;

            self.lastDoublePanLocation = neLocation;
            break;
        }
        default:
            break;
    }
}

@end