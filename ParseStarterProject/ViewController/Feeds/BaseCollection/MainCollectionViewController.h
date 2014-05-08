//
//  MainCollectionViewController.h
//  ParseStarterProject
//
//  Created by Q on 3/22/14.
//
//

#import <UIKit/UIKit.h>

@interface MainCollectionViewController : UICollectionViewController
@property (nonatomic, strong) NSMutableArray *dataSourceArray;
- (UICollectionViewController*)nextViewControllerAtPoint:(CGPoint)point;
@end
