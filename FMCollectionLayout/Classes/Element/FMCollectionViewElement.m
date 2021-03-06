//
//  FMCollectionViewElement.m
//  FMLayoutKit
//
//  Created by 郑桂华 on 2020/4/1.
//  Copyright © 2020 ZhouFaMing. All rights reserved.
//

#import "FMCollectionViewElement.h"

@implementation FMCollectionViewElement

+ (instancetype)elementWithViewClass:(Class)vCalss{
    return [self elementWithViewClass:vCalss isNib:NO];
}

+ (instancetype)elementWithViewClass:(Class)vCalss isNib:(BOOL)isNib{
    return [self elementWithViewClass:vCalss isNib:isNib reuseIdentifier:NSStringFromClass(vCalss)];
}

+ (instancetype)elementWithViewClass:(Class)vCalss isNib:(BOOL)isNib reuseIdentifier:(NSString *)reuseIdentifier{
    FMCollectionViewElement *element = [[self alloc] init];
    element.viewClass = vCalss;
    element.isNib = isNib;
    element.reuseIdentifier = reuseIdentifier;
    return element;
}

- (void)registerCellWithCollection:(UICollectionView *)collectionView{
    if (self.isNib) {
        [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass(self.viewClass) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:self.reuseIdentifier];
    } else {
        [collectionView registerClass:self.viewClass forCellWithReuseIdentifier:self.reuseIdentifier];
    }
}

@end
