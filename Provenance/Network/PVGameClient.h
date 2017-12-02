//
//  PVGameClient.h
//  Provenance
//
//  Created by Kamazuki on 2017/11/15.
//  Copyright © 2017年 James Addyman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PVModelGameStatus.h"
#import "PVModelGameRoomAction.h"
#import "PVModelGameRoomInfo.h"
#import "PVModelStartGame.h"

@protocol PVGameClient;

@protocol PVGameClientDelegate <NSObject>

@end

@protocol PVGameClientRoomListDelegate <NSObject>

-(void) onPVGameClient:(id<PVGameClient>) client serviceUpdateWithArray:(NSArray*) tempArray;
-(void) onPVGameClient:(id<PVGameClient>) client didJoinServerWithName:(NSString*) tempName;

@end

@protocol PVGameClientRoomDelegate <NSObject>

-(void) onPVGameClient:(id<PVGameClient>) client didUpdateWithGameRoomInfo:(PVModelGameRoomInfo*) tempInfo;
-(void) onPVGameClient:(id<PVGameClient>)client didStartGame:(PVModelStartGame*) tempInfo;

@end

@protocol PVGameClientConnection <NSObject>

#pragma mark - game connection
-(void) sendGameStatus:(unsigned long long)tempStatus;
-(void) sendGameRoomAction:(PVModelGameRoomActionType) tempAction;

@end

@protocol PVGameClient <PVGameClientConnection>

#pragma mark - find service
-(void) setDelegate:(id<PVGameClientDelegate>) tempDelegate;
-(void) setRoomDelegate:(id<PVGameClientRoomDelegate>) tempDelegate;
-(void) setRoomListDelegate:(id<PVGameClientRoomListDelegate>) tempDelegate;
-(void) connectToService:(NSNetService*) tempService;
-(void) start;

#pragma mark - game core
-(BOOL) isGameStatusOk;
-(BOOL) shouldSkipFrame;
-(unsigned long long) nextGameStatus;

@end
