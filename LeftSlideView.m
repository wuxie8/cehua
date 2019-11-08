//
//  LeftSlideView.m
//  dope
//
//  Created by 盛杰厚 on 2019/6/4.
//  Copyright © 2019 Dope. All rights reserved.
//

#import "LeftSlideView.h"
#import "UserModel.h"
#import "SetUpViewController.h"
#import "NewFriendListViewController.h"
#import "NewAllCircleViewController.h"
#import "QQPersonViewController.h"
#import "EOTextView.h"
#import "EONotiView.h"
#import <UMShare/UMShare.h>
#import "BottomAlertView.h"
#import "UserSocialManager.h"

@interface LeftSlideView ()

@property (weak, nonatomic) IBOutlet UIImageView *imageViewIcon;

@property (weak, nonatomic) IBOutlet UILabel *labelName;

@property (weak, nonatomic) IBOutlet UILabel *labelDynamics;

@property (weak, nonatomic) IBOutlet UILabel *labelCircle;

@property (weak, nonatomic) IBOutlet UILabel *labelMyFriends;

@property (weak, nonatomic) IBOutlet UIView *viewAlpha;

@property (weak, nonatomic) IBOutlet UIButton *btnInvicate;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBtnInvicateBottom;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintImageViewIconTop;


@end

@implementation LeftSlideView{
    UserModel *_userModel;
    
    UITapGestureRecognizer *tap;
}



- (id)init{
    self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([LeftSlideView class]) owner:nil options:nil] firstObject];
    self.backgroundColor = [UIColor clearColor];
    self.constraintImageViewIconTop.constant = 62 + (IS_IPHONE_X ? 44 : 0);
    UIWindow *wd = [UIApplication sharedApplication].keyWindow;
    self.viewAlpha.backgroundColor  = [UIColor blackColor];
    self.viewAlpha.alpha = 0;
    self.viewAlpha.hidden = YES;
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenAnimation)];
    [self.viewAlpha addGestureRecognizer:tap];
    
    self.frame = CGRectMake(- screenWidth, 0, screenWidth, screenHeight);
    [wd addSubview:self];
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [wd addGestureRecognizer:self.panGesture];
    return self;
}

- (void)destory{
    UIWindow *wd = [UIApplication sharedApplication].keyWindow;
    [tap removeTarget:self action:@selector(hiddenAnimation)];
    [self.panGesture removeTarget:self action:@selector(move:)];
    [wd removeGestureRecognizer:self.panGesture];
    [self.viewAlpha removeGestureRecognizer:tap];
    [self.viewAlpha removeFromSuperview];
    self.viewAlpha = nil;
    [self removeFromSuperview];
}

- (void)awakeFromNib{
    [super awakeFromNib];
    ViewRadius(self.btnInvicate, 27);

    [self.imageViewIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMG_URL,Context.currentUser.userAvatar]] placeholderImage:[UIImage imageNamed:@"headImage1"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.imageViewIcon.image =[UtilTools imageWithRoundCorner:image cornerRadius:kSCRATIO(55) size:CGSizeMake(kSCRATIO(110), kSCRATIO(110))];
        
    }];
    self.imageViewIcon.userInteractionEnabled = YES;
    __weak typeof(self) weakSelf = self;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf pushUserHomePageVc];
    }];
    [self.imageViewIcon addGestureRecognizer:tapGesture];
    self.labelName.text = Context.currentUser.userName;
    self.constraintBtnInvicateBottom.constant = BOTTOM_HEIGHT + 30;
    [[UserSocialManager shareInstance] requestUserSocialSuc:^{
        [self setLabelContent];
    }];

}

- (void)setLabelContent{
    self.labelCircle.text = [NSString stringWithFormat:@"%@",[[UserSocialManager shareInstance] circleCount]];
    self.labelMyFriends.text = [NSString stringWithFormat:@"%@",[[UserSocialManager shareInstance] friendCount]];
    self.labelDynamics.text = [NSString stringWithFormat:@"%@",[[UserSocialManager shareInstance] squareInfoCount]];
}

- (void)move:(UIPanGestureRecognizer *)pan{
    CGPoint offSet = [pan translationInView:pan.view];
    CGPoint center = self.center;
    if (self.origin.x >= 0 && offSet.x > 0) {
        CGRect fra = self.frame;
        fra.origin.x = 0;
        self.frame = fra;
    }else{
        center.x = center.x + offSet.x;
        self.center = center;
    }
    BOOL isLeft = NO;
    CGPoint velocity = [pan velocityInView:pan.view];
    if (velocity.x < 0) {
        isLeft = YES;
    }
    
    [pan setTranslation:CGPointZero inView:pan.view];
    if (pan.state == UIGestureRecognizerStateEnded) {
        if (!isLeft) {
            if (self.frame.origin.x >= (- screenWidth * 3 /4.0 + 20)) {
                [self showAnimation];
            }else{
                [self hiddenAnimation];
            }
        }else{
            [self hiddenAnimation];
        }
        
    }
}

- (void)showAnimation{
    UIWindow *wd = [UIApplication sharedApplication].keyWindow;
    [UIView animateWithDuration:0.25 animations:^{
        CGRect fra = self.frame;
        fra.origin.x = 0;
        self.frame = fra;
        self.viewAlpha.alpha = 0.3;
       
    } completion:^(BOOL finished) {
        self.viewAlpha.hidden = NO;
        [self.viewAlpha mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(wd);
        }];
    }];
}

- (void)hiddenAnimation{
    self.viewAlpha.hidden = YES;
   
    [UIView animateWithDuration:0.25 animations:^{
        CGRect fra = self.frame;
        fra.origin.x = - screenWidth;
        self.frame = fra;
        self.viewAlpha.alpha = 0;
    } completion:^(BOOL finished) {
        [self.viewAlpha mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }];
}

- (void)pushUserHomePageVc{
    QQPersonViewController *qqPersonVc = [[QQPersonViewController alloc] init];
    qqPersonVc.hidesBottomBarWhenPushed = YES;
    qqPersonVc.userId = [NSString stringWithFormat:@"%@", Context.currentUser.userId];
    qqPersonVc.isPerson = NO;
    [[[[AppHelper shareInstance] visibleViewController] navigationController] pushViewController:qqPersonVc animated:YES];
}

- (IBAction)clickedMyDynamic:(id)sender {
    //我的动态
    [self pushUserHomePageVc];
}

- (IBAction)clickedMyCircle:(id)sender {
    //我的圈子
    NewAllCircleViewController *myCircleVc = [[NewAllCircleViewController alloc] init];
    myCircleVc.isMine = YES;
    myCircleVc.hidesBottomBarWhenPushed = YES;
    [[[[AppHelper shareInstance] visibleViewController] navigationController] pushViewController:myCircleVc animated:YES];
}

- (IBAction)clickedMyFriends:(id)sender {
    //我的朋友
    NewFriendListViewController *myFriendVc = [[NewFriendListViewController alloc] init];
    myFriendVc.hidesBottomBarWhenPushed = YES;
    [[[[AppHelper shareInstance] visibleViewController] navigationController] pushViewController:myFriendVc animated:YES];
}

- (IBAction)clickedMyCard:(id)sender {
    WebVC *vc = [[WebVC alloc] init];
    [vc setNavTitle:@"圈子排行榜"];
    
    [vc loadFromURLStr:[NSString stringWithFormat:@"http://h5.dopesns.com/circleRank.html?token=%@",Context.currentUser.token]];
    vc.isRight=YES;
    vc.hidesBottomBarWhenPushed=YES;
    [[[[AppHelper shareInstance] visibleViewController] navigationController] pushViewController:vc animated:NO];
}


- (IBAction)clickedMyCollect:(id)sender {

}




- (IBAction)clickFeedBack:(id)sender {
    //我的反馈

    [self hiddenAnimation];
    [self feedback];
}

-(void)feedback{
    UIView *bgV = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    bgV.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    [[UIApplication sharedApplication].keyWindow addSubview:bgV];
    
    
    EOTextView *textView = [[EOTextView alloc] initWithFrame:CGRectMake(0, HEIGHT, WIDTH, HEIGHT+BOTTOM_HEIGHT-kStatusBarHeight) ];
    __weak EOTextView *weakTextView = textView;
    
    [textView setCancleBlock:^{
        [UIView animateWithDuration:0.25 animations:^{
            weakTextView.top = HEIGHT+BOTTOM_HEIGHT;
            
        } completion:^(BOOL finished) {
            [bgV removeFromSuperview];
            
        }];
    }];
    [textView setSureBlock:^(NSString * _Nonnull text) {
        if (text.length == 0) {
            [MessageAlertView showErrorMessage:@"内容不能为空"];
            return ;
        }
        [[NetWorkManager sharedManager ]postData:@"system/system-rest/feedback" parameters:@{@"userId":Context.currentUser.userId,@"content":text} success:^(NSURLSessionDataTask *task, id responseObject) {
            UIView *bgV1 = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            bgV1.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
            [[UIApplication sharedApplication].keyWindow addSubview:bgV1];
            
            EONotiView *notiV = [[EONotiView alloc] initWithFrame:CGRectMake(kSCRATIO(32), HEIGHT, kSCRATIO(305), kSCRATIO(325))];
            
            NSString *content =[NSString stringWithFormat:@"反馈建议提交成功"] ;
            NSString *btnTitle = @"好的";
            
            notiV.content = content;
            notiV.btnTitle = btnTitle;
            notiV.action.titleLabel.font = [UIFont boldSystemFontOfSize:kSCRATIO(16)];
            
            notiV.contentL.font=[UIFont boldSystemFontOfSize:kSCRATIO(18)];
            [notiV.icon  setImage:[UIImage imageNamed:@"notiVIcon"]];
            notiV.action.layer.cornerRadius=kSCRATIO(25);
            notiV.action.layer.masksToBounds=YES;
            notiV.action.backgroundColor=ColorFFE131;
            [notiV.action setTitleColor:ColorBlack forState:0];
            [notiV.icon mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.height.mas_equalTo(kSCRATIO(88));
            }];
            [notiV.action mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(kSCRATIO(164));
                make.height.mas_equalTo(kSCRATIO(50));
            }];
            __weak EONotiView *weakView = notiV;
            notiV.sureBlock = ^{
                [UIView animateWithDuration:0.5 animations:^{
                    weakTextView.top = HEIGHT+BOTTOM_HEIGHT;
                    [weakView removeFromSuperview];
                    
                } completion:^(BOOL finished) {
                    [bgV1 removeFromSuperview];
                    [bgV removeFromSuperview];
                    
                }];
                
            };
            [[UIApplication sharedApplication].keyWindow addSubview:notiV];
            
            [UIView animateWithDuration:0.2f animations:^{
                notiV.centerX = WIDTH * 0.5;
                
                notiV.centerY = HEIGHT * 0.5;
            }];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
        
        
        
        
    }];
    
    textView.textAmount=@"100";
    textView.titleLabel.text=@"反馈意见";
    textView.alertString=@"反馈意见";
    textView.randomButton1.hidden=YES;
    
    textView.textView.placeholderText=@"说说你对我们产品的意见和建议吧";
    [textView.action setTitle:@"提交" forState:0];
    [bgV addSubview:textView];
    
    [UIView animateWithDuration:0.15 animations:^{
        textView.bottom = HEIGHT+BOTTOM_HEIGHT;
    }];
}
- (IBAction)clickSystemSet:(id)sender {
    //系统设置
    SetUpViewController *setupVc = [[SetUpViewController alloc] init];
    setupVc.hidesBottomBarWhenPushed = YES;
    [[[[AppHelper shareInstance] visibleViewController] navigationController] pushViewController:setupVc animated:YES];
    
}

- (IBAction)clickInvicateFriendGainRedPacket:(id)sender {
    //邀请好友拿红包
       [self hiddenAnimation];
    BottomAlertView *alterView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([BottomAlertView class]) owner:nil options:nil] firstObject];
    alterView.arrTitles = @[@"微信好友",@"QQ好友",@"微信朋友圈",@"QQ空间",@"新浪微博"];
    NSArray *pictureNames = @[@"weixinfriends.png",@"qqfriends.png",@"weixinfriendcircle.png",@"qqspace.png",@"xinlangshare.png"];
    alterView.arrImageNames = pictureNames;
    alterView.seletedCallBack = ^(NSInteger index) {
        UMSocialPlatformType type = UMSocialPlatformType_UnKnown;
        if (index == 0) {
            type =  UMSocialPlatformType_WechatSession ;
        }
        if (index == 1) {
            type = UMSocialPlatformType_QQ;
        }
        if (index == 2) {
            type = UMSocialPlatformType_WechatTimeLine;
        }
        if (index == 3) {
            type = UMSocialPlatformType_Qzone;
        }
        if (index==4) {
            type = UMSocialPlatformType_Sina;
            
        }
        NSString *urlKey = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMG_URL,Context.currentUser.userAvatar]]];
        UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlKey];
        if (!image) {
            image = [UIImage imageNamed:@"login_Logo.png"];
        }
        UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
        UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:@"Hey，分享一个社交APP给你" descr:@"最放肆最有趣的人儿都在这儿" thumImage:image];
        shareObject.webpageUrl = @"http://www.dopesns.com/";
        
        messageObject.shareObject = shareObject;
        if ([[UMSocialManager defaultManager] isSupport:type]) {
            [[UMSocialManager defaultManager] shareToPlatform:type messageObject:messageObject currentViewController:nil completion:^(id data, NSError *error) {
                if (error) {
                    [MessageAlertView showErrorMessage:@"分享失败"];
                } else {
                    [MessageAlertView showErrorMessage:@"分享成功"];
                }
                
            }];
        }else{
            [MessageAlertView showErrorMessage:@"未安装应用"];
        }
    };
    [alterView show];
    
    return;
}







@end
