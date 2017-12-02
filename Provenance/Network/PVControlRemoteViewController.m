//
//  PVControlRemoteViewController.m
//  Provenance
//
//  Created by Kamazuki on 2017/11/17.
//  Copyright © 2017年 James Addyman. All rights reserved.
//

#import "PVControlRemoteViewController.h"
#import <PVGenesis/PVGenesisEmulatorCore.h>
#import "PVEmulatorConfiguration.h"

@interface PVControlRemoteViewController ()

@property(nonatomic, strong) PVGameServer* m_server;

@end

@implementation PVControlRemoteViewController

-(id) initWithServer:(PVGameServer*) tempServer game:(id)tempGame
{
    self = [super init];
    if (self)
    {
        self.m_server = tempServer;
        self.systemIdentifier = [tempGame systemIdentifier];
        self.controlLayout = [[PVEmulatorConfiguration sharedInstance] controllerLayoutForSystem:[tempGame systemIdentifier]];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
/*
- (void)dPad:(JSDPad *)dPad didPressDirection:(JSDPadDirection)direction
{
    [self.m_server notifyGameInstruction:0 pad:PVGenesisButtonUp];
    [self.m_server notifyGameInstruction:0 pad:PVGenesisButtonDown];
    [self.m_server notifyGameInstruction:0 pad:PVGenesisButtonRight];
    [self.m_server notifyGameInstruction:0 pad:PVGenesisButtonLeft];
    
    switch (direction)
    {
        case JSDPadDirectionUpLeft:
            [self.m_server notifyGameInstruction:1 pad:PVGenesisButtonUp];
            [self.m_server notifyGameInstruction:1 pad:PVGenesisButtonLeft];
            break;
        case JSDPadDirectionUp:
             [self.m_server notifyGameInstruction:1 pad:PVGenesisButtonUp];
            break;
        case JSDPadDirectionUpRight:
             [self.m_server notifyGameInstruction:1 pad:PVGenesisButtonUp];
             [self.m_server notifyGameInstruction:1 pad:PVGenesisButtonRight];
            break;
        case JSDPadDirectionLeft:
             [self.m_server notifyGameInstruction:1 pad:PVGenesisButtonLeft];
            break;
        case JSDPadDirectionRight:
             [self.m_server notifyGameInstruction:1 pad:PVGenesisButtonRight];
            break;
        case JSDPadDirectionDownLeft:
             [self.m_server notifyGameInstruction:1 pad:PVGenesisButtonDown];
             [self.m_server notifyGameInstruction:1 pad:PVGenesisButtonLeft];
            break;
        case JSDPadDirectionDown:
             [self.m_server notifyGameInstruction:1 pad:PVGenesisButtonDown];
            break;
        case JSDPadDirectionDownRight:
             [self.m_server notifyGameInstruction:1 pad:PVGenesisButtonDown];
             [self.m_server notifyGameInstruction:1 pad:PVGenesisButtonRight];
            break;
        default:
            break;
    }
    
    [super dPad:dPad didPressDirection:direction];
}

- (void)dPadDidReleaseDirection:(JSDPad *)dPad
{
    [self.m_server notifyGameInstruction:0 pad:PVGenesisButtonUp];
    [self.m_server notifyGameInstruction:0 pad:PVGenesisButtonDown];
    [self.m_server notifyGameInstruction:0 pad:PVGenesisButtonRight];
    [self.m_server notifyGameInstruction:0 pad:PVGenesisButtonLeft];
}

- (void)buttonPressed:(JSButton *)button
{
    [self.m_server notifyGameInstruction:1 pad:[button tag]];
}

- (void)buttonReleased:(JSButton *)button
{
    [self.m_server notifyGameInstruction:0 pad:[button tag]];
}

- (void)pressStartForPlayer:(NSUInteger)player
{
    [self.m_server notifyGameInstruction:1 pad:PVGenesisButtonStart];
}

- (void)releaseStartForPlayer:(NSUInteger)player
{
    [self.m_server notifyGameInstruction:0 pad:PVGenesisButtonStart];
}

- (void)pressSelectForPlayer:(NSUInteger)player
{

}

- (void)releaseSelectForPlayer:(NSUInteger)player
{

}
*/

@end
