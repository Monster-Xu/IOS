//
//  DeviceHavenFindCell.m
//  AIToys
//
//  Created by 乔不赖 on 2025/6/28.
//

#import "DeviceHavenFindCell.h"
#import "DeviceHavenFindItem.h"
@interface DeviceHavenFindCell()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UICollectionView *collectionView;

@end
@implementation DeviceHavenFindCell

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout.alloc init];
        layout.itemSize = CGSizeMake(64, 95);
//        layout.minimumLineSpacing = 12;
        layout.minimumInteritemSpacing = 12;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsMake(20, 15, 40, 15);
        _collectionView = [UICollectionView.alloc initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.showsVerticalScrollIndicator = false;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerNib:[UINib nibWithNibName:@"DeviceHavenFindItem" bundle:nil] forCellWithReuseIdentifier:@"cell"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.text = LocalString(@"发现设备...");
    [self.containerView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.containerView);
    }];
}

-(void)setDeviceList:(NSArray *)deviceList{
    _deviceList = deviceList;
    [self.collectionView reloadData];
}

#pragma mark - <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.deviceList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DeviceHavenFindItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *dic = self.deviceList[indexPath.row];
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:dic[@"icon"]] placeholderImage:[UIImage imageNamed:@"icon_find_device.png"]];
    NSString *name = dic[@"name"];
    cell.nameLabel.text = [PublicObj isEmptyObject:name] ? @"" : name;
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.itemClickBlock) {
        self.itemClickBlock(indexPath.row);
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
