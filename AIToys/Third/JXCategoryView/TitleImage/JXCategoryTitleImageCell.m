//
//  JXCategoryImageCell.m
//  JXCategoryView
//
//  Created by jiaxin on 2018/8/8.
//  Copyright © 2018年 jiaxin. All rights reserved.
//

#import "JXCategoryTitleImageCell.h"
#import "JXCategoryTitleImageCellModel.h"

@interface JXCategoryTitleImageCell()
@property (nonatomic, strong) id currentImageInfo;
@property (nonatomic, strong) NSString *currentImageName;
@property (nonatomic, strong) NSURL *currentImageURL;
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) NSLayoutConstraint *imageViewWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *imageViewHeightConstraint;
@end

@implementation JXCategoryTitleImageCell

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.currentImageInfo = nil;
    self.currentImageName = nil;
    self.currentImageURL = nil;
}

- (void)initializeViews {
    [super initializeViews];

    [self.titleLabel removeFromSuperview];

    _imageView = [[UIImageView alloc] init];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageViewWidthConstraint = [self.imageView.widthAnchor constraintEqualToConstant:0];
    self.imageViewWidthConstraint.active = YES;
    self.imageViewHeightConstraint = [self.imageView.heightAnchor constraintEqualToConstant:0];
    self.imageViewHeightConstraint.active = YES;

    _stackView = [[UIStackView alloc] init];
    self.stackView.alignment = UIStackViewAlignmentCenter;
    [self.contentView addSubview:self.stackView];
    self.stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.stackView.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor].active = YES;
    [self.stackView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
}

//- (void)layoutSubviews {
//    [super layoutSubviews];
//
//    JXCategoryTitleImageCellModel *myCellModel = (JXCategoryTitleImageCellModel *)self.cellModel;
//    self.titleLabel.hidden = NO;
//    self.imageView.hidden = NO;
//    CGSize imageSize = myCellModel.imageSize;
//    self.imageView.bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
//    self.imageView.layer.masksToBounds = YES;
//    if(myCellModel.imageNeedLayer){
//        self.imageView.layer.cornerRadius = imageSize.height * 0.5;
//    }
//    switch (myCellModel.imageType) {
//
//        case JXCategoryTitleImageType_TopImage:
//        {
//            CGFloat contentHeight = imageSize.height + myCellModel.titleImageSpacing + self.titleLabel.bounds.size.height;
//            self.imageView.center = CGPointMake(self.contentView.center.x, (self.contentView.bounds.size.height - contentHeight)/2 + imageSize.height/2);
//            self.titleLabel.center = CGPointMake(self.contentView.center.x, CGRectGetMaxY(self.imageView.frame) + myCellModel.titleImageSpacing + self.titleLabel.bounds.size.height/2);
//        }
//            break;
//
//        case JXCategoryTitleImageType_LeftImage:
//        {
//            CGFloat contentWidth = imageSize.width + myCellModel.titleImageSpacing + self.titleLabel.bounds.size.width;
//            self.imageView.center = CGPointMake((self.contentView.bounds.size.width - contentWidth)/2 + imageSize.width/2, self.contentView.center.y);
//            self.titleLabel.center = CGPointMake(CGRectGetMaxX(self.imageView.frame) + myCellModel.titleImageSpacing + self.titleLabel.bounds.size.width/2, self.contentView.center.y);
//        }
//            break;
//
//        case JXCategoryTitleImageType_BottomImage:
//        {
//            CGFloat contentHeight = imageSize.height + myCellModel.titleImageSpacing + self.titleLabel.bounds.size.height;
//            self.titleLabel.center = CGPointMake(self.contentView.center.x, (self.contentView.bounds.size.height - contentHeight)/2 + self.titleLabel.bounds.size.height/2);
//            self.imageView.center = CGPointMake(self.contentView.center.x, CGRectGetMaxY(self.titleLabel.frame) + myCellModel.titleImageSpacing + imageSize.height/2);
//        }
//            break;
//
//        case JXCategoryTitleImageType_RightImage:
//        {
//            CGFloat contentWidth = imageSize.width + myCellModel.titleImageSpacing + self.titleLabel.bounds.size.width;
//            self.titleLabel.center = CGPointMake((self.contentView.bounds.size.width - contentWidth)/2 + self.titleLabel.bounds.size.width/2, self.contentView.center.y);
//            self.imageView.center = CGPointMake(CGRectGetMaxX(self.titleLabel.frame) + myCellModel.titleImageSpacing + imageSize.width/2, self.contentView.center.y);
//        }
//            break;
//
//        case JXCategoryTitleImageType_OnlyImage:
//        {
//            self.titleLabel.hidden = YES;
//            self.imageView.center = self.contentView.center;
//        }
//            break;
//
//        case JXCategoryTitleImageType_OnlyTitle:
//        {
//            self.imageView.hidden = YES;
//            self.titleLabel.center = self.contentView.center;
//        }
//            break;
//
//        default:
//            break;
//    }
//}

- (void)reloadData:(JXCategoryBaseCellModel *)cellModel {
    [super reloadData:cellModel];
    JXCategoryTitleImageCellModel *myCellModel = (JXCategoryTitleImageCellModel *)cellModel;
    self.titleLabel.hidden = NO;
    self.imageView.hidden = NO;
    [self.stackView removeArrangedSubview:self.titleLabel];
    [self.stackView removeArrangedSubview:self.imageView];
    
    CGSize imageSize = myCellModel.imageSize;
    self.imageViewWidthConstraint.constant = imageSize.width;
    self.imageViewHeightConstraint.constant = imageSize.height;
    self.imageView.layer.masksToBounds = YES;
    if(myCellModel.imageNeedLayer){
        self.imageView.layer.cornerRadius = imageSize.height * 0.5;
    }
    self.stackView.spacing = myCellModel.titleImageSpacing;
    
//    if (myCellModel.imageName != nil) {
//        self.imageView.image = [UIImage imageNamed:myCellModel.imageName];
//        if(myCellModel.imageNeedLayer){
//            self.imageView.layer.borderColor = [UIColor clearColor].CGColor;
//        }
//    }else if (myCellModel.imageURL != nil) {
//        if (myCellModel.loadImageCallback != nil) {
//            myCellModel.loadImageCallback(self.imageView, myCellModel.imageURL);
//        }
//        if(myCellModel.imageNeedLayer){
//            self.imageView.layer.borderColor = [UIColor clearColor].CGColor;
//        }
//    }
//    if (myCellModel.selected) {
//        if (myCellModel.selectedImageName != nil) {
//            self.imageView.image = [UIImage imageNamed:myCellModel.selectedImageName];
//            if(myCellModel.imageNeedLayer){
//                self.imageView.layer.borderColor = myCellModel.titleSelectedColor.CGColor;
//                self.imageView.layer.borderWidth = 1;
//            }
//        }else if (myCellModel.selectedImageURL != nil) {
//            if (myCellModel.loadImageCallback != nil) {
//                myCellModel.loadImageCallback(self.imageView, myCellModel.selectedImageURL);
//            }
//            if(myCellModel.imageNeedLayer){
//                self.imageView.layer.borderColor = myCellModel.titleSelectedColor.CGColor;
//                self.imageView.layer.borderWidth = 1;
//            }
//        }
//    }
//
//    if (myCellModel.imageZoomEnabled) {
//        self.imageView.transform = CGAffineTransformMakeScale(myCellModel.imageZoomScale, myCellModel.imageZoomScale);
//    }else {
//        self.imageView.transform = CGAffineTransformIdentity;
//    }
//
//    [self setNeedsLayout];
//    [self layoutIfNeeded];
    
    
    switch (myCellModel.imageType) {
        case JXCategoryTitleImageType_TopImage: {
            self.stackView.axis = UILayoutConstraintAxisVertical;
            [self.stackView addArrangedSubview:self.imageView];
            [self.stackView addArrangedSubview:self.titleLabel];
            break;
        }
        case JXCategoryTitleImageType_LeftImage: {
            self.stackView.axis = UILayoutConstraintAxisHorizontal;
            [self.stackView addArrangedSubview:self.imageView];
            [self.stackView addArrangedSubview:self.titleLabel];
            break;
        }
        case JXCategoryTitleImageType_BottomImage: {
            self.stackView.axis = UILayoutConstraintAxisVertical;
            [self.stackView addArrangedSubview:self.titleLabel];
            [self.stackView addArrangedSubview:self.imageView];
            break;
        }
        case JXCategoryTitleImageType_RightImage: {
            self.stackView.axis = UILayoutConstraintAxisHorizontal;
            [self.stackView addArrangedSubview:self.titleLabel];
            [self.stackView addArrangedSubview:self.imageView];
            break;
        }
        case JXCategoryTitleImageType_OnlyImage: {
            self.titleLabel.hidden = YES;
            [self.stackView addArrangedSubview:self.imageView];
            break;
        }
        case JXCategoryTitleImageType_OnlyTitle: {
            self.imageView.hidden = YES;
            [self.stackView addArrangedSubview:self.titleLabel];
            break;
        }
    }

    //因为`- (void)reloadData:(JXCategoryBaseCellModel *)cellModel`方法会回调多次，尤其是左右滚动的时候会调用无数次，如果每次都触发图片加载，会非常消耗性能。所以只会在图片发生了变化的时候，才进行图片加载。
    NSString *currentImageName;
    NSURL *currentImageURL;
    if (myCellModel.imageName) {
        currentImageName = myCellModel.imageName;
    } else if (myCellModel.imageURL) {
        currentImageURL = myCellModel.imageURL;
    }
    if (myCellModel.isSelected) {
        if (myCellModel.selectedImageName) {
            currentImageName = myCellModel.selectedImageName;
            
        } else if (myCellModel.selectedImageURL) {
            currentImageURL = myCellModel.selectedImageURL;
        }
        if(myCellModel.imageNeedLayer){
            self.imageView.layer.borderColor = myCellModel.titleSelectedColor.CGColor;
            self.imageView.layer.borderWidth = 2;
        }
    }else{
        self.imageView.layer.borderColor = [UIColor clearColor].CGColor;
    }
    if (currentImageName && ![currentImageName isEqualToString:self.currentImageName]) {
        self.currentImageName = currentImageName;
        self.imageView.image = [UIImage imageNamed:currentImageName];
    } else if (currentImageURL && ![currentImageURL.absoluteString isEqualToString:self.currentImageURL.absoluteString]) {
        self.currentImageURL = currentImageURL;
        if (myCellModel.loadImageCallback) {
            myCellModel.loadImageCallback(self.imageView, currentImageURL);
        }
    }

    if (myCellModel.isImageZoomEnabled) {
        self.imageView.transform = CGAffineTransformMakeScale(myCellModel.imageZoomScale, myCellModel.imageZoomScale);
    } else {
        self.imageView.transform = CGAffineTransformIdentity;
    }
}


@end
