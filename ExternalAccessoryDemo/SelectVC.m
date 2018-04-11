//
//  SelectVC.m
//  ExternalAccessoryDemo
//
//  Created by Summer Wu on 14-10-27.
//  Copyright (c) 2014年 Summer.Wu. All rights reserved.
//

#import "SelectVC.h"
#import "SelectCell.h"
#import <ExternalAccessory/ExternalAccessory.h>
#import <MobileCoreServices/UTCoreTypes.h>

#import "TTSLog.h"

@interface SelectVC ()<NSStreamDelegate,EAAccessoryDelegate>

@end

@implementation SelectVC
{
    EAAccessory *_accessory;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self.view2 layer]setCornerRadius:8.0f];
    self.title = self.eaName;
    self.view.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.7];
    
    [self openSessionForProtocol:[self.protocolStrings firstObject]];
}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


#pragma mark - NSStream Delegate

- (void)stream:(NSStream*)theStream handleEvent:(NSStreamEvent)streamEvent
{
    switch (streamEvent)
    {
        case NSStreamEventHasBytesAvailable:
        {// Process the incoming stream data.
            
        }
            break;
            
        case NSStreamEventHasSpaceAvailable:
        {// Send the next queued command.
            
        }
            break;
            
        default:
            break;
    }
    
}


#pragma mark - 找到指定的protocol 并创建输入输出流

- (EASession *)openSessionForProtocol:(NSString *)protocolString
{
    NSArray *accessories = [[EAAccessoryManager sharedAccessoryManager]
                            connectedAccessories];
    EASession *session = nil;
    
    for (EAAccessory *obj in accessories)
    {
        if ([[obj protocolStrings] containsObject:protocolString])
        {
            _accessory = obj;
            _accessory.delegate = self;
            break;
        }
    }
    
    if (_accessory)
    {
        session = [[EASession alloc] initWithAccessory:_accessory
                                           forProtocol:protocolString];
        if (session)
        {
            [[session inputStream] setDelegate:self];
            [[session inputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                             forMode:NSDefaultRunLoopMode];
            [[session inputStream] open];
            [[session outputStream] setDelegate:self];
            [[session outputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                              forMode:NSDefaultRunLoopMode];
            [[session outputStream] open];
        }
    }
    
    return session;
}


#pragma mark - EAAccessory Delegate

- (void)accessoryDidDisconnect:(EAAccessory *)accessory
{
    TTSLOG(@"选中外设断开链接");
}


#pragma mark - tableView Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return _protocolStrings.count;
    }
    else
    {
        return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SelectCell";
    SelectCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"SelectCell" owner:nil options:nil] firstObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell updateCell:[self.protocolStrings objectAtIndex:[indexPath row]]];
    return cell;
}

#pragma mark - 私有方法

-(IBAction)closeSelectVCTouchUpInside:(id)sender
{
    [self.view removeFromSuperview];
}

@end
