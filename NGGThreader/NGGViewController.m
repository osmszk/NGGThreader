//
//  NGGViewController.m
//  NGGThreader
//
//  Created by Osamu Suzuki on 2014/02/28.
//  Copyright (c) 2014年 Plegineer, Inc. All rights reserved.
//

#import "NGGViewController.h"

#define SCROLL_SPEED 5

@interface NGGViewController ()<UICollisionBehaviorDelegate>
@property (nonatomic, strong) UIImageView *ballImageView;
@property (nonatomic, strong) UIImageView *groundImageView;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIPushBehavior *floatUpBehavior;
@property (nonatomic, strong) NSMutableArray *sceneries;
@end

@implementation NGGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.sceneries = [[NSMutableArray alloc] init];
    
    UIView *bgView = [[UIView alloc] initWithFrame:self.view.frame];
    bgView.backgroundColor = [UIColor colorWithRed:0 green:150.0f/255.0f blue:255.0f alpha:1.0f];
    [self.view addSubview:bgView];
    
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
    [self.sceneries addObject:groundImageView];
    self.groundImageView = groundImageView;
    
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
        [self updateViews];
        
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

- (void)updateViews
{
//    NSTimeInterval interval = self.animator.elapsedTime;
    
    for(UIView *scenary in self.sceneries){
        scenary.center = CGPointMake(scenary.center.x-SCROLL_SPEED, scenary.center.y);
    }
    
    if (self.groundImageView.frame.origin.x <= -[self displaySize].width) {
        self.groundImageView.center = CGPointMake([self displaySize].width, self.groundImageView.center.y);
        NSLog(@"new! bg! %@",NSStringFromCGRect(self.groundImageView.frame));
        
        for(UIView *scenary in [self.sceneries reverseObjectEnumerator]){
            if(scenary.frame.origin.x+scenary.frame.size.width < 0){
                [scenary removeFromSuperview];
                [self.sceneries removeObject:scenary];
            }
        }
        
        [self addBuildings];
    }
    
//    NSLog(@"action %f x:%f",interval,self.groundImageView.center.x);
}

- (void)addBuildings
{
    CGFloat interSpace = 80;
    NSInteger offset = arc4random()%200-100;
    CGFloat downSideYPostion = [self displaySize].height/2 + offset;//[self displaySize].height/2 -+100
    
    NSLog(@"yPostion:%f",downSideYPostion);
    
    UIImageView *upSideBuildingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"building"]];
    upSideBuildingImageView.frame = CGRectMake([self displaySize].width, downSideYPostion-400-interSpace, 60, 400);
    [self.view insertSubview:upSideBuildingImageView belowSubview:self.groundImageView];
    [self.sceneries addObject:upSideBuildingImageView];
    
    UIImageView *downSideBuildingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"building"]];
    downSideBuildingImageView.frame = CGRectMake([self displaySize].width, downSideYPostion, 60, 400);
    [self.view insertSubview:downSideBuildingImageView belowSubview:self.groundImageView];
    [self.sceneries addObject:downSideBuildingImageView];
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
