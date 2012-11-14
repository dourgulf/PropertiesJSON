//
//  TMDataModel.m
//  Demo
//
//  Created by Dawen Rie on 12-11-14.
//  Copyright (c) 2012年 G4Next. All rights reserved.
//

#import "TMDataModel.h"

@implementation TMDataModel1
- (void)dealloc
{
    NSLog(@"%@ delloc", NSStringFromClass([self class]));
    [_propNumber release];
    [_notSupported release];
    [super dealloc];
}

-(NSString *)propReadOnly {
    return @"read only string";
}

@end

@implementation TMDataModel

- (void)dealloc
{
    NSLog(@"%@ delloc", NSStringFromClass([self class]));
    [_propArray release];
    [_propDictionary release];
    [_propData1 release];
    [super dealloc];
}

@end
