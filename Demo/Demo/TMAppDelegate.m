//
//  TMAppDelegate.m
//  Demo
//
//  Created by Dawen Rie on 12-11-14.
//  Copyright (c) 2012年 G4Next. All rights reserved.
//

#import "TMAppDelegate.h"
#import "TMDataModel.h"

#import "PropertyJSON.h"

@implementation TMAppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    TMDataModel1 *dm1 =[TMDataModel1 new];
    dm1.propNumber = @999;
    dm1.notSupported = [NSDate date];   // no output in JSON string
    dm1.onlyObjectSupported = 2;        // on output in JSON string
    TMDataModel *model = [TMDataModel new];
    model.propArray = [NSArray arrayWithObjects:
                     @"begin array",
                     @123,
                     dm1,
                     dm1,
                     @"end of array",
                     nil];
    
    model.propDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"begin dictionary", @"begin",
                          dm1, @"dm1_1",
                          dm1, @"dm1_2",
                          @888, @"NUM",
                          @"end dictionary", @"end",
                          nil];
    model.propData1 = dm1;
    NSLog(@"model property structure:\n%@", [model propertiesDescription]);
    NSString *json = [model propertiesJSONString];
    NSLog(@"JSON of model:\n%@", json);
    
    TMDataModel *model2 = [TMDataModel new];
    [model2 setPropertiesFromJSON:json];
    NSLog(@"model property of deserialized\n%@", [model2 propertiesDescription]);
    
    // make the array object deserialized to object property
    TMDataModel1 *dm2 = [TMDataModel1 new];
    [dm2 setPropertiesFromDictionary:model2.propArray[2]];
    NSLog(@"model property of array[2]\n%@", [dm2 propertiesDescription]);
    [dm1 release];
    [model release];
    [model2 release];
}

@end
