//
//  HWKCustomCell.h
//  Hawk
//
//  Created by Lochie Ferrier on 25/09/12.
//  Copyright (c) 2012 Lochie Ferrier. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HWKCustomCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *trackIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *isCurrentlyTrackingImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cellLabelHSpaceConstraint;



@end
