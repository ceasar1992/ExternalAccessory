//
//  RootVC.m
//  ExternalAccessoryDemo
//
//  Created by Summer Wu on 14-10-27.
//  Copyright (c) 2014年 Summer.Wu. All rights reserved.
//

#import "RootVC.h"
//#import <MobileCoreServices/UTCoreTypes.h>
#import <ExternalAccessory/ExternalAccessory.h>

#import "SelectVC.h"
#import "LogVC.h"
#import "TTSLog.h"


#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface RootVC ()
{
    NSMutableArray *_accessoryList;
    EAAccessory    *_selectedAccessory;
    UIView         *_noExternalAccessoriesPosterView;
    UILabel        *_noExternalAccessoriesLabelView;
    UIActionSheet  *_protocolSelectionActionSheet;
}

@end

@implementation RootVC


- (void)viewDidLoad
{
//    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
//    [pasteBoard setString:(NSString *)]
    [super viewDidLoad];
    [self setHeaderUI];
    _noExternalAccessoriesPosterView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [_noExternalAccessoriesPosterView setBackgroundColor:[UIColor whiteColor]];
    _noExternalAccessoriesLabelView = [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth - 300)/2.0, 200, 300, 50)];
    [_noExternalAccessoriesLabelView setText:@"No Accessories Connected"];
    _noExternalAccessoriesLabelView.font = [UIFont systemFontOfSize:20.0];
    _noExternalAccessoriesLabelView.textAlignment = NSTextAlignmentCenter;
    [_noExternalAccessoriesPosterView addSubview:_noExternalAccessoriesLabelView];
    [_tableView addSubview:_noExternalAccessoriesPosterView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_accessoryDidConnect:) name:EAAccessoryDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_accessoryDidDisconnect:) name:EAAccessoryDidDisconnectNotification object:nil];
    [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
     _accessoryList = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
    if ([_accessoryList count] == 0) {
        [_noExternalAccessoriesPosterView setHidden:NO];
    } else {
        [_noExternalAccessoriesPosterView setHidden:YES];
    }
    
    // Do any additional setup after loading the view from its nib.
}

-(void)setHeaderUI
{
    self.title = @"Accessories";
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Log" style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(myAction)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

-(void)myAction
{
    [self performSegueWithIdentifier:@"showLog" sender:nil];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _accessoryList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *eaAccessoryCellIdentifier = @"eaAccessoryCellIdentifier";
    NSUInteger row = [indexPath row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:eaAccessoryCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:eaAccessoryCellIdentifier];
    }
    if (row == 0) {
        TTSLOG(@"-------------------- Here are all the accessories can be connected ---------------------")
    }
    EAAccessory  *eaAccessory = [_accessoryList objectAtIndex:row];
    TTSLOG([eaAccessory description]);
    
    NSString *accessoryName = [[_accessoryList objectAtIndex:row] name];
    if (!accessoryName || [accessoryName isEqualToString:@""]) {
        accessoryName = @"unknown";
    }
    cell.textLabel.font = [UIFont systemFontOfSize:23];
    
	[[cell textLabel] setText:accessoryName];
	
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    _selectedAccessory = [_accessoryList objectAtIndex:row];
    TTSLOG(@"-------------------- Selected accessory --------------------")
    TTSLOG([_selectedAccessory description])
    
    [self performSegueWithIdentifier:@"showDetail" sender:nil];
    
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        SelectVC *vc = segue.destinationViewController;
        vc.eaName = [NSString stringWithFormat:@"%@'s protocols", [_selectedAccessory name]];
        vc.protocolStrings = [_selectedAccessory protocolStrings];
    }
}


#pragma mark - Accessory Connect Delegate

- (void)_accessoryDidConnect:(NSNotification *)notification {
    EAAccessory *connectedAccessory = [[notification userInfo] objectForKey:EAAccessoryKey];
    [_accessoryList addObject:connectedAccessory];
    TTSLOG(@"-------------------- The following accessory connected: --------------------")
    TTSLOG([connectedAccessory description])
    
    if ([_accessoryList count] == 0) {
        [_noExternalAccessoriesPosterView setHidden:NO];
    } else {
        [_noExternalAccessoriesPosterView setHidden:YES];
    }

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([_accessoryList count] - 1) inSection:0];
    [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)_accessoryDidDisconnect:(NSNotification *)notification {
    EAAccessory *disconnectedAccessory = [[notification userInfo] objectForKey:EAAccessoryKey];
    
    TTSLOG(@"-------------------- The following accessory disconnected: --------------------")
    TTSLOG([disconnectedAccessory description])
    
    if (_selectedAccessory && [disconnectedAccessory connectionID] == [_selectedAccessory connectionID])
    {
        [_protocolSelectionActionSheet dismissWithClickedButtonIndex:-1 animated:YES];
    }
    
    int disconnectedAccessoryIndex = 0;
    for(EAAccessory *accessory in _accessoryList) {
        if ([disconnectedAccessory connectionID] == [accessory connectionID]) {
            break;
        }
        disconnectedAccessoryIndex++;
    }
    
    if (disconnectedAccessoryIndex < [_accessoryList count]) {
        [_accessoryList removeObjectAtIndex:disconnectedAccessoryIndex];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:disconnectedAccessoryIndex inSection:0];
        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
	} else {
        NSLog(@"could not find disconnected accessory in accessory list");
        TTSLOG(@"---------------- could not find disconnected accessory in accessory list -----------------");
    }
    
    if ([_accessoryList count] == 0) {
        [_noExternalAccessoriesPosterView setHidden:NO];
    } else {
        [_noExternalAccessoriesPosterView setHidden:YES];
    }
}

@end
