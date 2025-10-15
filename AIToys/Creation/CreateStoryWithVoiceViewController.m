//
//  CreateStoryWithVoiceViewController.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/13.
//

#import "CreateStoryWithVoiceViewController.h"
#import "CreateStoryWithVoiceTableViewCell.h"

@interface CreateStoryWithVoiceViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *createImageView;
@property (weak, nonatomic) IBOutlet UILabel *storyStautsLabel;
@property (weak, nonatomic) IBOutlet UILabel *storyTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *chooseVoiceLabel;
@property (weak, nonatomic) IBOutlet UIButton *addNewVoiceBtn;
@property (weak, nonatomic) IBOutlet UITableView *voiceTabelView;
@property (weak, nonatomic) IBOutlet UIButton *saveStoryBtn;

@end

@implementation CreateStoryWithVoiceViewController





- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Create Story";
    self.view.backgroundColor = [UIColor colorWithRed:0xF6/255.0 green:0xF7/255.0 blue:0xFB/255.0 alpha:1.0];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0xF6/255.0 green:0xF7/255.0 blue:0xFB/255.0 alpha:1.0]];
    self.voiceTabelView.delegate = self;
    self.voiceTabelView.dataSource = self;
    self.addNewVoiceBtn.borderWidth = 1;
    self.addNewVoiceBtn.borderColor = HexOf(0x1EAAFD);
    
    UINib *CreateStoryWithVoiceTableViewCell = [UINib nibWithNibName:@"CreateStoryWithVoiceTableViewCell" bundle:nil];
    [self.voiceTabelView registerNib:CreateStoryWithVoiceTableViewCell forCellReuseIdentifier:@"CreateStoryWithVoiceTableViewCell"];
    
    
//    [self.voiceTabelView registerClass:[CreateStoryWithVoiceTableViewCell class] forCellReuseIdentifier:@"CreateStoryWithVoiceTableViewCell"];
    // Do any additional setup after loading the view from its nib.
}



#pragma mark - UITableView DataSource

// ✅ 添加：每个 cell 作为一个独立的 section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3; // 每个 section 只有 1 行
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CreateStoryWithVoiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CreateStoryWithVoiceTableViewCell" forIndexPath:indexPath];
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
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
