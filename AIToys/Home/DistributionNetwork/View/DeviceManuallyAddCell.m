//
//  DeviceManuallyAddCell.m
//  AIToys
//
//  Created by 乔不赖 on 2025/6/28.
//

#import "DeviceManuallyAddCell.h"
#import "DeviceManuallyAddItem.h"

@interface DeviceManuallyAddCell()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UIView *picView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *picH;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) UICollectionView *collectionView;

@end
@implementation DeviceManuallyAddCell

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout.alloc init];
        layout.itemSize = CGSizeMake((kScreenWidth - 60 - 36)/4, 88);
        layout.minimumLineSpacing = 12;
        layout.minimumInteritemSpacing = 12;
        layout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
        _collectionView = [UICollectionView.alloc initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.showsVerticalScrollIndicator = false;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerNib:[UINib nibWithNibName:@"DeviceManuallyAddItem" bundle:nil] forCellWithReuseIdentifier:@"cell"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.text = LocalString(@"手动添加");
    [self.picView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.picView);
    }];
}

-(void)setDataArr:(NSArray<FindDollModel *> *)dataArr{
    _dataArr = dataArr;
    if (dataArr.count == 0) {
        self.picH.constant = 0;
    }else{
        NSInteger row = dataArr.count%4 == 0 ? dataArr.count/4 : dataArr.count/4 +1;
        if (dataArr.count <= 4) {
            self.picH.constant = 118;
        }else{
            self.picH.constant = 100 *row - 12 + 30;
        }
    }
    [self.collectionView reloadData];
}

#pragma mark - <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DeviceManuallyAddItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
//    cell.nameLabel.text = self.dataArr[indexPath.row].name;
//    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:self.dataArr[indexPath.row].coverImg] placeholderImage:[UIImage imageNamed:@"icon_find_device.png"]];
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
