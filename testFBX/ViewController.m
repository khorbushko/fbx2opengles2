//
//  ViewController.m
//  testFBX
//
//  Created by Kirill Gorbushko on 06.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

#import "ViewController.h"

#import "FBX2GLModelMigrator.h"
#import "GLDrawer.h"


@interface ViewController ()

@property (strong, nonatomic) EAGLContext *context;

@property (strong, nonatomic) FBX2GLModelMigrator *migrator;
@property (strong, nonatomic) GLDrawer *drawer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.migrator = [[FBX2GLModelMigrator alloc]
                     initWithModelNamed:@"TreeSet3.fbx"];
//                     initWithModelNamed:@"Mine.fbx"];
//                     initWithModelNamed:@"Mine3.fbx"];
//                     initWithModelNamed:@"basketball.fbx"];
//                     initWithModelNamed:@"cylinderProjection.fbx"];
    
    
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!self.context) {
        NSLog(@"No Context");
    }
    
    GLKView *view = ((GLKView *)self.view);
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    self.drawer = [[GLDrawer alloc] initWithContext:self.context withinView:view model:self.migrator.model];
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
