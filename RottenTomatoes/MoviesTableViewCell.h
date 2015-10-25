//
//  MoviesTableViewCell.h
//  RottenTomatoes
//
//  Created by Nizha Shree Seenivasan on 10/20/15.
//  Copyright © 2015 Nizha Shree Seenivasan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoviesTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *SynopsisLabel;
@property (weak, nonatomic) IBOutlet UIImageView *Thumbnail;
@property (strong, nonatomic) NSDictionary *movieJson;
@property (weak, nonatomic) IBOutlet UILabel *LoadingLabel;
@end
