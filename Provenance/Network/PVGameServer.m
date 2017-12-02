//
//  PVGameServer.m
//  Provenance
//
//  Created by Kamazuki on 2017/11/15.
//  Copyright © 2017年 James Addyman. All rights reserved.
//

#import "PVGameServer.h"
#import "GCDAsyncSocket.h"
#import "PVGameNetworkDef.h"
#import "PVGameCgiDef.h"
#import "NSObject+YYModel.h"
#import "PVGameCgi.h"
#import "PVGameNotifyDef.h"
#import "PVModelGameStatus.h"
#import "PVScopeLock.h"
#import "PVGameDataParser.h"
#import "PVModelGameRoomInfo.h"

@interface PVGameServer ()
<
    PVGameDataParserDelegate,
    PVGameCgiDelegate,
    NSNetServiceDelegate,
    GCDAsyncSocketDelegate
>

//广播网络服务
@property(nonatomic, strong) NSNetService* m_netService;
//当前连接的socket
@property(nonatomic, strong) NSMutableArray* m_connectedSockets;
//当前自己的socket
@property(nonatomic, strong) GCDAsyncSocket* m_serverSocket;
//用于接受客户端发过来的信息
@property(nonatomic, strong) PVGameCgi* m_gameCgi;
//用于解析接收的数据
@property(nonatomic, strong) PVGameDataParser* m_dataParser;

//====游戏房间内容====//
@property(nonatomic, strong) NSMutableArray<PVModelUser*>* m_userList;
@property(nonatomic, strong) NSMutableArray* m_player1Instructions;

@property(nonatomic, assign) unsigned long long m_player2Instruction;
@property(nonatomic, assign) unsigned long long m_gameServerSequence;
//^^^^游戏房间内容^^^^//

//just for fun
@property(nonatomic, strong) NSMutableArray* m_randomNames;

@end

@implementation PVGameServer

-(id) init
{
    self = [super init];
    if (self) {
        self.m_connectedSockets = [NSMutableArray array];
        self.m_gameCgi = [[PVGameCgi alloc] init];
        self.m_gameCgi.m_delegate = self;
        
        self.m_dataParser = [[PVGameDataParser alloc] init];
        self.m_dataParser.m_delegate = self;
        
        self.m_userList = [NSMutableArray array];
        self.m_player1Instructions = [NSMutableArray array];
        
        {
            NSMutableArray* tempArray = [NSMutableArray array];
            [tempArray addObject:@"鹅是扎扎飞"];
            [tempArray addObject:@"吾是顾挺勒"];
            [tempArray addObject:@"我系陈少村"];
            [tempArray addObject:@"我系踢波很厉害的那个碧咸"];
            [tempArray addObject:@"吾是打波很厉害的那个佐敦"];
            
            self.m_randomNames = tempArray;
        }
    }
    return self;
}

-(void) start
{
    //房主
    PVModelUser* tempUser = [[PVModelUser alloc] init];
    tempUser.m_id = UINT_MAX;
    tempUser.m_ready = 1;
    tempUser.m_name = [self userNameRandom];
    
    [self.m_userList addObject:tempUser];
    
    PVModelGameRoomInfo* tempInfo = [[PVModelGameRoomInfo alloc] init];
    tempInfo.m_userArray = self.m_userList;
    
    [self.m_notifyDelegate onPVGameNotifyWithGameRoomInfo:tempInfo];
    
    self.m_serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError* tempError = nil;
    if ([self.m_serverSocket acceptOnPort:9999 error:&tempError])
    {
        UInt16 port = [self.m_serverSocket localPort];
        
        // Create and publish the bonjour service.
        // Obviously you will be using your own custom service type.
        
        self.m_netService = [[NSNetService alloc] initWithDomain:NETWORK_DOMAIN
                                                     type:NETWORK_SERVICE_TYPE
                                                     name:NETWORK_SERVICE_NAME
                                                     port:port];
        
        [self.m_netService setDelegate:self];
        [self.m_netService publish];
        
        // You can optionally add TXT record stuff
        
        NSMutableDictionary *txtDict = [NSMutableDictionary dictionaryWithCapacity:2];
        
        [txtDict setObject:@"sunset riders" forKey:@"game name"];
        [txtDict setObject:@"great fun!" forKey:@"game detail"];
        
        NSData *txtData = [NSNetService dataFromTXTRecordDictionary:txtDict];
        [self.m_netService setTXTRecordData:txtData];
        return;
    }
    
    NSLog(@"server socket error:%@", tempError);
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    [self.m_dataParser parserData:data user:sock.userData];
    [sock readDataWithTimeout:-1 tag:1];
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"didAcceptNewSocket.");
    if (newSocket == nil)
    {
        NSLog(@"newSocket == nil.");
        return;
    }
    
    //有新玩家进入游戏，先给他分配一个游戏id就是当前的socket的编号
    PVModelUser* tempUser = [[PVModelUser alloc] init];
    tempUser.m_id = (unsigned int)self.m_connectedSockets.count;
    tempUser.m_name = [self userNameRandom];
    
    [self.m_userList addObject:tempUser];
    
    newSocket.userData = tempUser;
    [self.m_connectedSockets addObject:newSocket];
    
    [newSocket readDataWithTimeout:-1 tag:1];
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"socketDidDisconnect. %@", err);
    if (sock == nil)
    {
        NSLog(@"sock == nil.");
        return;
    }
    
    [self.m_connectedSockets removeObject:sock];
}

- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{

}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{

}

- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{
}

#pragma mark - NSNetServiceDelegate

- (void)netServiceDidPublish:(NSNetService *)ns
{
    // TODO: 应该要在主线程显示游戏发布成功
    NSLog(@"Bonjour Service Published: domain(%@) type(%@) name(%@) port(%i)",
              [ns domain], [ns type], [ns name], (int)[ns port]);
}

- (void)netService:(NSNetService *)ns didNotPublish:(NSDictionary *)errorDict
{
    // TODO: 应该要在主线程显示游戏发布失败
    NSLog(@"Failed to Publish Service: domain(%@) type(%@) name(%@) - %@",
               [ns domain], [ns type], [ns name], errorDict);
}

#pragma mark - PVGameCgiDelegate
-(void) onPVGameCgiSendGameStatus:(PVModelGameStatus *)tempInstruction user:(PVModelUser *)tempUser
{
    //只处理player2的游戏数据
    if (tempUser.m_id != 0)
    {
        return;
    }
    self.m_player2Instruction = tempInstruction.m_controllerStatus;
}

-(void) onPVGameCgiSendGameRoomAction:(PVModelGameRoomAction *)tempAction user:(PVModelUser *)tempUser
{
    if (tempAction.m_action == PVModelGameRoomActionGetRoomInfo)
    {
        [self notifyGameRoomInfo];
        return;
    }
    
    if (tempAction.m_action == PVModelGameRoomActionGetReady)
    {
        tempUser.m_ready = 1;
        [self notifyGameRoomInfo];
        return;
    }
    
    if (tempAction.m_action == PVModelGameRoomActionGetNoReady)
    {
        tempUser.m_ready = 0;
        [self notifyGameRoomInfo];
        return;
    }
}

#pragma mark - PVGameClientConnection
-(void) sendGameStatus:(unsigned long long) tempStatus
{
    PVModelGameStatus* tempInstruction = [[PVModelGameStatus alloc] init];
    tempInstruction.m_controllerStatus = tempStatus | self.m_player2Instruction;
    [self.m_player1Instructions addObject:tempInstruction];
    
    [self.m_notifyDelegate onPVGameNotifyWithGameStatus:tempInstruction];

    [self notifyGameStatus:tempInstruction];
}

-(void) sendGameRoomAction:(PVModelGameRoomActionType) tempAction
{
    //这里判断action类型
    if (tempAction == PVModelGameRoomActionGetReady)
    {
        for (PVModelUser* tempUser in self.m_userList)
        {
            if (tempUser.m_ready == 0)
            {
                return;
            }
        }
        
        [self notifyStartGame];
    }
}

#pragma mark - logic method

-(unsigned long long) gameStatus
{
    PVModelGameStatus* gameInstruction = nil;
    unsigned long long tempIndex = self.m_player1Instructions.count;
    
    if (tempIndex == 0)
    {
        gameInstruction = [[PVModelGameStatus alloc] init];
        gameInstruction.m_controllerStatus = 0;
        [self.m_player1Instructions addObject:gameInstruction];
    }
    else
    {
        gameInstruction = [self.m_player1Instructions objectAtIndex:self.m_player1Instructions.count - 1];
    }

    return gameInstruction.m_controllerStatus;
}

#pragma mark - notify method
-(void) notifyGameStatus:(PVModelGameStatus*) packageOne
{
    PVModelBase* tempModel = [[PVModelBase alloc] init];
    tempModel.m_cgi = PVGameNotifyDef_GameStatus;
    tempModel.m_sequence = self.m_gameServerSequence;
    
    self.m_gameServerSequence ++;
    
    tempModel.m_string = [packageOne yy_modelToJSONString];
    
    NSData* tempResult = [PVGameDataParser messageDataWithModel:tempModel];
    
    for (GCDAsyncSocket* tempSocket in self.m_connectedSockets)
    {
        [tempSocket writeData:tempResult withTimeout:-1 tag:1];
    }
}

-(void) notifyGameRoomInfo
{
    PVModelGameRoomInfo* temp = [[PVModelGameRoomInfo alloc] init];
    temp.m_userArray = self.m_userList;
    
    [self.m_notifyDelegate onPVGameNotifyWithGameRoomInfo:temp];
    
    PVModelBase* tempModel = [[PVModelBase alloc] init];
    tempModel.m_cgi = PVGameNotifyDef_GameRoomInfo;
    tempModel.m_sequence = self.m_gameServerSequence;
    
    self.m_gameServerSequence ++;
    
    tempModel.m_string = [temp yy_modelToJSONString];
    
    NSData* tempResult = [PVGameDataParser messageDataWithModel:tempModel];
    
    for (GCDAsyncSocket* tempSocket in self.m_connectedSockets)
    {
        [tempSocket writeData:tempResult withTimeout:-1 tag:1];
    }
}

-(void) notifyStartGame
{
    PVModelStartGame* temp = [[PVModelStartGame alloc] init];
    temp.m_delay = 1;
    
    [self.m_notifyDelegate onPVGameNotifyWithStartGame:temp];
    
    PVModelBase* tempModel = [[PVModelBase alloc] init];
    tempModel.m_cgi = PVGameNotifyDef_StartGame;
    tempModel.m_sequence = self.m_gameServerSequence;
    
    self.m_gameServerSequence ++;
    
    tempModel.m_string = [temp yy_modelToJSONString];
    
    NSData* tempResult = [PVGameDataParser messageDataWithModel:tempModel];
    
    for (GCDAsyncSocket* tempSocket in self.m_connectedSockets)
    {
        [tempSocket writeData:tempResult withTimeout:-1 tag:1];
    }
}

#pragma mark - PVGameDataParserDelegate
-(void) didParserData:(NSData*) tempModelData user:(PVModelUser *)tempUser
{
    PVModelBase* tempModel = [PVModelBase yy_modelWithJSON:tempModelData];
    if (tempModel == nil)
    {
        NSLog(@"tempModel == nil.");
        return;
    }
    
    [self.m_gameCgi cgiWithModel:tempModel user:tempUser];
}

#pragma mark - just for fun
-(NSString*) userNameRandom
{
    int tempRandomNumber = arc4random() % self.m_randomNames.count;
    NSString* tempName = [self.m_randomNames objectAtIndex:tempRandomNumber];
    [self.m_randomNames removeObjectAtIndex:tempRandomNumber];
    
    return tempName;
}

@end
