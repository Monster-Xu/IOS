//
//  HomeDeviceListVC.m
//  AIToys
//
//  Created by qdkj on 2025/6/25.
//

#import "HomeDeviceListVC.h"
#import "HomeDeviceItem.h"
#import "ATFontManager.h"
#import "AnalyticsManager.h"
#import <ThingSmartMiniAppBizBundle/ThingSmartMiniAppBizBundle.h>

@interface HomeDeviceListVC ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *btnView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colletionBottomH;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *makeTopBtn;

@property (nonatomic, strong) UIButton *editBtn;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) NSArray <ThingSmartDeviceModel *>*deviceArr;
@property (nonatomic,strong)NSMutableArray <ThingSmartDeviceModel *>*dataArr;

//拖拉排序相关
@property (nonatomic, strong)UILongPressGestureRecognizer *longPress;//长按手势
@property (nonatomic,strong) HomeDeviceItem *cell ;
@property (nonatomic,strong)UIView *tempMoveCell;
@property (nonatomic,strong)NSIndexPath *indexPath;
@property (nonatomic,strong)NSIndexPath *moveIndexPath;
@property (nonatomic,assign)CGPoint lastPoint;
@property (nonatomic,assign)BOOL isMoved;//是否移动了

//选中的设备Id
@property (nonatomic,copy)NSString *selectDeviceId;
//修改之前的数据
@property (nonatomic, strong) NSArray <ThingSmartDeviceModel *>*historyArr;

// 🔒 安全数组操作方法声明
- (BOOL)safeInsertObject:(id)object atIndex:(NSUInteger)index toMutableArray:(NSMutableArray *)array;
- (id)safeObjectAtIndex:(NSUInteger)index fromArray:(NSArray *)array;
- (BOOL)safeRemoveObjectAtIndex:(NSUInteger)index fromMutableArray:(NSMutableArray *)array;

@end

@implementation HomeDeviceListVC


- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [[NSMutableArray alloc] init];
    }
    return _dataArr;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadData];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LocalString(@"设备管理") ;
    [self setupUI];
}

- (void)loadData{
    [self showHud];
    WEAK_SELF
    [self.home getHomeDataWithSuccess:^(ThingSmartHomeModel *homeModel) {
       
        weakSelf.deviceArr = [weakSelf.home.deviceList sortedArrayUsingComparator:^NSComparisonResult(ThingSmartDeviceModel *obj1, ThingSmartDeviceModel *obj2) {
            return obj1.homeDisplayOrder - obj2.homeDisplayOrder; // 或者使用 [obj1.age compare:obj2.age] 如果你想要更复杂的比较逻辑（比如字符串比较）
        }];
        weakSelf.historyArr = self.deviceArr;
        weakSelf.dataArr = [[NSMutableArray alloc] initWithArray:self.deviceArr];
        if(weakSelf.isEdit){
            weakSelf.isEdit = NO;
            [weakSelf dealViewEditStatus:NO];
        }
        [weakSelf hiddenHud];
        [weakSelf.collectionView reloadData];
    } failure:^(NSError *error) {
        [weakSelf hiddenHud];
    }];
    
}

-(void)setupUI{
    [self setRightBtn];
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout.alloc init];
    layout.itemSize = CGSizeMake((kScreenWidth - 30 - 12)/2, 150);
    layout.minimumLineSpacing = 12;
    layout.minimumInteritemSpacing = 12;
    layout.sectionInset = UIEdgeInsetsMake(12, 15, 12, 15);
    self.collectionView.collectionViewLayout = layout;
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerNib:[UINib nibWithNibName:@"HomeDeviceItem" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.deleteBtn setTitle:LocalString(@"删除设备") forState:0];
    [self.makeTopBtn setTitle:LocalString(@"置顶") forState:0];
    
}

//设置左侧按钮
-(void)setLeftBtn{
    self.cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,0, 40, 44)];
    [self.cancelBtn setTitle:LocalString(@"取消") forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:UIColorFromRGBA(000000, 0.9) forState:UIControlStateNormal];
    self.cancelBtn.titleLabel.font = [ATFontManager systemFontOfSize:15 weight:600];
    self.cancelBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.cancelBtn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* leftItem = [[UIBarButtonItem alloc]initWithCustomView:self.cancelBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

//设置右侧按钮
-(void)setRightBtn{
    self.editBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,0, 106, 44)];
    [self.editBtn setTitle:LocalString(@"管理") forState:UIControlStateNormal];
    [self.editBtn setTitleColor:mainColor forState:UIControlStateNormal];
    self.editBtn.titleLabel.font = [ATFontManager systemFontOfSize:15 weight:600];
    self.editBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight; // 设置内容水平对齐方式为右对齐
    [self.editBtn addTarget:self action:@selector(editBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc]initWithCustomView:self.editBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

//管理按钮
-(void)editBtnClick:(UIButton *)btn{
    [self dealViewEditStatus:self.isMoved];
    
}

//取消按钮
-(void)cancelBtnClick:(UIButton *)btn{
    [self dealViewEditStatus:NO];
}

//处理页面编辑页状态
- (void)dealViewEditStatus:(BOOL)deal{
    self.isEdit = !self.isEdit;
    [self.editBtn setTitle: self.isEdit ?  LocalString(@"完成"): LocalString(@"管理") forState:UIControlStateNormal];
    self.btnView.hidden = !self.isEdit;
    if(self.isEdit){
        [self setLeftBtn];
        self.colletionBottomH.constant = 68;
        [self.collectionView addGestureRecognizer:self.longPress];
    }else{
        [self setupNavBackBtn];
        self.colletionBottomH.constant = 0;
        [self.collectionView removeGestureRecognizer:self.longPress];
        self.selectDeviceId = nil;
        if(deal){
            [self sortDevice];
        }else{
            self.dataArr = [[NSMutableArray alloc] initWithArray:self.historyArr];
        }
    }
    [self.collectionView reloadData];
}

#pragma mark - <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HomeDeviceItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    // 🔒 安全获取设备模型
    ThingSmartDeviceModel *deviceModel = [self safeObjectAtIndex:indexPath.row fromArray:self.dataArr];
    if (!deviceModel) {
        NSLog(@"⚠️ [HomeDeviceListVC] 获取cell数据失败，索引: %ld", (long)indexPath.row);
        return cell; // 返回空cell，避免崩溃
    }
    
    cell.model = deviceModel;
    cell.index = indexPath.row;
    cell.isEdit = self.isEdit;
    cell.isSel = [deviceModel.devId isEqualToString:self.selectDeviceId];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 🔒 安全获取设备模型
    ThingSmartDeviceModel *deviceModel = [self safeObjectAtIndex:indexPath.row fromArray:self.dataArr];
    if (!deviceModel) {
        NSLog(@"⚠️ [HomeDeviceListVC] 点击事件获取设备失败，索引: %ld", (long)indexPath.row);
        return;
    }
    
    if(_isEdit){
        NSString *oldSelectDeviceId = self.selectDeviceId;
        self.selectDeviceId = deviceModel.devId;

        // 优化：只刷新相关的cell，而不是整个collection view
        NSMutableArray *indexPaths = [NSMutableArray array];

        // 添加当前选中的cell
        [indexPaths addObject:indexPath];

        // 添加之前选中的cell（如果存在）
        if (oldSelectDeviceId) {
            for (NSInteger i = 0; i < self.dataArr.count; i++) {
                ThingSmartDeviceModel *model = [self safeObjectAtIndex:i fromArray:self.dataArr];
                if (model && [model.devId isEqualToString:oldSelectDeviceId]) {
                    [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
                    break;
                }
            }
        }

        [self.collectionView reloadItemsAtIndexPaths:indexPaths];
    }else{
        //跳转小程序
        NSLog(@"[HomeDeviceListVC] 用户点击设备 - deviceId: %@, productId: %@", deviceModel.devId, deviceModel.productId);
        // 埋点上报：我的设备点击
        [[AnalyticsManager sharedManager] reportMyDeviceClickWithDeviceId:deviceModel.devId pid:deviceModel.productId];

        [[ThingMiniAppClient coreClient] openMiniAppByUrl:@"godzilla://ty7y8au1b7tamhvzij/pages/main/index" params:@{@"deviceId":deviceModel.devId,@"BearerId":(kMyUser.accessToken?:@""),@"langType":@"en",@"ownerId":@([[CoreArchive strForKey:KCURRENT_HOME_ID] integerValue])?:@"",@"envtype":@"dev"}];
    }
}

//拖动排序手势
-(void)pan:(UILongPressGestureRecognizer *)pan
{
    WEAK_SELF
    //判断手势状态
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{

//            self.isEdit = YES;
//            [self.collectionView reloadData];
            [self.collectionView performBatchUpdates:^{
                
            } completion:^(BOOL finished) {
                //判断手势落点位置是否在路径上
                weakSelf.indexPath = [weakSelf.collectionView indexPathForItemAtPoint:[pan locationOfTouch:0 inView:pan.view]];
                //得到该路径上的cell
                weakSelf.cell = (HomeDeviceItem *)[weakSelf.collectionView cellForItemAtIndexPath:weakSelf.indexPath];
                //截图cell，得到一个view
                weakSelf.tempMoveCell = [weakSelf.cell snapshotViewAfterScreenUpdates:NO];
                weakSelf.tempMoveCell.frame = weakSelf.cell.frame;
                
                 [weakSelf.collectionView addSubview:weakSelf.tempMoveCell];
                weakSelf.cell.hidden = YES;
                //记录当前手指位置
                weakSelf.lastPoint = [pan locationOfTouch:0 inView:pan.view];
                }];
            }
            break;
        case UIGestureRecognizerStateChanged:
        {
            //偏移量
            CGFloat tranX = [pan locationOfTouch:0 inView:pan.view].x - _lastPoint.x;
            CGFloat tranY = [pan locationOfTouch:0 inView:pan.view].y - _lastPoint.y;
            
            //更新cell位置
            _tempMoveCell.center = CGPointApplyAffineTransform(_tempMoveCell.center, CGAffineTransformMakeTranslation(tranX, tranY));
             //记录当前手指位置
            _lastPoint = [pan locationOfTouch:0 inView:pan.view];
            
            for (UICollectionViewCell *cell in [self.collectionView visibleCells]) {
                //剔除隐藏的cell
                if ([self.collectionView indexPathForCell:cell] == self.indexPath) {
                    continue;
                }
                //计算中心，如果相交一半就移动
                CGFloat spacingX = fabs(_tempMoveCell.center.x - cell.center.x);
                CGFloat spacingY = fabs(_tempMoveCell.center.y - cell.center.y);
                if (spacingX <= _tempMoveCell.bounds.size.width / 2.0f && spacingY <= _tempMoveCell.bounds.size.height / 2.0f){
                    self.moveIndexPath = [self.collectionView indexPathForCell:cell];
                    //更新数据源（移动前必须更新数据源）
                    [self updateDataSource];
                    //移动cell
                    [self.collectionView moveItemAtIndexPath:self.indexPath toIndexPath:self.moveIndexPath];
                   //设置移动后的起始indexPath
                    self.indexPath = self.moveIndexPath;
                    break;
                }
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [self.collectionView performBatchUpdates:^{
                
            } completion:^(BOOL finished) {
                weakSelf.cell  = (HomeDeviceItem *)[weakSelf.collectionView cellForItemAtIndexPath:weakSelf.indexPath];
                [UIView animateWithDuration:0.1 animations:^{
                    weakSelf.tempMoveCell.center = weakSelf.cell.center;
                } completion:^(BOOL finished) {
                    [weakSelf.tempMoveCell removeFromSuperview];
                    weakSelf.cell.hidden = NO;
                    // 移除不必要的延迟，直接更新
                    [weakSelf.collectionView reloadData];
                }];

            }];
        }
            break;
        default:
            break;
    }
}

-(void)updateDataSource
{
    // 🔒 安全检查：确保 indexPath 和 moveIndexPath 有效
    if (!self.indexPath || !self.moveIndexPath) {
        NSLog(@"⚠️ [HomeDeviceListVC] 拖拽排序失败: indexPath 或 moveIndexPath 为nil");
        return;
    }
    
    if (self.indexPath.row >= self.dataArr.count) {
        NSLog(@"⚠️ [HomeDeviceListVC] 拖拽排序失败: 源索引 %ld 超出数组范围 %lu", (long)self.indexPath.row, (unsigned long)self.dataArr.count);
        return;
    }
    
    self.isMoved = YES;
    
    // 🔒 安全获取要移动的对象
    id objc = [self safeObjectAtIndex:self.indexPath.row fromArray:self.dataArr];
    if (!objc) {
        NSLog(@"⚠️ [HomeDeviceListVC] 拖拽排序失败: 无法获取源对象");
        return;
    }
    
    // 🔒 安全移除源位置的对象
    if (![self safeRemoveObjectAtIndex:self.indexPath.row fromMutableArray:self.dataArr]) {
        NSLog(@"⚠️ [HomeDeviceListVC] 拖拽排序失败: 无法移除源对象");
        return;
    }
    
    // 🔒 安全插入到目标位置
    // 注意：移除元素后，如果目标索引大于源索引，需要调整目标索引
    NSUInteger targetIndex = self.moveIndexPath.row;
    if (targetIndex > self.indexPath.row) {
        targetIndex = targetIndex - 1; // 因为前面移除了一个元素，索引需要减1
    }
    
    if (![self safeInsertObject:objc atIndex:targetIndex toMutableArray:self.dataArr]) {
        NSLog(@"⚠️ [HomeDeviceListVC] 拖拽排序失败: 无法插入到目标位置，尝试恢复数据");
        // 尝试恢复数据：重新插入到原位置
        [self safeInsertObject:objc atIndex:self.indexPath.row toMutableArray:self.dataArr];
        self.isMoved = NO;
        return;
    }
    
    NSLog(@"✅ [HomeDeviceListVC] 拖拽排序成功: 从索引 %ld 移动到 %lu", (long)self.indexPath.row, (unsigned long)targetIndex);
}

//删除设备
- (IBAction)deleteDeviceBtnClick:(id)sender {
    if([PublicObj isEmptyObject:self.selectDeviceId]){
        [SVProgressHUD showErrorWithStatus:LocalString(@"请选择设备")];
        return;
    }
    WEAK_SELF
    [LGBaseAlertView showAlertWithTitle:LocalString(@"确定要删除设备吗？")  content:nil cancelBtnStr:LocalString(@"取消") confirmBtnStr:LocalString(@"删除") confirmBlock:^(BOOL isValue, id obj) {
        if (isValue){
            ThingSmartDevice *device = [ThingSmartDevice deviceWithDeviceId:self.selectDeviceId];
            [device resetFactory:^{
                NSLog(@"remove success");
                [SVProgressHUD showSuccessWithStatus:LocalString(@"删除成功")];
                
                // 🔒 安全查找并删除设备
                NSInteger targetIndex = NSNotFound;
                for (NSInteger i = 0; i < weakSelf.dataArr.count; i++) {
                    ThingSmartDeviceModel *deviceModel = [weakSelf safeObjectAtIndex:i fromArray:weakSelf.dataArr];
                    if (deviceModel && [weakSelf.selectDeviceId isEqualToString:deviceModel.devId]) {
                        targetIndex = i;
                        break;
                    }
                }
                
                if (targetIndex != NSNotFound) {
                    if ([weakSelf safeRemoveObjectAtIndex:targetIndex fromMutableArray:weakSelf.dataArr]) {
                        weakSelf.historyArr = [weakSelf.dataArr copy];
                        [weakSelf.collectionView reloadData];
                        NSLog(@"✅ [HomeDeviceListVC] 设备删除成功");
                    } else {
                        NSLog(@"⚠️ [HomeDeviceListVC] 数组删除失败");
                    }
                } else {
                    NSLog(@"⚠️ [HomeDeviceListVC] 未找到要删除的设备");
                }
                
                //删除设备不退出编辑状态
//                [weakSelf dealViewEditStatus:NO];
            } failure:^(NSError *error) {
                NSLog(@"remove failure: %@", error);
            }];
        }
    }];
    
}

//置顶设备
- (IBAction)setDeviceTop:(id)sender {
    if([PublicObj isEmptyObject:self.selectDeviceId]){
        [SVProgressHUD showErrorWithStatus:LocalString(@"请选择设备")];
        return;
    }
    
    // 🔒 安全查找要置顶的设备
    id objc = nil;
    NSInteger targetIndex = NSNotFound;
    
    for (NSInteger i = 0; i < self.dataArr.count; i++) {
        ThingSmartDeviceModel *device = [self safeObjectAtIndex:i fromArray:self.dataArr];
        if (device && [self.selectDeviceId isEqualToString:device.devId]) {
            targetIndex = i;
            objc = device;
            break;
        }
    }
    
    // 🔒 验证找到的设备
    if (targetIndex == NSNotFound || !objc) {
        NSLog(@"⚠️ [HomeDeviceListVC] 置顶失败: 未找到选中的设备 %@", self.selectDeviceId);
        [SVProgressHUD showErrorWithStatus:LocalString(@"设备不存在，无法置顶")];
        return;
    }
    
    // 🔒 如果已经在顶部，无需操作
    if (targetIndex == 0) {
        NSLog(@"ℹ️ [HomeDeviceListVC] 设备已在顶部，无需置顶");
        [SVProgressHUD showInfoWithStatus:LocalString(@"设备已在顶部")];
        return;
    }
    
    // 🔒 安全移除原位置的设备
    if (![self safeRemoveObjectAtIndex:targetIndex fromMutableArray:self.dataArr]) {
        NSLog(@"⚠️ [HomeDeviceListVC] 置顶失败: 无法移除设备");
        [SVProgressHUD showErrorWithStatus:LocalString(@"操作失败，请重试")];
        return;
    }
    
    // 🔒 安全插入到顶部
    if (![self safeInsertObject:objc atIndex:0 toMutableArray:self.dataArr]) {
        NSLog(@"⚠️ [HomeDeviceListVC] 置顶失败: 无法插入到顶部，尝试恢复");
        // 尝试恢复：重新插入到原位置
        [self safeInsertObject:objc atIndex:targetIndex toMutableArray:self.dataArr];
        [SVProgressHUD showErrorWithStatus:LocalString(@"操作失败，请重试")];
        return;
    }
    
    [self.collectionView reloadData];
    self.isMoved = YES;
    
    NSLog(@"✅ [HomeDeviceListVC] 设备置顶成功: %@", self.selectDeviceId);
    [SVProgressHUD showSuccessWithStatus:LocalString(@"置顶成功")];
}

//设备排序接口
-(void)sortDevice{
    NSMutableArray *orderList = [NSMutableArray array];
    //device's bizType = @"6" group's bizType = @"5".
    for (NSInteger i = self.dataArr.count-1; i>=0; i--) {
        // 🔒 安全获取设备模型
        ThingSmartDeviceModel *deviceModel = [self safeObjectAtIndex:i fromArray:self.dataArr];
        if (deviceModel && deviceModel.devId) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:deviceModel.devId forKey:@"bizId"];
            [dic setObject:@"6" forKey:@"bizType"];
            [orderList addObject:dic];
        } else {
            NSLog(@"⚠️ [HomeDeviceListVC] 排序时跳过无效设备，索引: %ld", (long)i);
        }
    }
//    for (ThingSmartDeviceModel *model in self.dataArr) {
//        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//        [dic setObject:model.devId forKey:@"bizId"];
//        [dic setObject:@"6" forKey:@"bizType"];
//        [orderList addObject:dic];
//    }
    [self showHud];
    WEAK_SELF
    //设备或群组排序
    [self.home sortDeviceOrGroupWithOrderList:orderList success:^{
        NSLog(@"sort device or group success");
        [self hiddenHud];
        [SVProgressHUD showSuccessWithStatus:LocalString(@"操作成功")];
        weakSelf.historyArr = weakSelf.dataArr;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HomeDeviceRefresh" object:nil];
    } failure:^(NSError *error) {
        [self hiddenHud];
        NSLog(@"sort device or group failure: %@", error);
    }];
}

#pragma mark - 🔒 安全数组操作方法

// 安全插入对象到可变数组
- (BOOL)safeInsertObject:(id)object atIndex:(NSUInteger)index toMutableArray:(NSMutableArray *)array {
    // 参数有效性检查
    if (!array || ![array isKindOfClass:[NSMutableArray class]]) {
        NSLog(@"⚠️ [HomeDeviceListVC] 安全插入失败: 数组为nil或不是NSMutableArray类型");
        return NO;
    }
    
    if (!object) {
        NSLog(@"⚠️ [HomeDeviceListVC] 安全插入失败: 要插入的对象为nil");
        return NO;
    }
    
    // 索引范围检查
    if (index > array.count) {
        NSLog(@"⚠️ [HomeDeviceListVC] 安全插入失败: 索引 %lu 超出范围 [0-%lu]", (unsigned long)index, (unsigned long)array.count);
        return NO;
    }
    
    // 执行插入操作
    @try {
        [array insertObject:object atIndex:index];
        NSLog(@"✅ [HomeDeviceListVC] 成功插入对象到索引 %lu", (unsigned long)index);
        return YES;
    } @catch (NSException *exception) {
        NSLog(@"❌ [HomeDeviceListVC] 插入对象异常: %@", exception.reason);
        return NO;
    }
}

// 安全获取数组中的对象
- (id)safeObjectAtIndex:(NSUInteger)index fromArray:(NSArray *)array {
    if (!array || ![array isKindOfClass:[NSArray class]]) {
        NSLog(@"⚠️ [HomeDeviceListVC] 安全获取失败: 数组为nil或不是NSArray类型");
        return nil;
    }
    
    if (index >= array.count) {
        NSLog(@"⚠️ [HomeDeviceListVC] 安全获取失败: 索引 %lu 超出范围 [0-%lu)", (unsigned long)index, (unsigned long)array.count);
        return nil;
    }
    
    @try {
        return array[index];
    } @catch (NSException *exception) {
        NSLog(@"❌ [HomeDeviceListVC] 获取对象异常: %@", exception.reason);
        return nil;
    }
}

// 安全移除数组中指定索引的对象
- (BOOL)safeRemoveObjectAtIndex:(NSUInteger)index fromMutableArray:(NSMutableArray *)array {
    if (!array || ![array isKindOfClass:[NSMutableArray class]]) {
        NSLog(@"⚠️ [HomeDeviceListVC] 安全移除失败: 数组为nil或不是NSMutableArray类型");
        return NO;
    }
    
    if (index >= array.count) {
        NSLog(@"⚠️ [HomeDeviceListVC] 安全移除失败: 索引 %lu 超出范围 [0-%lu)", (unsigned long)index, (unsigned long)array.count);
        return NO;
    }
    
    @try {
        [array removeObjectAtIndex:index];
        NSLog(@"✅ [HomeDeviceListVC] 成功移除索引 %lu 的对象", (unsigned long)index);
        return YES;
    } @catch (NSException *exception) {
        NSLog(@"❌ [HomeDeviceListVC] 移除对象异常: %@", exception.reason);
        return NO;
    }
}

@end
