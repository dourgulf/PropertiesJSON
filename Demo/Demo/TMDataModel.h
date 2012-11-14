//
//  TMDataModel.h
//  Demo
//
//  Created by Dawen Rie on 12-11-14.
//  Copyright (c) 2012年 G4Next. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMDataModel1 : NSObject
@property (nonatomic) CGFloat onlyObjectSupported;
@property (nonatomic, readonly) NSString *propReadOnly;
@property (nonatomic, retain) NSNumber *propNumber;
@property (nonatomic, retain) NSDate *notSupported;
@end

@interface TMDataModel : NSObject
@property (nonatomic, retain) TMDataModel1 *propData1;
@property (nonatomic, retain) NSArray *propArray;
@property (nonatomic, retain) NSDictionary *propDictionary;
@end