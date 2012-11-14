//
//  PropertyJSON.m
//  PropertyJSON
//
//  Created by Dawen Rie on 12-11-13.
//  Copyright (c) 2012年 G4Next. All rights reserved.
//

#import "PropertyJSON.h"
#import "JSONKit.h"
#import <objc/runtime.h>

static BOOL IsBasicSerailizeType(id value)
{
    return [value isKindOfClass:[NSString class]] ||
    [value isKindOfClass:[NSNumber class]] ||
    [value isKindOfClass:[NSNull class]];
}

static BOOL IsBasicDeserializeType(NSString *attribute) {
    return [attribute isEqualToString:@"NSString"] ||
    [attribute isEqualToString:@"NSNumber"] ||
    [attribute isEqualToString:@"NSArray"] ||
    [attribute isEqualToString:@"NSDictionary"];
}

static SEL MakeGetSelector(NSString *name, NSString *attribute){
    NSString *selectorName = name;
    for (NSString *part in [attribute componentsSeparatedByString:@","]) {
        if ([part hasPrefix:@"G"]) {
            selectorName = [part substringFromIndex:1];
            break;
        }
    }
    return NSSelectorFromString(selectorName);
}

static SEL MakeSetSelector(NSString *name, NSString *attribute) {
    NSString *selectorName = [NSString stringWithFormat:@"set%@%@:", [[name substringToIndex:1] uppercaseString], [name substringFromIndex:1]];
    for (NSString *part in [attribute componentsSeparatedByString:@","]) {
        if ([part hasPrefix:@"S"]) {
            selectorName = [part substringFromIndex:1];
            break;
        }
    }
    return NSSelectorFromString(selectorName);
}

static NSString *GetPropertyType(NSString *attribute){
    NSArray *attributeParts = [attribute componentsSeparatedByString:@","];
    if (attributeParts.count < 1) {
        return @"";
    }
    NSString *typePart = attributeParts[0];
    if (typePart.length < 4) {
        return @"";
    }
    NSRange subRange = NSMakeRange(3, typePart.length-4);
    return [typePart substringWithRange:subRange];
}

//static SEL get
@implementation NSObject (PropertyJSON)

-(void)reflection{
    Class clazz = [self class];
    u_int count;
    
    Ivar* ivars = class_copyIvarList(clazz, &count);
    NSMutableArray* ivarArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        const char* ivarName = ivar_getName(ivars[i]);
        const char* typeEncoding = ivar_getTypeEncoding(ivars[i]);
        NSString *ivarInfo = [NSString stringWithFormat:@"%s %s", ivarName, typeEncoding];
        [ivarArray addObject:ivarInfo];
    }
    free(ivars);
    
    objc_property_t* properties = class_copyPropertyList(clazz, &count);
    NSMutableArray* propertyArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        const char* name = property_getName(properties[i]);
        const char* attribute = property_getAttributes(properties[i]);
        NSString *propertyInfo = [NSString stringWithFormat:@"%s %s", name, attribute];
        [propertyArray addObject:propertyInfo];
    }
    free(properties);
    
    Method* methods = class_copyMethodList(clazz, &count);
    NSMutableArray* methodArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        SEL selector = method_getName(methods[i]);
        
        const char* methodName = sel_getName(selector);
        [methodArray addObject:[NSString  stringWithCString:methodName encoding:NSUTF8StringEncoding]];
    }
    free(methods);
    
    NSDictionary* classDump = [NSDictionary dictionaryWithObjectsAndKeys:
                               ivarArray, @"ivars",
                               propertyArray, @"properties",
                               methodArray, @"methods",
                               nil];
    
    NSLog(@"%@", classDump);
}

-(NSString *)propertiesDescription{
    return [[self propertiesObject] description];
}

-(NSString *)propertiesJSONString {
    return [[self propertiesObject] JSONString];
}

-(NSDictionary *)propertiesObject {
    NSMutableDictionary * dict = [[NSMutableDictionary  alloc] init];
    Class clazz = [self class];
    u_int count;
    
    objc_property_t* properties = class_copyPropertyList(clazz, &count);
    
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        const char* propertyAttribute = property_getAttributes(properties[i]);
        
        NSString *name=[NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
        NSString *attribute=[NSString stringWithCString:propertyAttribute encoding:NSUTF8StringEncoding];
        SEL selector = MakeGetSelector(name, attribute);
        if (selector && [self respondsToSelector:selector])
        {
            id value = [self performSelector:selector];
            if (!value) {
                value = [NSNull null];
            }
            NSString *valueType = GetPropertyType(attribute);
            if (valueType.length == 0) {
                NSLog(@"property:%@ not an object type", name);
                continue;
            }
            
            NSLog(@"set property:%@ of type:%@", name, valueType);
            if (IsBasicSerailizeType(value)) {
                [dict setValue:value forKey:name];
            }
            else{
                [dict setValue:[value propertiesObject] forKey:name];
            }
        }
        else {
            NSLog(@"object:%@ not response to SEL:%@ for property:%@, %@",
                  self, NSStringFromSelector(selector), name, attribute);
        }
    }
    free(properties);
    return  [dict autorelease];
}

-(void)setPropertiesFromJSON:(NSString *)json{
    id object = [json objectFromJSONString];
    if ([object isKindOfClass:[NSDictionary class]]) {
        [self setPropertiesFromDictionary:object];
    }
}

- (void)setPropertiesFromDictionary:(NSDictionary *)dict {
    Class clazz = [self class];
    u_int count;
    
    objc_property_t* properties = class_copyPropertyList(clazz, &count);
    
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        const char* propertyAttribute = property_getAttributes(properties[i]);
        
        NSString *name=[NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
        NSString *attribute=[NSString stringWithCString:propertyAttribute encoding:NSUTF8StringEncoding];
        id value = [dict objectForKey:name];
        if (value) {
            SEL selector = MakeSetSelector(name, attribute);
            if (selector && [self respondsToSelector:selector]) {
                NSString *valueType = GetPropertyType(attribute);
                if (valueType.length == 0) {
                    NSLog(@"property:%@ not an object type", name);
                    continue;
                }
                if (IsBasicDeserializeType(valueType)) {
                    // basic type set the value directly
                    NSLog(@"set basic property:%@ of type:%@", name, valueType);
                    [self performSelector:selector withObject:value];
                }
                else {
                    Class valueClass = NSClassFromString(valueType);
                    if (valueClass) {
                        // user define type, create it, and set it's properties
                        id valueObject = [[valueClass alloc] init];
                        if (valueObject) {
                            NSLog(@"set custom property:%@ type:%@", name, valueType);
                            [valueObject setPropertiesFromDictionary:value];
                            [self performSelector:selector withObject:valueObject];
                        }
                    }
                }
            }
        }
        else {
            NSLog(@"can't find JSON key for property:%@", name);
        }
    }
    free(properties);
}

@end

@implementation NSArray (PropertyJSON)
-(NSString *)propertiesJSONString{
    return [[self propertiesObject] JSONString];
}

-(NSArray *)propertiesObject{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:self.count];
    for (int i=0; i<self.count; i++) {
        id value = [self objectAtIndex:i];
        NSLog(@"add array type:%@", NSStringFromClass([value class]));
        if (IsBasicSerailizeType(value)) {
            [array addObject:value];
        }
        else{
            [array addObject:[value propertiesObject]];
        }
    }
    return [array autorelease];
}

@end

@implementation NSDictionary (PropertyJSON)
-(NSString *)propertiesJSONString{
    return [[self propertiesObject] JSONString];
}

-(NSDictionary *)propertiesObject{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:self.count];
    for (id key in [self allKeys]) {
        id value = [self objectForKey:key];
        if (IsBasicSerailizeType(value)) {
            [dict setObject:value forKey:key];
        }
        else {
            [dict setObject:[value propertiesObject] forKey:key];
        }
    }
    return [dict autorelease];
}
@end
