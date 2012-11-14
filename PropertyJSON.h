//
//  PropertyJSON.h
//  PropertyJSON
//
//  Created by Dawen Rie on 12-11-13.
//  Copyright (c) 2012年 G4Next. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PropertyJSON)
- (NSString *)propertiesDescription;
- (NSString *)propertiesJSONString;
- (void)setPropertiesFromJSON:(NSString *)json;
- (void)setPropertiesFromDictionary:(NSDictionary *)dict;
@end

@interface NSArray (PropertyJSON)
- (NSString *)propertiesJSONString;
@end

@interface NSDictionary (PropertyJSON)
- (NSString *)propertiesJSONString;
@end