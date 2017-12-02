//
//  PVGameClientRealReal.m
//  Provenance
//
//  Created by Kamazuki on 2017/11/15.
//  Copyright © 2017年 James Addyman. All rights reserved.
//

#import "PVGameClientReal.h"
#import "GCDAsyncSocket.h"
#import "PVGameNetworkDef.h"
#import "PVGameNotify.h"
#import "NSObject+YYModel.h"
#import "PVGameCgiDef.h"
#import "PVScopeLock.h"
#import "PVGameDataParser.h"

@interface PVGameClientReal ()
<
    PVGameDataParserDelegate,
    PVGameNotifyDelegate,
    NSNetServiceDelegate,
    GCDAsyncSocketDelegate,
    NSNetServiceBrowserDelegate
>

@property(nonatomic, strong) NSNetServiceBrowser* m_netBrowser;
@property(nonatomic, strong) NSNetService* m_currentConnectService;
@property(nonatomic, strong) NSMutableArray* m_serviceArray;
@property(nonatomic, strong) NSMutableArray* m_serviceAddressArray;
@property(nonatomic, strong) GCDAsyncSocket* m_clientSocket;
@property(nonatomic, strong) GCDAsyncSocket* m_serverSocket;
@property(nonatomic, strong) PVGameNotify* m_gameNotify;
@property(nonatomic, strong) NSRecursiveLock* m_lock;
@property(nonatomic, strong) PVGameDataParser* m_dataParser;
//====房间数据====//
@property(nonatomic, strong) NSMutableArray* m_gameStatus;
@property(nonatomic, assign) unsigned long long m_gameStatusIndex;
//^^^^房间数据^^^^//

@property(nonatomic, weak) id<PVGameClientDelegate> m_delegate;
@property(nonatomic, weak) id<PVGameClientRoomDelegate> m_roomDelegate;
@property(nonatomic, weak) id<PVGameClientRoomListDelegate> m_roomListDelegate;

@property(nonatomic, assign) BOOL m_connected;

//====//
@property(nonatomic, strong) PVModelUser* m_myRole;

@end

@implementation PVGameClientReal

-(id) init
{
    self = [super init];
    if (self) {
        self.m_serviceArray = [NSMutableArray array];
        self.m_gameNotify = [[PVGameNotify alloc] init];
        self.m_gameNotify.m_delegate = self;
        self.m_dataParser = [[PVGameDataParser alloc] init];
        self.m_dataParser.m_delegate = self;
        
        self.m_gameStatus = [NSMutableArray array];
        self.m_lock = [[NSRecursiveLock alloc] init];
    }
    return self;
}

-(void) setDelegate:(id<PVGameClientDelegate>)tempDelegate
{
    self.m_delegate = tempDelegate;
}

-(void) setRoomDelegate:(id<PVGameClientRoomDelegate>)tempDelegate
{
    self.m_roomDelegate = tempDelegate;
}

-(void) setRoomListDelegate:(id<PVGameClientRoomListDelegate>)tempDelegate
{
    self.m_roomListDelegate = tempDelegate;
}

-(void) connectToService:(NSNetService*) tempService
{
    self.m_currentConnectService = tempService;
    
    [self.m_currentConnectService setDelegate:self];
    [self.m_currentConnectService resolveWithTimeout:5.0];
}

-(void) start
{
    self.m_netBrowser = [[NSNetServiceBrowser alloc] init];
    
    [self.m_netBrowser setDelegate:self];
    [self.m_netBrowser searchForServicesOfType:NETWORK_SERVICE_TYPE inDomain:NETWORK_DOMAIN];
}

- (void)connectToNextAddress
{
    BOOL done = NO;
    
    while (done == NO && ([self.m_serviceAddressArray count] != 0))
    {
        NSData *addr;
        
        addr = [self.m_serviceAddressArray objectAtIndex:0];
        [self.m_serviceAddressArray removeObjectAtIndex:0];
        
        NSLog(@"Attempting connection to %@", addr);
        
        NSError *err = nil;
        if ([self.m_clientSocket connectToAddress:addr error:&err])
        {
            done = YES;
        }
        else
        {
            NSLog(@"Unable to connect: %@", err);
        }
    }
    
    if (done == NO)
    {
        NSLog(@"Unable to connect to any resolved address");
    }
}

-(BOOL) isGameStatusOk
{
    PVScopeLock* tempLock = [[PVScopeLock alloc] initWithLock:self.m_lock];
    [tempLock scopeLock];
    
    if (self.m_gameStatusIndex >= self.m_gameStatus.count)
    {
        return NO;
    }
    return YES;
}

-(BOOL) shouldSkipFrame
{
    PVScopeLock* tempLock = [[PVScopeLock alloc] initWithLock:self.m_lock];
    [tempLock scopeLock];
    
    unsigned long tempFrameBuffer = 4;
    if (self.m_gameStatus.count < tempFrameBuffer)
    {
        return NO;
    }
    
    if (self.m_gameStatusIndex < self.m_gameStatus.count - tempFrameBuffer)
    {
        return YES;
    }
    return NO;
}

-(unsigned long long) nextGameStatus
{
    PVScopeLock* tempLock = [[PVScopeLock alloc] initWithLock:self.m_lock];
    [tempLock scopeLock];
    
    if (self.m_gameStatusIndex >= self.m_gameStatus.count)
    {
        return 0;
    }
    
    PVModelGameStatus* tempStatus = [self.m_gameStatus objectAtIndex:self.m_gameStatusIndex];
    self.m_gameStatusIndex ++;
    
    if (self.m_gameStatus.count >= 50)
    {
        NSUInteger tempLength = self.m_gameStatus.count - self.m_gameStatusIndex;
        if (tempLength == 0)
        {
            self.m_gameStatus = [NSMutableArray array];
        }
        else
        {
            self.m_gameStatus = [[self.m_gameStatus subarrayWithRange:NSMakeRange(self.m_gameStatusIndex, tempLength)] mutableCopy];
        }
        self.m_gameStatusIndex = 0;
    }
    
    return tempStatus.m_controllerStatus;
}

#pragma mark - NSNetServiceBrowserDelegate
- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser
{
    NSLog(@"netServiceBrowserWillSearch.");
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser
{
    NSLog(@"netServiceBrowserDidStopSearch.");
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary<NSString *, NSNumber *> *)errorDict
{
    NSLog(@"didNotSearch.");
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing
{
    NSLog(@"didFindDomain.");
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    NSLog(@"didFindService:%@, moreComing:%d", [service name], moreComing);
    
    if (service == nil)
    {
        return;
    }
    
    [self.m_serviceArray addObject:service];
    
    if ([self.m_roomListDelegate respondsToSelector:@selector(onPVGameClient:serviceUpdateWithArray:)])
    {
        [self.m_roomListDelegate onPVGameClient:self serviceUpdateWithArray:self.m_serviceArray];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveDomain:(NSString *)domainString moreComing:(BOOL)moreComing
{
    NSLog(@"didRemoveDomain.");
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    NSLog(@"didRemoveService:%@, moreComing:%d", [service name], moreComing);
    
    if (service == nil)
    {
        return;
    }
    
    [self.m_serviceArray removeObject:service];
    
    if ([self.m_roomListDelegate respondsToSelector:@selector(onPVGameClient:serviceUpdateWithArray:)])
    {
        [self.m_roomListDelegate onPVGameClient:self serviceUpdateWithArray:self.m_serviceArray];
    }
}

#pragma mark - NSNetServiceDelegate
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
    NSLog(@"DidNotResolve");
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
    NSLog(@"DidResolve: %@", [sender addresses]);
    
    self.m_serviceAddressArray = [[sender addresses] mutableCopy];
    
    self.m_clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self connectToNextAddress];
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"Socket:DidConnectToHost: %@ Port: %hu", host, port);
    self.m_connected = YES;
    self.m_serverSocket = sock;
    if ([self.m_roomListDelegate respondsToSelector:@selector(onPVGameClient:didJoinServerWithName:)])
    {
        [self.m_roomListDelegate onPVGameClient:self didJoinServerWithName:self.m_currentConnectService.name];
    }
   
    
    [self.m_clientSocket readDataWithTimeout:-1 tag:1];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"SocketDidDisconnect:WithError: %@", err);
    //曾经连上过，就不要再连了
    if (self.m_connected == NO)
    {
        [self connectToNextAddress];
    }
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    [self.m_dataParser parserData:data user:nil];
    [self.m_clientSocket readDataWithTimeout:-1 tag:1];
}

#pragma mark - PVGameNotifyDelegate
-(void) onPVGameNotifyWithGameStatus:(PVModelGameStatus *)tempStatus
{
    PVScopeLock* tempLock = [[PVScopeLock alloc] initWithLock:self.m_lock];
    [tempLock scopeLock];
    
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

#pragma mark - cgi method

-(void) sendGameStatus:(unsigned long long)tempStatus
{
    tempStatus = tempStatus << 12;
    PVModelBase* tempModel = [[PVModelBase alloc] init];
    tempModel.m_cgi = PVGameCgiDef_SendGameStatus;
    
    PVModelGameStatus* tempInstruction = [[PVModelGameStatus alloc] init];
    tempInstruction.m_controllerStatus = tempStatus;
    
    tempModel.m_string = [tempInstruction yy_modelToJSONString];
    
    NSData* tempResult = [PVGameDataParser messageDataWithModel:tempModel];
    
    [self.m_serverSocket writeData:tempResult withTimeout:-1 tag:1];
}

-(void) sendGameRoomAction:(PVModelGameRoomActionType)tempAction
{
    PVModelBase* tempModel = [[PVModelBase alloc] init];
    tempModel.m_cgi = PVGameCgiDef_SendGameRoomAction;
    
    PVModelGameRoomAction* temp = [[PVModelGameRoomAction alloc] init];
    temp.m_action = tempAction;
    
    tempModel.m_string = [temp yy_modelToJSONString];
    
    NSData* tempResult = [PVGameDataParser messageDataWithModel:tempModel];
    
    [self.m_serverSocket writeData:tempResult withTimeout:-1 tag:1];
}

#pragma mark - PVGameDataParserDelegate
-(void) didParserData:(NSData *)data user:(PVModelUser *)tempUser
{
    PVModelBase* tempModel = [PVModelBase yy_modelWithJSON:data];
    [self.m_gameNotify notifyWithModel:tempModel];
}

@end

