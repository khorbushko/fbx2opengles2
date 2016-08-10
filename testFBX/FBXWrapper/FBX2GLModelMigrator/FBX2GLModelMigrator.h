//
//  FBX2GLModelMigrator.h
//  testFBX
//
//  Created by Kirill Gorbushko on 06.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBX2GLModel.h"

@interface FBX2GLModelMigrator : NSObject

@property (strong, nonatomic) NSMutableArray <FBX2GLModel *> *avaliableModels;

- (instancetype)initWithModelNamed:(NSString *)fileNamed;

@end
