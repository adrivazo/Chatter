//
//  ChatViewController.m
//  Chatter
//
//  Created by Josh Pearlstein on 11/3/15.
//  Copyright © 2015 SEAS. All rights reserved.
//

#import "ChatViewController.h"

#import "ParseDataManager.h"
#import <Parse/Parse.h>

@interface ChatViewController ()
@property(nonatomic) NSMutableArray *chatData;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;
@property(nonatomic) ParseDataManager *dataManager;
@end

@implementation ChatViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.dataManager = [ParseDataManager sharedManager];
  [self setupChatBubbles];
  self.chatData = [[NSMutableArray alloc]init];
    
    //NSString *digit = [[sender titlelabel] text];
    NSLog(@"launching...");
    /// TODO...SET THESE BASED ON [PFUser currentUser]
    self.senderId = @"test";
    self.senderDisplayName = @"test";
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        //update the senderID and displayName
        self.senderId = [[PFUser currentUser] username];
        self.senderDisplayName = [[PFUser currentUser] username];
        // do stuff with the user
        //take them to the chatter
        //[currentUser delete];
        //[PFUser logOut];
        [self loadData];
        NSLog(@"%@ logged in", [currentUser username]);
        
        
        NSTimer *timer = [NSTimer timerWithTimeInterval:5.0f
                                                 target:self
                                               selector:@selector(loadData)
                                               userInfo:nil
                                                repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];

        
        
        //NSLog(@"%@ deleted");
    } else {
        // show the signup or login screen
        //perform segue programatically
         [self performSegueWithIdentifier:@"signupSegue" sender:self];
    }
    
}

//add a timer to load data every so often...



- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  self.collectionView.collectionViewLayout.springinessEnabled = YES;
  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
  self.inputToolbar.contentView.leftBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date {
    
    NSLog(@"Sending message %@", text);
  // TODO - Handle the passing of data from this method to the
    
    NSNumber *latitude = @75;
    NSNumber *longitude = @75;
    
    
    [_dataManager postMessageText:text
                         senderId:senderId
                senderDisplayName:senderId
                             date:date
                        longitude:longitude latitude:latitude withCallback:^(BOOL success) {
        
        if (success){
            NSLog(@"Found friend!");
        }
        else{
            NSLog(@"Friend not found...");
        }
    }];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath {
 // TODO: Handle what happens when a user selects a cell. It should segue to the MapViewController and display the location
  // Of the message sent.
}

/* All data given to the chat library must be of form JSQMessage. Search for it in the project or
   cmd + click on it to check it out. Here's an example of a way to convert a PFObject to a JSQMessage*/
 
- (void)loadData {
  [self.dataManager loadMostRecentMessagesWithCallback:^(NSMutableArray *chats) {
    if(chats){
    for (PFObject *obj in chats) {
      JSQMessage *message = [[JSQMessage alloc] initWithSenderId:[obj objectForKey:@"chatUsername"]
                                               senderDisplayName:[obj objectForKey:@"chatUsername"]
                                                            date:obj.createdAt
                                                            text:[obj objectForKey:@"chatText"]];
      [self.chatData addObject:message];
    }
          [self.collectionView reloadData];
      }
  }];
}

#pragma mark - Don't Touch this stuff...Or do, I'm a line of code, not a cop.

- (void)setupChatBubbles {
  JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
  self.outgoingBubbleImageData =
      [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
  self.incomingBubbleImageData =
      [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
  return [self.chatData objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {

  JSQMessage *message = [self.chatData objectAtIndex:indexPath.item];
  
  if ([message.senderId isEqualToString:self.senderId]) {
    return self.outgoingBubbleImageData;
  }
  
  return self.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
  return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {

  if (indexPath.item % 3 == 0) {
    JSQMessage *message = [self.chatData objectAtIndex:indexPath.item];
    return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
  }
  
  return nil;
}


- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
  JSQMessage *message = [self.chatData objectAtIndex:indexPath.item];
  if ([message.senderId isEqualToString:self.senderId]) {
    return nil;
  }
  if (indexPath.item - 1 > 0) {
    JSQMessage *previousMessage = [self.chatData objectAtIndex:indexPath.item - 1];
    if ([[previousMessage senderId] isEqualToString:message.senderId]) {
      return nil;
    }
  }
  return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return [self.chatData count];
}


- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

  JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];

  JSQMessage *msg = [self.chatData objectAtIndex:indexPath.item];
  
  if (!msg.isMediaMessage) {
    
    if ([msg.senderId isEqualToString:self.senderId]) {
      cell.textView.textColor = [UIColor whiteColor];
    }
    else {
      cell.textView.textColor = [UIColor blackColor];
    }
    
    cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                          NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
  }
  
  return cell;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.item % 3 == 0) {
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
  }
  
  return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {

  JSQMessage *currentMessage = [self.chatData objectAtIndex:indexPath.item];
  if ([[currentMessage senderId] isEqualToString:self.senderId]) {
    return 0.0f;
  }
  
  if (indexPath.item - 1 > 0) {
    JSQMessage *previousMessage = [self.chatData objectAtIndex:indexPath.item - 1];
    if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
      return 0.0f;
    }
  }
  return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
  return 0.0f;
}

@end
