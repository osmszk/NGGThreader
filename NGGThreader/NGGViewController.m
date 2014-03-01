//
//  NGGViewController.m
//  NGGThreader
//
//  Created by Osamu Suzuki on 2014/02/28.
//  Copyright (c) 2014年 Plegineer, Inc. All rights reserved.
//

#import "NGGViewController.h"

#define SCROLL_SPEED 15

@interface NGGViewController ()<UICollisionBehaviorDelegate>
@property (nonatomic, strong) UIImageView *ballImageView;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIPushBehavior *floatUpBehavior;
@end

@implementation NGGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    CGFloat ballWidth = 40;
    CGFloat ballHeight = 40;
    UIImageView *ballImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ball"]];
    ballImageView.frame = CGRectMake(0, 0, ballWidth, ballHeight);
    ballImageView.center = CGPointMake([self displaySize].width/2, [self displaySize].height/2);
    [self.view addSubview:ballImageView];
    self.ballImageView = ballImageView;
    
    UIImageView *groundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ground"]];
    groundImageView.frame = CGRectMake(0, [self displaySize].height-40, 640, 40);
    [self.view addSubview:groundImageView];
    
    
    
    UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    UIGravityBehavior *gravityBehvior = [[UIGravityBehavior alloc] initWithItems:@[ballImageView]];
    [animator addBehavior:gravityBehvior];
    
    UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[ballImageView]];
    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    collisionBehavior.collisionDelegate = self;
    [collisionBehavior addBoundaryWithIdentifier:@"ground" fromPoint:CGPointMake(0, groundImageView.frame.origin.y) toPoint:CGPointMake(groundImageView.frame.size.width, groundImageView.frame.origin.y)];
    [animator addBehavior:collisionBehavior];
    
    UIPushBehavior *floatUpBeahavior = [[UIPushBehavior alloc] initWithItems:@[self.ballImageView] mode:UIPushBehaviorModeInstantaneous];
    floatUpBeahavior.pushDirection = CGVectorMake(0, -0.5);
    floatUpBeahavior.active = NO;
    [animator addBehavior:floatUpBeahavior];
    self.floatUpBehavior = floatUpBeahavior;
    
    self.animator = animator;
    
    UIDynamicBehavior *scrollBehavior = [[UIDynamicBehavior alloc] init];
    scrollBehavior.action = ^ {
        NSTimeInterval interval = self.animator.elapsedTime;
        
        groundImageView.center = CGPointMake(groundImageView.center.x-SCROLL_SPEED, groundImageView.center.y);
        
        if (groundImageView.frame.origin.x <= -[self displaySize].width) {
            groundImageView.center = CGPointMake([self displaySize].width, groundImageView.center.y);
        }
        
        NSLog(@"action %f x:%f",interval,groundImageView.center.x);
    };
    [self.animator addBehavior:scrollBehavior];
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

#pragma mark - Touch Event

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    self.floatUpBehavior.active = YES;
}

#pragma mark - UICollisionBehaviorDelegate

- (void)collisionBehavior:(UICollisionBehavior*)behavior beganContactForItem:(id <UIDynamicItem>)item withBoundaryIdentifier:(id <NSCopying>)identifier atPoint:(CGPoint)p
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)collisionBehavior:(UICollisionBehavior*)behavior endedContactForItem:(id <UIDynamicItem>)item withBoundaryIdentifier:(id <NSCopying>)identifier
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}


@end
