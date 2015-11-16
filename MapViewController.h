//
//  MapViewController.h
//  Chatter
//
//  Created by Josh Pearlstein on 11/3/15.
//  Copyright © 2015 SEAS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapViewController : UIViewController
@property (nonatomic, weak) NSNumber *latitude;
@property (nonatomic, weak) NSNumber *longitude;

-(void) updatePin;

@end
