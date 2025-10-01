//
//  DeviceConnectingVC.m
//  AIToys
//
//  Created by qdkj on 2025/6/30.
//

#import "DeviceConnectingVC.h"

@interface DeviceConnectingVC ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong)NSTimer *timer;
@end

@implementation DeviceConnectingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.fd_prefersNavigationBarHidden = YES;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
}

- (void)updateProgress {
    if (self.progressView.progress < 1.0) {
        self.progressView.progress += 0.1;
    } else {
        [self.timer invalidate];
    }
}

//关闭按钮
- (IBAction)closeBtnClcik:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
