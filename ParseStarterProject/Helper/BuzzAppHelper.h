//
//  BuzzAppHelper.h
//  BuzzApp
//
//  Created by Q Buzzwoo on 5/2/2557 BE.
//  Copyright (c) 2557 BUZZWOO!. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BuzzAppHelper : NSObject

+ (id)sharedInstance;
- (NSString *)getAnswerFilePathWithName:(NSString *)name;
- (NSData *)getJSONDataFromDictionary:(NSMutableDictionary *)dict;

@end
