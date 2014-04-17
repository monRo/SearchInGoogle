//
//  ViewController.m
//  SearchInGoogle
//
//  Created by Monro on 16.04.14.
//  Copyright (c) 2014 DatPixel. All rights reserved.
//

#import "ViewController.h"
#import "SimpleTableCell.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSLog(@"%d", [self.url count]);
    return [self.url count];
//    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    SimpleTableCell *cell = (SimpleTableCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

    if (cell == nil) {
        cell = [[SimpleTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
//    NSArray *arrayTitle = [self.url objectAtIndex:indexPath.row];

    cell.titleLabel.text = [self.url objectAtIndex:indexPath.row];
    
    return cell;
}

- (IBAction)searthButton:(UIBarButtonItem *)sender {
    NSLog(@"%@", self.searchTextField.text);
    [self search:self.searchTextField.text];
    NSLog(@"%@", self.url);
}

#pragma mark - Search
- (void)search:(NSString *)searchText {
    
    NSURL *searchURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=%@", searchText]];
    
    NSData *jsonData = [NSData dataWithContentsOfURL:searchURL];
    
    NSError *error = nil;
    
    NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    
    NSDictionary *responseData = [dataDictionary objectForKey:@"responseData"];
    
    NSDictionary *results = [responseData objectForKey:@"results"];
    
    for (NSDictionary *search in results) {
        
        NSString *content = [search objectForKey:@"content"];
        NSLog(@"%@", content);
        [self.context addObject:content];
        
        NSString *urlStr = [search objectForKey:@"unescapedUrl"];
        NSLog(@"%@", urlStr);
        [self.url addObject:urlStr];
        
        NSString *titleUrlStr = [search objectForKey:@"titleNoFormatting"];
        NSLog(@"%@", titleUrlStr);
        [self.titleUrl addObject:titleUrlStr]; 
    }
    [self.tableView reloadData];
}
@end
