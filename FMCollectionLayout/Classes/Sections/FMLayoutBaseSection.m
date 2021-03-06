//
//  FMLayoutBaseSection.m
//  LiangXinApp
//
//  Created by 郑桂华 on 2020/3/20.
//  Copyright © 2020 ZhouFaMing. All rights reserved.
//

#import "FMLayoutBaseSection.h"
#import "FMSupplementaryFooter.h"
#import "FMSupplementaryHeader.h"
#import "FMSupplementaryBackground.h"
#import "FMCollectionLayoutAttributes.h"
#import "FMKVOArrayObject.h"

@interface FMLayoutBaseSection ()

@property(nonatomic, strong)FMKVOArrayObject *kvoArray;

@end

@implementation FMLayoutBaseSection

- (void)dealloc{
    NSLog(@"%@ dealloc", NSStringFromClass([self class]));
    [self.kvoArray removeObserver:self forKeyPath:@"targetArray" context:nil];
}

+ (instancetype)sectionWithSectionInset:(UIEdgeInsets)inset itemSpace:(CGFloat)itemSpace lineSpace:(CGFloat)lineSpace column:(NSInteger)column{
    FMLayoutBaseSection *section = [[self alloc] init];
    section.sectionInset = inset;
    section.itemSpace = itemSpace;
    section.lineSpace = lineSpace;
    section.column = column;
    [section resetColumnHeights];
    return section;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.kvoArray = [[FMKVOArrayObject alloc] init];
        [self.kvoArray addObserver:self forKeyPath:@"targetArray" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}

- (void)setHandleItemStart:(NSInteger)handleItemStart{
    if (handleItemStart < _handleItemStart) {
        _handleItemStart = handleItemStart;
    }
}

- (NSMutableArray *)itemDatas{
    return [self.kvoArray mutableArrayValueForKey:@"targetArray"];
}

- (void)setItemDatas:(NSMutableArray *)itemDatas{

    if (self.kvoArray.targetArray == itemDatas) {
        return;
    }

    if (self.kvoArray.targetArray) {
        [self.kvoArray removeObserver:self forKeyPath:@"targetArray" context:nil];
    }

    if (![itemDatas isKindOfClass:[NSMutableArray class]]) {
        self.kvoArray.targetArray = [itemDatas mutableCopy];
        [self.kvoArray addObserver:self forKeyPath:@"targetArray" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    } else {
        self.kvoArray.targetArray = itemDatas;
        [self.kvoArray addObserver:self forKeyPath:@"targetArray" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"targetArray"]) {
        self.hasHandle = NO;
//        NSInteger kind = [change[@"kind"] integerValue];
        NSIndexSet *set = change[@"indexes"];
        self.handleItemStart = set.firstIndex;
//        if (kind == 2) { //增加 需判断是插入 还是
//
//        }
//        /*
//         NSKeyValueChangeSetting = 1,
//         NSKeyValueChangeInsertion = 2,  //插入
//         NSKeyValueChangeRemoval = 3, // 移除
//         NSKeyValueChangeReplacement = 4, // 替换
//         */
//
    }
    NSLog(@"base section itemDatas changeed %@", change);
}

- (void)setSectionOffset:(CGFloat)sectionOffset{
    _sectionOffset = sectionOffset;
}

- (CGFloat)firstItemStartY{
    return self.sectionOffset + self.sectionInset.top + self.header.inset.top + self.header.height + self.header.inset.bottom + self.header.bottomMargin;
}

- (void)markChangeAt:(NSInteger)index{
    self.hasHandle = NO;
    self.handleItemStart = index;
}

- (void)handleLayout{
    if (self.header) {
        [self prepareHeader];
    }
    [self prepareItems];
    if (self.footer) {
        [self prepareFooter];
    }
    self.sectionHeight = self.sectionInset.top + self.header.inset.top +self.header.height + self.header.inset.bottom + self.header.bottomMargin + [self getColumnMaxHeight] + self.footer.inset.top + self.footer.height +  self.footer.topMargin + self.footer.inset.bottom + self.sectionInset.bottom;

    [self prepareBackground];
}


- (BOOL)intersectsRect:(CGRect)rect{
    return CGRectIntersectsRect(CGRectMake(0, self.sectionOffset, self.collectionView.bounds.size.width, self.sectionHeight), rect);
}

- (void)prepareHeader{
    if (self.handleType == FMLayoutSectionHandleTypeOlnyChangeOffsetY && self.headerAttribute) {
        self.headerAttribute.indexPath = self.indexPath;
        CGRect frame = self.headerAttribute.frame;
        frame.origin.y += self.changeOffsetY;
        self.headerAttribute.frame = frame;
        return;
    }
    FMCollectionLayoutAttributes *header = [FMCollectionLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:self.indexPath];
    header.frame = CGRectMake(self.sectionInset.left + self.header.inset.left, self.sectionInset.top + self.header.inset.top + self.sectionOffset, self.collectionView.bounds.size.width - self.sectionInset.left- self.header.inset.left - self.sectionInset.right - self.header.inset.right, self.header.height);
    header.zIndex = self.header.zIndex;
    self.headerAttribute = header;
}

- (void)prepareFooter{
    if (self.handleType == FMLayoutSectionHandleTypeOlnyChangeOffsetY && self.footerAttribute) {
        self.footerAttribute.indexPath = self.indexPath;
        CGRect frame = self.footerAttribute.frame;
        frame.origin.y += self.changeOffsetY;
        self.footerAttribute.frame = frame;
        return;
    }
    FMCollectionLayoutAttributes *footer = [FMCollectionLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:self.indexPath];
    footer.frame = CGRectMake(self.sectionInset.left + self.footer.inset.left, self.sectionOffset + self.sectionInset.top + self.footer.inset.top + self.header.height + self.header.bottomMargin + [self getColumnMaxHeight] + self.footer.topMargin, self.collectionView.bounds.size.width - self.sectionInset.left - self.footer.inset.left - self.sectionInset.right - self.footer.inset.right, self.footer.height);
    footer.zIndex = self.footer.zIndex;
    self.footerAttribute = footer;
}

- (void)prepareItems{
    
}

- (void)prepareBackground{
    if (self.handleType == FMLayoutSectionHandleTypeOlnyChangeOffsetY && self.bgAttribute) {
        self.bgAttribute.indexPath = self.indexPath;
        CGRect frame = self.bgAttribute.frame;
        frame.origin.y += self.changeOffsetY;
        self.bgAttribute.frame = frame;
        return;
    }
    if (self.background) {
        FMCollectionLayoutAttributes *bgAttr = [FMCollectionLayoutAttributes layoutAttributesForSupplementaryViewOfKind:self.background.elementKind withIndexPath:self.indexPath];
        bgAttr.frame = CGRectMake(self.background.inset.left, self.sectionOffset + self.background.inset.top, self.collectionView.bounds.size.width - (self.background.inset.left + self.background.inset.right), self.sectionHeight - (self.background.inset.top + self.background.inset.bottom));
        bgAttr.zIndex = self.background.zIndex;
        self.bgAttribute = bgAttr;
    }
}

///头部悬停布局计算
- (UICollectionViewLayoutAttributes *)showHeaderLayout{
    if (self.header.type == FMSupplementaryTypeFixed) {
        return self.headerAttribute;
    }
    if (self.header.type == FMSupplementaryTypeSuspension) {
        CGFloat columnMaxHeight = [self getColumnMaxHeight];
        CGFloat itemMaxHeight = self.sectionOffset + self.sectionInset.top + self.header.height + self.header.bottomMargin + columnMaxHeight;
        if (self.collectionView.contentOffset.y > self.sectionOffset + self.sectionInset.top && self.collectionView.contentOffset.y < itemMaxHeight - self.header.height) {
            UICollectionViewLayoutAttributes *show = [self.headerAttribute copy];
            CGRect frame = show.frame;
            frame.origin.y = self.collectionView.contentOffset.y;
            show.frame = frame;
            return show;
        } else if (self.collectionView.contentOffset.y >= itemMaxHeight - self.header.height) {
            UICollectionViewLayoutAttributes *show = [self.headerAttribute copy];
            CGRect frame = show.frame;
            frame.origin.y = itemMaxHeight - self.header.height;
            show.frame = frame;
            return show;
        } else {
            return self.headerAttribute;
        }
    }
    if (self.header.type == FMSupplementaryTypeSuspensionAlways) {
        if (self.collectionView.contentOffset.y > self.sectionOffset + self.sectionInset.top - self.header.suspensionTopHeight) {
            UICollectionViewLayoutAttributes *show = [self.headerAttribute copy];
            CGRect frame = show.frame;
            frame.origin.y = self.collectionView.contentOffset.y + self.header.suspensionTopHeight;
            show.frame = frame;
            return show;
        } else {
            if (self.header.isStickTop) {///黏在顶部
                if (self.collectionView.contentOffset.y > 0) {
                    return self.headerAttribute;
                }
                UICollectionViewLayoutAttributes *show = [self.headerAttribute copy];
                CGRect frame = show.frame;
                frame.origin.y = self.collectionView.contentOffset.y + frame.origin.y;
                show.frame = frame;
                return show;
            } else {
                return self.headerAttribute;
            }
        }
    }
    if (self.header.type == FMSupplementaryTypeSuspensionBigger && self.indexPath.section == 0) {
        UICollectionViewLayoutAttributes *show = [self.headerAttribute copy];
        CGFloat offsetY = self.collectionView.contentOffset.y;
        if (offsetY < CGRectGetHeight(show.frame)) {
            CGRect frame = show.frame;
            
            frame.origin.y += offsetY;
            frame.size.height -= offsetY;
            
            show.frame = frame;
            
            return show;
        } else {
            CGRect frame = show.frame;
            
            frame.origin.y += CGRectGetHeight(show.frame);
            frame.size.height -= CGRectGetHeight(show.frame);
            
            show.frame = frame;
            return show;
        }
    }
    return self.headerAttribute;
}
/// 判断是否只改变Y值
- (BOOL)prepareLayoutItemsIsOlnyChangeY{
    if (self.handleType == FMLayoutSectionHandleTypeOlnyChangeOffsetY) {
        [self.itemsAttribute enumerateObjectsUsingBlock:^(FMCollectionLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.indexPath = [NSIndexPath indexPathForItem:idx inSection:self.indexPath.section];
            CGRect frame = obj.frame;
            frame.origin.y += self.changeOffsetY;
            obj.frame = frame;
        }];
        return YES;
    } else {
        return NO;
    }
}

///获取最小高度的列
- (NSInteger)getMinHeightColumn{
    if (self.columnHeights.allKeys.count == 0) {
        return 0;
    }
    NSInteger column = 0;
    CGFloat minHeight = [self.columnHeights[@0] floatValue];
    for (int i = 1; i<self.column; i++) {
        CGFloat height = [self.columnHeights[@(i)] floatValue];
        if (height < minHeight) {
            column = i;
            minHeight = height;
        }
    }
    return column;
}
///获取最所有列的最大高度
- (CGFloat)getColumnMaxHeight{
    if (self.columnHeights.allKeys.count == 0) {
        return 0;
    }
    CGFloat maxHeight = [self.columnHeights[@0] floatValue];
    for (int i = 1; i<self.column; i++) {
        CGFloat height = [self.columnHeights[@(i)] integerValue];
        if (height > maxHeight) {
            maxHeight = height;
        }
    }
    return maxHeight;
}
///重置所有列的高度缓存
- (void)resetColumnHeights{
    self.columnHeights = [NSMutableDictionary dictionary];
    for (int i = 0; i < self.column; i++) {
        self.columnHeights[@(i)] = @0;
    }
}

- (UICollectionViewCell *)dequeueReusableCellForIndexPath:(NSIndexPath *)indexPath{
    @throw [NSException exceptionWithName:@"child class must implementation this method" reason:@"FMLayoutBaseSection" userInfo:nil];
}
- (void)registerCells{
    
}
@end
