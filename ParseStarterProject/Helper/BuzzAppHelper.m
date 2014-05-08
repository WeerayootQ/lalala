//
//  BuzzAppHelper.m
//  BuzzApp
//
//  Created by Q Buzzwoo on 5/2/2557 BE.
//  Copyright (c) 2557 BUZZWOO!. All rights reserved.
//

#import "BuzzAppHelper.h"

@implementation BuzzAppHelper

static BuzzAppHelper *__sharedInstance = nil;

+ (id)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[BuzzAppHelper alloc] init];
    });
    
    return __sharedInstance;
}

- (NSString *)getAnswerFilePathWithName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/UserAvatar"];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folde
    }
    
    NSString *stringPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"UserAvatar/%@.png", name]];
    return stringPath;
}

- (NSData *)getJSONDataFromDictionary:(NSMutableDictionary *)dict
{
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&err];
    
    if (jsonData)
    {
        NSString *myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"JSON : %@", myString);
    }
    else
    {
        NSLog(@"ERROR : %@", [err localizedDescription]);
    }
    
    return jsonData;
}

@end
