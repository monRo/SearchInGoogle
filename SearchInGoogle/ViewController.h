//
//  ViewController.h
//  SearchInGoogle
//
//  Created by Monro on 16.04.14.
//  Copyright (c) 2014 DatPixel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> 
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UITextField *searchTextField;

- (IBAction)searthButton:(UIBarButtonItem *)sender;

@property (weak, nonatomic) NSMutableArray *url;
@property (weak, nonatomic) NSMutableArray *titleUrl;
@property (weak, nonatomic) NSMutableArray *context;

@end
