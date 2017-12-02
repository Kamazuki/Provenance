//
//  PVGameMultiplayerViewController.h
//  Provenance
//
//  Created by Kamazuki on 2017/11/15.
//  Copyright © 2017年 James Addyman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PVGame.h"
#import "PVGameClient.h"
#import "PVGameRoomViewController.h"

@protocol PVGameRoomListViewControllerDelegate <NSObject>

-(void) onPVGameRoomListViewControllerStartGame:(PVGame*) tempGame;

@end

@interface PVGameRoomListViewController : UIViewController

@property(nonatomic, weak) id<PVGameRoomListViewControllerDelegate, PVGameRoomViewControllerDelegate> m_delegate;
-(id) initWithGame:(PVGame*) tempGame client:(id<PVGameClient>) tempClient;

@end
