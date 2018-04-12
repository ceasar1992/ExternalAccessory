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
    EASession *_session;
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
    
    _session = [self openSessionForProtocol:[self.protocolStrings firstObject]];
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
            [self receiveData];
        }
            break;
            
        case NSStreamEventHasSpaceAvailable:
        {// Send the next queued command.
            [self writeData];
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

-(void)receiveData
{
    NSInteger maxLength = 128;
    uint8_t readBuffer [maxLength];
    //是否已经到结尾标识
    BOOL endOfStreamReached = NO;
    // NOTE: this tight loop will block until stream ends
    while (! endOfStreamReached)
    {
        NSInteger bytesRead = [_session.inputStream read: readBuffer maxLength:maxLength];
        if (bytesRead == 0)
        {//文件读取到最后
            endOfStreamReached = YES;
        }
        else if (bytesRead == -1)
        {//文件读取错误
            endOfStreamReached = YES;
        }
        else
        {
            NSString *readBufferString =[[NSString alloc] initWithBytesNoCopy:readBuffer length:bytesRead encoding: NSUTF8StringEncoding freeWhenDone: NO];
            //将字符不断的加载到视图
            NSLog(@"收到设备信息：%@",readBufferString);
            TTSLOG(@"收到设备信息");
        }
    }
}

-(void)writeData
{
    BOOL isAvailable = _session.outputStream.hasSpaceAvailable;
    if (isAvailable == YES) {
        NSData *data = [[NSData alloc]initWithBase64EncodedString:@"出发了老铁" options:NSDataBase64DecodingIgnoreUnknownCharacters];
        [_session.outputStream write:[data bytes] maxLength:data.length];
    }
    
}


@end
