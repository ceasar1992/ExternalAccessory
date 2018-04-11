//
//  HHTool.m
//  EADemo
//
//  Created by HDHaoShaoPeng on 2018/4/11.
//  Copyright © 2018年 Summer.Wu. All rights reserved.
//

#import "HHTool.h"

@implementation HHTool
+(NSString*)sexToHexWith:(NSString *)hexString
{
    int int_ch;  /// 两位16进制数转化后的10进制数
    
    int i = 0;
    
    unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
    int int_ch1;
    if(hex_char1 >= '0' && hex_char1 <='9')
        int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
    else if(hex_char1 >= 'A' && hex_char1 <='F')
        int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
    else
        int_ch1 = (hex_char1-87)*16; //// a 的Ascll - 97
    i++;
    
    unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
    int int_ch2;
    if(hex_char2 >= '0' && hex_char2 <='9')
        int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
    else if(hex_char1 >= 'A' && hex_char1 <='F')
        int_ch2 = hex_char2-55; //// A 的Ascll - 65
    else
        int_ch2 = hex_char2-87; //// a 的Ascll - 97
    
    int_ch = int_ch1+int_ch2;
    
    return [NSString stringWithFormat:@"%d",int_ch];
}

+(NSArray *)gaoDiWeiWith:(NSString *)str
{
    int a = str.intValue;
    int b = a/256;
    int c = a%256;
    NSArray *arr = @[[NSNumber numberWithInt:b],[NSNumber numberWithInt:c]];
    return arr;
}
@end
