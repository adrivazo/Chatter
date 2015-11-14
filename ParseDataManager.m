//
//  ParseDataManager.m
//  Chatter
//
//  Created by Josh Pearlstein on 11/3/15.
//  Copyright © 2015 SEAS. All rights reserved.
//

#import "ParseDataManager.h"

#import <Parse/Parse.h>

@implementation ParseDataManager
NSMutableArray *lastRetrievedChats;
NSDate *lastRetrievedDate; // date of the last chat retrieved

+ (ParseDataManager *)sharedManager {
  static ParseDataManager *obj;
  static dispatch_once_t token;
  dispatch_once(&token, ^{
    obj = [[ParseDataManager alloc] init];
    /// TODO: Any other setup you'd like to do.
  });
  return obj;
}

- (BOOL)isUserLoggedIn {
  return [[PFUser currentUser] isAuthenticated];
}

- (void) signupUser: (NSString *)username : (NSString *) password : (NSString *) email {
    
    
    PFUser *user = [PFUser user];
    user.username = username;//@"my name";
    user.password = password;//@"my pass";
    user.email =email;// @"email@example.com";
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Logged in!");
            // Hooray! Let them use the app now.
        } else {   NSString *errorString = [error userInfo][@"error"];   // Show the errorString somewhere and let the user try again.
            
            NSLog(@"error %@",errorString);
        }
    }];
}


- (void)loadMostRecentMessagesWithCallback:(void (^)(NSMutableArray *))callback {
// TODO: Load data here.
    PFQuery *query = [PFQuery queryWithClassName:@"Chats"];
    if(lastRetrievedDate)//if the last retrieved date is not null
        {
            [query whereKey:@"createdAt" greaterThan:lastRetrievedDate];
        }
    
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (!error) {
        NSMutableArray * mutableObjects = [objects mutableCopy];
        if([mutableObjects isEqualToArray:lastRetrievedChats]){
        // they are the same or there are no updates, no need to update!
            callback(lastRetrievedChats);// can you do this?
        }
        
        if(mutableObjects.count==0){//could or w above
            callback(nil);
        }
        else{
            PFObject *last = [mutableObjects lastObject];
            lastRetrievedDate = last.createdAt;
            lastRetrievedChats = mutableObjects;
            callback(mutableObjects);
        }
    }
  }];
}

/*
 - (void)loadData {
 PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
 [query orderByDescending:@"createdAt"];
 [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
 self.messages = [objects mutableCopy];
 [self.tableView reloadData];
 
 }];
 }
 */

-(void) postMessageText:(NSString *)text
               senderId:(NSString *)senderId
      senderDisplayName:(NSString *)senderDisplayName
                   date:(NSDate *)date
                   longitude: (NSNumber*) longitude
               latitude: (NSNumber *) latitude withCallback: (void(^)(BOOL success)) callback {
    
        PFObject *chatMessage = [PFObject objectWithClassName:@"Chats"];
        [chatMessage setObject:text forKey:@"chatText"];
        [chatMessage setObject:senderId forKey:@"chatUsername"];
        [chatMessage setObject:senderId forKey:@"senderId"];
        [chatMessage setObject:text forKey:@"chatText"];
        [chatMessage setObject:latitude forKey:@"chatLatitude"];
        [chatMessage setObject:longitude forKey:@"chatLongitude"];

    [chatMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error){
        if (!succeeded) {
            NSLog(@"%@",[error localizedDescription]);
            callback(NO);

        } else {
             NSLog(@"%@",[error localizedDescription]);
            callback(YES);
        }
    }];
}
@end
