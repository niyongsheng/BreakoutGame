//
//  ViewController.h
//  Blocker
//
//  Created by 倪刚 on 2017/4/29.
//  Copyright © 2017年 倪刚. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *ball;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *blocks;

@property (weak, nonatomic) IBOutlet UIImageView *paddle;

@property (weak, nonatomic) IBOutlet UILabel *msgLabel;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGR;

    
//- (IBAction)onPaddlePan:(UIPanGestureRecognizer *)sender;
- (IBAction)onPaddlePan:(UIPanGestureRecognizer *)sender;

- (IBAction)onTapScreen:(id)sender;

@end

