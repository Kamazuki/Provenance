//
//  PVGameServer.h
//  Provenance
//
//  Created by Kamazuki on 2017/11/15.
//  Copyright © 2017年 James Addyman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PVModelGameStatus.h"
#import "PVGameNotify.h"
#import "PVGameClient.h"

@class PVGameServer;

@protocol PVGameServerRoomDelegate <NSObject>

@end

@interface PVGameServer : NSObject<PVGameClientConnection>

@property(nonatomic, weak) id<PVGameNotifyDelegate> m_notifyDelegate;
@property(nonatomic, weak) id<PVGameServerRoomDelegate> m_roomDelegate;
-(void) start;


@end
