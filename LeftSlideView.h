//
//  LeftSlideView.h
//  dope
//
//  Created by 盛杰厚 on 2019/6/4.
//  Copyright © 2019 Dope. All rights reserved.
//

#import <UIKit/UIKit.h>



NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,UserType) {
    UserTypeMyCard = 0,
    UserTypeMyWallet = 1,
    UserTypeFeedBack = 2,
    UserTypeSystemSet = 3,
};



@interface LeftSlideView : UIView

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;



- (id)init;

- (void)showAnimation;

- (void)hiddenAnimation;

- (void)destory;

@end

NS_ASSUME_NONNULL_END
