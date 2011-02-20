//
//  Global.m
//  NinetyMinutes
//
//  Created by Nebil on 12/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import "Global.h"

//#define LOCALHOST 1

#ifdef LOCALHOST
NSString * const kAPIRootURL = @"http://localhost:8082/api";
#else
NSString * const kAPIRootURL = @"http://90minutesin.appspot.com/api";
#endif

NSString * const kFacebookAppId = @"152318558158118";
