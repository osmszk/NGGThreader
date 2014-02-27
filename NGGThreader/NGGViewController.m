//
//  NGGViewController.m
//  NGGThreader
//
//  Created by Osamu Suzuki on 2014/02/28.
//  Copyright (c) 2014年 Plegineer, Inc. All rights reserved.
//

#import "NGGViewController.h"

@interface NGGViewController ()

@end

@implementation NGGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    
    
    CGFloat ballWidth = 40;
    CGFloat ballHeight = 40;
    UIImageView *ballImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ball"]];
    ballImageView.frame = CGRectMake(0, 0, ballWidth, ballHeight);
    ballImageView.center = CGPointMake([self displaySize].width/2, [self displaySize].height/2);
    [self.view addSubview:ballImageView];
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Custom

- (CGSize)displaySize
{
    return [[UIScreen mainScreen] bounds].size;
}

@end
