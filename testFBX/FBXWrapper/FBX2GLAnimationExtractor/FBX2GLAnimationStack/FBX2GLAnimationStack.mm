//
//  FBX2GLAnimationStack.m
//  testFBX
//
//  Created by Kirill Gorbushko on 12.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

#import "FBX2GLAnimationStack.h"
#import "FBX2GlAnimationLayer.h"

@implementation FBX2GLAnimationStack

#pragma mark - LifeCYcle

- (instancetype)initWithFbxAnimStack:(FbxAnimStack*)lAnimStack rootNode:(FbxNode *)pNode
{
    self = [super init];
    if (self) {
        
        NSString *name = [NSString stringWithUTF8String:lAnimStack->GetName()];
        self.name = name;
        self.layersCount = lAnimStack->GetMemberCount<FbxAnimLayer>();
        self.layers = [FBX2GlAnimationLayer parseLayersFromStack:lAnimStack rootNode:pNode];
    }
    return self;
}

#pragma mark - Public

+ (NSArray <FBX2GLAnimationStack *> *)animationStacksFromScene:(FbxScene *)pScene
{
    NSMutableArray *stacks = [NSMutableArray array];
    for (int i = 0; i < pScene->GetSrcObjectCount<FbxAnimStack>(); i++) {
        FbxAnimStack* lAnimStack = pScene->GetSrcObject<FbxAnimStack>(i);

        FBX2GLAnimationStack *stack = [[FBX2GLAnimationStack alloc] initWithFbxAnimStack:lAnimStack
                                                                                rootNode:pScene->GetRootNode()];
        stack.index = i;
        
        [stacks addObject:stack];
    }
    
    return stacks;
}

@end
