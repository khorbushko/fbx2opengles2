//
//  FBX2GLModelMigrator.h
//  testFBX
//
//  Created by Kirill Gorbushko on 06.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectStucture.h"

@interface FBX2GLModelMigrator : NSObject

@property (assign, nonatomic) FBXModel model;

- (instancetype)initWithModelNamed:(NSString *)fileNamed;
- (void)printObject;

@end
