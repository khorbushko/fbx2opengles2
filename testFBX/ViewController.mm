//
//  ViewController.m
//  testFBX
//
//  Created by Kirill Gorbushko on 06.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

#import "ViewController.h"

#import "FBX2GLModelMigrator.h"
#import "FBX2GLModel.h"
#import "FBX2GLDrawer.h"

@interface ViewController ()

@property (strong, nonatomic) EAGLContext *context;

@property (strong, nonatomic) FBX2GLModelMigrator *migrator;
@property (strong, nonatomic) FBX2GLDrawer *drawer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.migrator = [[FBX2GLModelMigrator alloc]
//                     initWithModelNamed:@"TreeSet3.fbx"];
//                     initWithModelNamed:@"Mine.fbx"];
//                     initWithModelNamed:@"Mine3.fbx"];
//                     initWithModelNamed:@"basketball.fbx"];
//                     initWithModelNamed:@"cylinderProjection.fbx"];
//                     initWithModelNamed:@"semtex.fbx"];
//                     initWithModelNamed:@"CubiModel.fbx"];
                     initWithModelNamed:@"Low Poly Chainsaw_blend_Shape_Keys_Animation2.fbx"]; //incorrect texture?
//                     initWithModelNamed:@"bench.FBX"];
//                     initWithModelNamed:@"Low Poly Chainsaw_blend.fbx"];//incorrect
//                     initWithModelNamed:@"Robo8.fbx"];

    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!self.context) {
        NSLog(@"No Context");
    }
    
    self.preferredFramesPerSecond = 60;
    
    GLKView *view = ((GLKView *)self.view);
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
        
    self.drawer = [[FBX2GLDrawer alloc] initWithContext:self.context withinView:view models:self.migrator.avaliableModels];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        [self.drawer tearDown];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
}

- (void)dealloc
{
    [self.drawer tearDown];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)update
{
    [self.drawer updateGLView];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [self.drawer draw];
}

@end
