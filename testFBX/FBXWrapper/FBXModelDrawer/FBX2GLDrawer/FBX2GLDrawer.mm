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
#import "FBX2GLAnimationExtractor.h"
#import "FBX2GLAnimationPose.h"
#import "FBX2GLAnimationStack.h"
#import "FBX2GlAnimationLayer.h"
#import "FBX2GlAnimationCurves.h"
#import "FBX2GLAnimationCurveItem.h"
#import "FBX2GLAnimationPoseMatrix.h"

@interface FBX2GLDrawer()

@property (strong, nonatomic) GLKView *glView;
@property (weak, nonatomic) EAGLContext *glContext;

@property (assign, nonatomic) CGPoint lastPanLocation;
@property (assign, nonatomic) CGPoint lastDoublePanLocation;
@property (assign, nonatomic) CGFloat prevScale;

@property (strong, nonatomic) NSMutableArray <FBX2GLMeshDrawer *> *glMeshDrawers;
@property (strong, nonatomic) FBX2GLAnimationExtractor *animator;

@end

@implementation FBX2GLDrawer
{
    GLKMatrix3 _normalMatrix;
    
    GLfloat _rotationX;
    GLfloat _rotationY;
    GLfloat _scale;
    GLfloat _positionY;
    GLfloat _positionX;
}

static GLint animationFrameCounter = 0;

#pragma mark - Lifecycle

- (instancetype)initWithContext:(EAGLContext *)context withinView:(GLKView *)glView models:(NSArray <FBX2GLModel *> *)models textureNamed:(NSString *)textureNamed
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
            FBX2GLMeshDrawer *drawer = [[FBX2GLMeshDrawer alloc] initWithMeshModel:meshModel textureName:textureNamed];
            [_glMeshDrawers addObject:drawer];
        }
        
        [self applyDefaultParameters];
    }
    
    return self;
}

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
            FBX2GLMeshDrawer *drawer = [[FBX2GLMeshDrawer alloc] initWithMeshModel:meshModel textureName:@"1.png"];
            [_glMeshDrawers addObject:drawer];
        }
        [self applyDefaultParameters];
    }
    
    return self;
}

- (void)applyDefaultParameters
{
    _scale = 1;
    _rotationX = 1;
    _rotationY = 1;
    _positionY = 0;
    _positionX = 0;
    
    _drawMode = GL_TRIANGLES;
}

- (void)attachAnimatorObject:(FBX2GLAnimationExtractor *)animator
{
    _animator = animator;
    animationFrameCounter = 0;
}

- (void)setAnimate:(GLboolean)animate
{
    _animate = animate;
    animationFrameCounter = 0;
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
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.01f, 100);
    //scale
    //rotate
    //translate
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.5f);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, projectionMatrix);

    GLfloat scale = 0.5 *_scale;
    GLKMatrix4 scaleMatrix = GLKMatrix4MakeScale(scale, scale, scale);

    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, _positionX, _positionY, -5);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotationX, 0.0f, 1.0f, 0.0f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotationY, 1.0f, 0.0f, 0.0f);

    modelViewMatrix = GLKMatrix4Multiply(scaleMatrix, modelViewMatrix);
    
    for (FBX2GLMeshDrawer *meshGlDrawer in _glMeshDrawers) {
        if (_animate && _animator) {
            if (![self performAnimationForObject:meshGlDrawer withMatrix:modelViewMatrix]) {
                [meshGlDrawer performMeshUpdateWithBaseMVPMatrix:modelViewMatrix];
            }
        } else {
            [meshGlDrawer performMeshUpdateWithBaseMVPMatrix:modelViewMatrix];
        }
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
        meshGlDrawer.drawElementsMode = self.drawMode;
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

#pragma mark - GLAnimations

- (BOOL)performAnimationForObject:(FBX2GLMeshDrawer *)candidate withMatrix:(GLKMatrix4)mvpMatrix
{
    GLfloat koef = _animator.timeModeFPS / self.expectedFramerate;
    GLint animTransformName = (int)(animationFrameCounter * koef);
    
    GLuint selectedStack = 0;
    GLuint selectedLayer = 0;
    
    //        for (int i = 0; i < _animator.animationStacks.count; i++) { //basically 1, if more - few animations?
    FBX2GLAnimationStack *currentStack = _animator.animationStacks[selectedStack];
    //            for (int j = 0; j < currentStack.layers.count; j++) { //basically 1 if more - blended anim
    FBX2GlAnimationLayer *currentlayer = currentStack.layers[selectedLayer];
    if ([currentlayer.animationList containsObject:candidate.modelName]) {
        //                    NSInteger indexOfMeshCurve = layer;//[currentlayer.animationList indexOfObject:candidate.modelName];
        
        GLKMatrix4 animMat = GLKMatrix4Identity;
        for (int k = 0; k < currentlayer.curves.count; k++) {
            FBX2GlAnimationCurves *currentCurves = currentlayer.curves[k];
            GLKMatrix4 matItem = [currentCurves curveTransformForIndex:animTransformName];
            if (isIdentityMatric(matItem)) {
                continue;
            }
            //                            [candidate performMeshUpdateWithBaseMVPMatrix:mvpMatrix animMatrix:matItem];
            
            animMat = GLKMatrix4Multiply(animMat, matItem);
        }
        [candidate performMeshUpdateWithBaseMVPMatrix:mvpMatrix animMatrix:animMat];
        
    }
    //            }
    //        }
    animationFrameCounter++;
    if ( (GLfloat) animationFrameCounter * koef >= _animator.frameDuration) {
        animationFrameCounter = 0;
    }
    //    }
    
    return YES;
}

#pragma mark - Utils

GLboolean isIdentityMatric(GLKMatrix4 matrixToCompare) {
    GLboolean isIdentty = YES;
    GLKMatrix4 identity = GLKMatrix4Identity;
    CGFloat *srcPointer = (CGFloat *)&identity;
    GLfloat *destPointer = matrixToCompare.m;
    for (int i = 0; i < 16; i++) {
        if (destPointer[i] != srcPointer[i]) {
            isIdentty = NO;
            break;
        }
    }
    return isIdentty;
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