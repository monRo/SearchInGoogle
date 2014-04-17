//
//  SimpleTableCell.m
//  SearchInGoogle
//
//  Created by Monro on 16.04.14.
//  Copyright (c) 2014 DatPixel. All rights reserved.
//

#import "SimpleTableCell.h"

@implementation SimpleTableCell
@synthesize titleLabel = _titleLabel;

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

@end
