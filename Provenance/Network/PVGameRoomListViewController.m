//
//  PVGameMultiplayerViewController.m
//  Provenance
//
//  Created by Kamazuki on 2017/11/15.
//  Copyright © 2017年 James Addyman. All rights reserved.
//

#import "PVGameRoomListViewController.h"
#import "PVEmulatorViewController.h"

@interface PVGameRoomListViewController ()
<
    PVGameClientRoomListDelegate,
    UITableViewDelegate,
    UITableViewDataSource
>

@property(nonatomic, strong) PVGame* m_game;
@property(nonatomic, strong) UITableView* m_tableView;
@property(nonatomic, strong) NSArray* m_serviceArray;
@property(nonatomic, strong) id<PVGameClient> m_client;

@property(nonatomic, strong) PVEmulatorViewController* m_gameView;

@end

@implementation PVGameRoomListViewController

-(id) initWithGame:(PVGame*) tempGame client:(id<PVGameClient>) tempClient
{
    self = [super init];
    if (self) {
        self.m_game = tempGame;
        self.m_client = tempClient;
        [self.m_client setRoomListDelegate:self];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self updateTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self updateTableView];
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
    static NSString* RoomCellIdentifier = @"RoomCell";
    UITableViewCell* tempCell = [tableView dequeueReusableCellWithIdentifier:RoomCellIdentifier];
    if (tempCell == nil)
    {
        tempCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:RoomCellIdentifier];
    }
    
    if (indexPath.row < self.m_serviceArray.count)
    {
        NSNetService* tempService = [self.m_serviceArray objectAtIndex:indexPath.row];
        tempCell.textLabel.text = tempService.name;
    }
    
    return tempCell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.m_serviceArray.count;
}

#pragma mark - UITableViewDelegate
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.m_serviceArray.count)
    {
        return;
    }
    
    NSNetService* tempService = [self.m_serviceArray objectAtIndex:indexPath.row];
    [self.m_client connectToService:tempService];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - PVGameClientRoomListDelegate
-(void) onPVGameClient:(id<PVGameClient>)client serviceUpdateWithArray:(NSArray *)tempArray
{
    self.m_serviceArray = tempArray;
    
    [self.m_tableView reloadData];
}

-(void) onPVGameClient:(id<PVGameClient>)client didJoinServerWithName:(NSString *)tempName
{
    PVGameRoomViewController* tempViewController = [[PVGameRoomViewController alloc] initWithGame:self.m_game client:self.m_client];
    tempViewController.m_delegate = self.m_delegate;
    [self.navigationController pushViewController:tempViewController animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
