//
//  SimpleTableCell.h
//  SearchInGoogle
//
//  Created by Monro on 16.04.14.
//  Copyright (c) 2014 DatPixel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimpleTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contextLabel;

@end
