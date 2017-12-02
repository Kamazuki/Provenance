//
//  PVGameRoomViewController.m
//  Provenance
//
//  Created by Kamazuki on 2017/11/15.
//  Copyright © 2017年 James Addyman. All rights reserved.
//

#import "PVGameRoomViewController.h"
#import "PVModelUser.h"
#import "PVControlRemoteViewController.h"

@interface PVGameRoomViewController ()
<
    PVGameClientRoomDelegate,
    UITableViewDelegate,
    UITableViewDataSource
>
//data
@property(nonatomic, strong) PVGame* m_game;
@property(nonatomic, strong) id<PVGameClient> m_client;
@property(nonatomic, strong) PVModelGameRoomInfo* m_gameRoomInfo;

//view
@property(nonatomic, strong) UITableView* m_tableView;


@end

@implementation PVGameRoomViewController

-(id) initWithGame:(PVGame*) tempGame client:(id<PVGameClient>)tempClient
{
    self = [super init];
    if (self) {
        self.m_game = tempGame;
        self.m_client = tempClient;
        [self.m_client setRoomDelegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self updateTableView];
    
    [self.m_client sendGameRoomAction:PVModelGameRoomActionGetRoomInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self updateTableView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"ready" style:UIBarButtonItemStyleDone target:self action:@selector(onReady)];
}

-(void) onReady
{
    [self.m_client sendGameRoomAction:PVModelGameRoomActionGetReady];
}

-(void) updateTableView
{
    if (self.m_tableView == nil)
    {
        self.m_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
        
        self.m_tableView.dataSource = self;
        self.m_tableView.delegate = self;
        
        [self.view addSubview:self.m_tableView];
    }
    
    self.m_tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

#pragma mark - UITableViewDataSource

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* RoomCellIdentifier = @"UserCell";
    UITableViewCell* tempCell = [tableView dequeueReusableCellWithIdentifier:RoomCellIdentifier];
    if (tempCell == nil)
    {
        tempCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:RoomCellIdentifier];
    }
    
    if (indexPath.row < self.m_gameRoomInfo.m_userArray.count)
    {
        PVModelUser* tempUser = [self.m_gameRoomInfo.m_userArray objectAtIndex:indexPath.row];
        tempCell.textLabel.text = tempUser.m_name;
        if (tempUser.m_ready)
        {
            tempCell.detailTextLabel.text = @"准备👌了！";
        }
        else
        {
            tempCell.detailTextLabel.text = @"大🐻弟，再稍等我一会！";
        }
        
    }
    
    return tempCell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.m_gameRoomInfo.m_userArray.count;
}

#pragma mark - UITableViewDelegate
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.m_gameRoomInfo.m_userArray.count)
    {
        NSLog(@"indexPath out of bound.");
        return;
    }
}

#pragma mark - PVGameClientRoomDelegate
-(void) onPVGameClient:(id<PVGameClient>)client didUpdateWithGameRoomInfo:(PVModelGameRoomInfo *)tempInfo
{
    self.m_gameRoomInfo = tempInfo;
    [self.m_tableView reloadData];
}

-(void) onPVGameClient:(id<PVGameClient>)client didStartGame:(PVModelStartGame *)tempInfo
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.m_delegate onPVGameRoomViewControllerStartGame:self.m_game info:tempInfo];
}

@end
