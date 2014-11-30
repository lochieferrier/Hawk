//
//  HWKMyTracksCustomCell.m
//  Hawk
//
//  Created by Lochie Ferrier on 25/09/12.
//  Copyright (c) 2012 Lochie Ferrier. All rights reserved.
//

#import "HWKCustomCell.h"

@implementation HWKCustomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)awakeFromNib{
    
    // -------------------------------------------------------------------
    // We need to create our own constraint which is effective against the
    // contentView, so the UI elements indent when the cell is put into
    // editing mode
    // -------------------------------------------------------------------
    
    // Remove the IB added horizontal constraint, as that's effective
    // against the cell not the contentView
    [self removeConstraint:self.cellLabelHSpaceConstraint];
    
    // Create a dictionary to represent the view being positioned
    NSDictionary *labelViewDictionary = NSDictionaryOfVariableBindings(_nameLabel);
    
    // Create the new constraint
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[_nameLabel]" options:0 metrics:nil views:labelViewDictionary];
    
    // Add the constraint against the contentView
    [self.contentView addConstraints:constraints];
    
}

@end
