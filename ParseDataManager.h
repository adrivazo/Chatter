//
//  ParseDataManager.h
//  Chatter
//
//  Created by Josh Pearlstein on 11/3/15.
//  Copyright © 2015 SEAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParseDataManager : NSObject

+ (ParseDataManager *)sharedManager;

- (BOOL)isUserLoggedIn;

- (void)loadMostRecentMessagesWithCallback:(void (^)(NSMutableArray *))callback;

- (void) signupUser: (NSString *)username : (NSString *) password : (NSString *) email;

// TODO: Handle posting messages with Longitude and Latitude

-(void) postMessageText:(NSString *)text
               senderId:(NSString *)senderId
      senderDisplayName:(NSString *)senderDisplayName
                   date:(NSDate *)date
              longitude: (NSNumber*) longitude
               latitude: (NSNumber *) latitude withCallback: (void(^)(BOOL success)) callback;

// TODO: Handle User signup

@end
