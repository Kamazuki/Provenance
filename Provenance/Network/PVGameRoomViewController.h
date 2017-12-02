//
//  PVGameRoomViewController.h
//  Provenance
//
//  Created by Kamazuki on 2017/11/15.
//  Copyright © 2017年 James Addyman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PVGame.h"
#import "PVGameClient.h"

@protocol PVGameRoomViewControllerDelegate <NSObject>

-(void) onPVGameRoomViewControllerStartGame:(PVGame*) tempGame info:(PVModelStartGame*) tempInfo;

@end

@interface PVGameRoomViewController : UIViewController

@property(nonatomic, weak) id<PVGameRoomViewControllerDelegate> m_delegate;
-(id) initWithGame:(PVGame*) tempGame client:(id<PVGameClient>) tempClient;

@end
