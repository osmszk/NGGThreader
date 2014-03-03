//
//  NGGViewController.m
//  NGGThreader
//
//  Created by Osamu Suzuki on 2014/02/28.
//  Copyright (c) 2014年 Plegineer, Inc. All rights reserved.
//

#import "NGGViewController.h"

#define SCROLL_SPEED 4
#define INTER_SPACE 100
#define TAG_BUILDING 1

typedef NS_ENUM(NSInteger, NGGViewStatus) {
    NGGVIewStatusNone = 0,
    NGGVIewStatusStandby = 1,
    NGGVIewStatusAlive = 2,
    NGGVIewStatusGameOver = 3,
};

@interface NGGViewController ()<UICollisionBehaviorDelegate>
@property (nonatomic, strong) UILabel *startLabel;
@property (nonatomic, strong) UILabel *gameOverLabel;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UIImageView *ballImageView;
@property (nonatomic, strong) UIImageView *groundImageView;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIPushBehavior *floatUpBehavior;
@property (nonatomic, strong) NSMutableArray *sceneries;
@property (nonatomic, assign) NGGViewStatus viewStatus;
@property (nonatomic, assign) NSInteger score;
@end

@implementation NGGViewController

//ViewControllerのViewが生成されたときに呼ばれる
//UIに関する部分はここでaddSubViewする
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //背景表示
    UIView *bgView = [[UIView alloc] initWithFrame:self.view.frame];
    bgView.backgroundColor = [UIColor colorWithRed:0 green:150.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    [self.view addSubview:bgView];
    
    //ボール表示
    CGFloat ballWidth = 40;
    CGFloat ballHeight = 40;
    UIImageView *ballImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ball"]];
    ballImageView.frame = CGRectMake(0, 0, ballWidth, ballHeight);
    ballImageView.center = CGPointMake([self displaySize].width*1/4, [self displaySize].height/2);
    [self.view addSubview:ballImageView];
    self.ballImageView = ballImageView;
    
    //地面表示
    UIImageView *groundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ground"]];
    groundImageView.frame = CGRectMake(0, [self displaySize].height-40, 640, 40);
    [self.view addSubview:groundImageView];
    self.groundImageView = groundImageView;
    
    //スコアラベル表示
    UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [self displaySize].width, 100)];
    scoreLabel.backgroundColor = [UIColor clearColor];
    scoreLabel.textAlignment = NSTextAlignmentCenter;
    scoreLabel.textColor = [UIColor whiteColor];
    scoreLabel.font = [UIFont boldSystemFontOfSize:32];
    [self.view addSubview:scoreLabel];
    self.scoreLabel = scoreLabel;
    [self updateScore];
    
    [self setStanbyLabel];
    _viewStatus = NGGVIewStatusStandby;
}

//メモリが切迫したときに呼ばれる
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//ステータスバー非表示
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Custom

//本来はUtililtyクラスつくってクラスメソッドとして呼びたい
//ディスプレイサイズ
- (CGSize)displaySize
{
    return [[UIScreen mainScreen] bounds].size;
}

//重力とかビヘイビア（iOS7からの機能）を各オブジェクトに付与
- (void)setBehaviors
{
    UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    UIGravityBehavior *gravityBehvior = [[UIGravityBehavior alloc] initWithItems:@[self.ballImageView]];
    [animator addBehavior:gravityBehvior];
    
    UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.ballImageView]];
    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    collisionBehavior.collisionDelegate = self;
    [collisionBehavior addBoundaryWithIdentifier:@"ground" fromPoint:CGPointMake(0, self.groundImageView.frame.origin.y) toPoint:CGPointMake(self.groundImageView.frame.size.width, self.groundImageView.frame.origin.y)];
    [animator addBehavior:collisionBehavior];
    
    UIPushBehavior *floatUpBeahavior = [[UIPushBehavior alloc] initWithItems:@[self.ballImageView] mode:UIPushBehaviorModeInstantaneous];
    floatUpBeahavior.pushDirection = CGVectorMake(0, -0.5);
    floatUpBeahavior.active = NO;
    [animator addBehavior:floatUpBeahavior];
    self.floatUpBehavior = floatUpBeahavior;
    
    UIDynamicBehavior *scrollBehavior = [[UIDynamicBehavior alloc] init];
    scrollBehavior.action = ^ {
        [self updateViews];
    };
    [animator addBehavior:scrollBehavior];
    
    self.animator = animator;
}

//ビューを更新
- (void)updateViews
{
    for(UIView *scenary in self.sceneries){
        scenary.center = CGPointMake(scenary.center.x-SCROLL_SPEED, scenary.center.y);
        if(scenary.tag == TAG_BUILDING
           && (int)(scenary.frame.origin.x+scenary.frame.size.width)==(int)([self displaySize].width/2)){
            self.score++;
            [self updateScore];
        }
    }
    
    if (self.groundImageView.frame.origin.x <= -[self displaySize].width) {
        self.groundImageView.center = CGPointMake([self displaySize].width, self.groundImageView.center.y);
        
        for(UIView *scenary in [self.sceneries reverseObjectEnumerator]){
            if(scenary.frame.origin.x+scenary.frame.size.width < 0){
                [scenary removeFromSuperview];
                [self.sceneries removeObject:scenary];
            }
        }
        
        [self setBuildingViews];
    }
    
    //衝突判定
    for (UIView *scenary  in self.sceneries) {
        if(CGRectIntersectsRect(self.ballImageView.frame, scenary.frame)){
            NSLog(@"Game Over!");
            [self setGameOverLabel];
            [self.animator removeAllBehaviors];
            _viewStatus = NGGVIewStatusGameOver;
            break;
        }
    }
}

//障害物表示
- (void)setBuildingViews
{
    NSInteger offset = arc4random()%200-100;
    CGFloat downSideYPostion = [self displaySize].height/2 + offset;//[self displaySize].height/2 -+100
    
    UIImageView *upSideBuildingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"building"]];
    upSideBuildingImageView.frame = CGRectMake([self displaySize].width, downSideYPostion-400-INTER_SPACE, 60, 400);
    [self.view insertSubview:upSideBuildingImageView belowSubview:self.groundImageView];
    [self.sceneries addObject:upSideBuildingImageView];
    
    UIImageView *downSideBuildingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"building"]];
    downSideBuildingImageView.frame = CGRectMake([self displaySize].width, downSideYPostion, 60, 400);
    downSideBuildingImageView.tag = TAG_BUILDING;
    [self.view insertSubview:downSideBuildingImageView belowSubview:self.groundImageView];
    [self.sceneries addObject:downSideBuildingImageView];
}

//ゲームオーバー表示
- (void)setGameOverLabel
{
    UILabel *gameOverLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, [self displaySize].width, 200)];
    gameOverLabel.backgroundColor = [UIColor clearColor];
    gameOverLabel.textAlignment = NSTextAlignmentCenter;
    gameOverLabel.textColor = [UIColor whiteColor];
    gameOverLabel.text = @"GAME OVER";
    gameOverLabel.font = [UIFont boldSystemFontOfSize:32];
    [self.view addSubview:gameOverLabel];
    self.gameOverLabel = gameOverLabel;
}

//スタートラベル表示
- (void)setStanbyLabel
{
    UILabel *startLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, [self displaySize].width, 200)];
    startLabel.backgroundColor = [UIColor clearColor];
    startLabel.textAlignment = NSTextAlignmentCenter;
    startLabel.textColor = [UIColor whiteColor];
    startLabel.text = @"TAP TO START!";
    startLabel.font = [UIFont boldSystemFontOfSize:32];
    [self.view addSubview:startLabel];
    self.startLabel = startLabel;
}

//リセット
- (void)resetViewsAndAnimator
{
    [self.startLabel removeFromSuperview];
    [self.gameOverLabel removeFromSuperview];
    [self.sceneries makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.sceneries = [NSMutableArray array];
    
    [self.animator removeAllBehaviors];
    
    self.ballImageView.center = CGPointMake([self displaySize].width*1/4, [self displaySize].height/2);
    self.groundImageView.frame = CGRectMake(0, [self displaySize].height-40, 640, 40);
    [self.view insertSubview:self.groundImageView belowSubview:self.ballImageView];
    [self.sceneries addObject:self.groundImageView];
    
    self.score = 0;
    [self updateScore];
}

//スコア更新
- (void)updateScore
{
    self.scoreLabel.text = [NSString stringWithFormat:@"%d",(int)self.score];
}

#pragma mark - Touch Event
//これはControl+6で各メソッドにジャンプするための目印みたいなもの

//タッチイベント UIResponderで実装
//タッチ開始時に呼ばれる
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    if (_viewStatus == NGGVIewStatusAlive) {
        self.floatUpBehavior.active = YES;
    }else if(_viewStatus == NGGVIewStatusGameOver){
        [self setStanbyLabel];
        [self.gameOverLabel removeFromSuperview];
        _viewStatus = NGGVIewStatusStandby;
    }else if (_viewStatus == NGGVIewStatusStandby){
        [self resetViewsAndAnimator];
        [self setBehaviors];
        _viewStatus = NGGVIewStatusAlive;
    }
}

#pragma mark - UICollisionBehaviorDelegate

//衝突ビヘイビアのデリゲート
- (void)collisionBehavior:(UICollisionBehavior*)behavior beganContactForItem:(id <UIDynamicItem>)item withBoundaryIdentifier:(id <NSCopying>)identifier atPoint:(CGPoint)p
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)collisionBehavior:(UICollisionBehavior*)behavior endedContactForItem:(id <UIDynamicItem>)item withBoundaryIdentifier:(id <NSCopying>)identifier
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

@end
