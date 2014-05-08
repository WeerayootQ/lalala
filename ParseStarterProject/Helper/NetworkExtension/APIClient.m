//
//  APIClient.m
//  ParseStarterProject
//
//  Created by Q on 4/20/14.
//
//

#import "APIClient.h"

@implementation APIClient

static NSString *const APIBaseURLString = @"https://api.forecast.io/forecast/";
static NSString *const APIKEY = @"75630817a4c5d125ce0c851a6644f24f";
static APIClient *__sharedInstance = nil;

+ (id)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[APIClient alloc] initWithBaseURL:[NSURL URLWithString:APIBaseURLString]];
    });
    
    return __sharedInstance;
}

- (void)getForecastWithDict:(NSDictionary *)dictionary
                  withBlock:(void (^)(NSDictionary *forecastDict, BOOL succeeded, NSError *error))block
{
    NSString *URLString = [NSString stringWithFormat:@"https://api.forecast.io/forecast/%@/%@,%@", APIKEY, dictionary[@"LATITUDE"], dictionary[@"LONGITUDE"]];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:URLString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"Response : %@", responseObject[@"currently"]);
        
        if (block)
        {
            block([NSDictionary dictionaryWithDictionary:(NSDictionary *)responseObject[@"currently"]], YES, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Failed : %@", [error localizedDescription]);
        
        if (block)
        {
            block([NSDictionary dictionary], NO, error);
        }
    }];
}

@end
