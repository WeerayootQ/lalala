//
//  APIClient.h
//  ParseStarterProject
//
//  Created by Q on 4/20/14.
//
//

#import "AFHTTPSessionManager.h"

@interface APIClient : AFHTTPSessionManager
+ (id)sharedInstance;
- (void)getForecastWithDict:(NSDictionary *)dictionary
                  withBlock:(void (^)(NSDictionary *forecastDict, BOOL succeeded, NSError *error))block;
@end
