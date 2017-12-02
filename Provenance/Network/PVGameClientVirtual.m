//
//  PVGameClientVirtual.m
//  Provenance
//
//  Created by Kamazuki on 2017/11/17.
//  Copyright © 2017年 James Addyman. All rights reserved.
//

#import "PVGameClientVirtual.h"
#import "PVGameServer.h"
#import "PVScopeLock.h"

@interface PVGameClientVirtual ()
<
    PVGameServerRoomDelegate,
    PVGameNotifyDelegate
>

@property(nonatomic, weak) id<PVGameClientDelegate> m_delegate;
@property(nonatomic, weak) id<PVGameClientRoomDelegate> m_roomDelegate;

@property(nonatomic, strong) PVGameServer* m_server;

//====房间数据====//
@property(nonatomic, strong) NSMutableArray* m_gameStatus;
@property(nonatomic, strong) NSRecursiveLock* m_lock;
//^^^^房间数据^^^^//

@end

@implementation PVGameClientVirtual

-(id) init
{
    self = [super init];
    if (self)
    {
        self.m_server = [[PVGameServer alloc] init];
        self.m_server.m_notifyDelegate = self;
        self.m_server.m_roomDelegate = self;
        
        self.m_gameStatus = [NSMutableArray array];
        self.m_lock = [[NSRecursiveLock alloc] init];
    }
    return self;
}

-(void) setDelegate:(id<PVGameClientDelegate>) tempDelegate
{
    self.m_delegate = tempDelegate;
}

-(void) setRoomDelegate:(id<PVGameClientRoomDelegate>) tempDelegate
{
    self.m_roomDelegate = tempDelegate;
}

-(void) setRoomListDelegate:(id<PVGameClientRoomListDelegate>)tempDelegate
{

}

-(void) connectToService:(NSNetService*) tempService
{
    //进入房间
}

-(void) start
{
    // start server
    [self.m_server start];
}

-(BOOL) isGameStatusOk
{
    if (self.m_gameStatus.count == 0)
    {
        return NO;
    }
    
    return YES;
}

-(BOOL) shouldSkipFrame
{
    return NO;
}

-(unsigned long long) nextGameStatus
{
    if (self.m_gameStatus.count == 0)
    {
        return 0;
    }
    
    PVModelGameStatus* tempStatus = [self.m_gameStatus objectAtIndex:self.m_gameStatus.count - 1];
    
    return tempStatus.m_controllerStatus;
}

#pragma mark - PVGameClientConnection
-(void) sendGameStatus:(unsigned long long)tempStatus
{
    [self.m_server sendGameStatus:tempStatus];
}

-(void) sendGameRoomAction:(PVModelGameRoomActionType) tempAction
{
    [self.m_server sendGameRoomAction:tempAction];
}

#pragma mark - cgi method

-(void) onPVGameNotifyWithGameStatus:(PVModelGameStatus *)tempStatus
{
    [self.m_gameStatus addObject:tempStatus];
}

-(void) onPVGameNotifyWithGameRoomInfo:(PVModelGameRoomInfo *)tempInfo
{
    if ([self.m_roomDelegate respondsToSelector:@selector(onPVGameClient:didUpdateWithGameRoomInfo:)])
    {
        [self.m_roomDelegate onPVGameClient:self didUpdateWithGameRoomInfo:tempInfo];
    }
}

-(void) onPVGameNotifyWithStartGame:(PVModelStartGame *)tempStartGame
{
    if ([self.m_roomDelegate respondsToSelector:@selector(onPVGameClient:didStartGame:)])
    {
        [self.m_roomDelegate onPVGameClient:self didStartGame:tempStartGame];
    }
}

#pragma mark - PVGameServerRoomDelegate

@end
