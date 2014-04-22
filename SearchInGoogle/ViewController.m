//
//  ViewController.m
//  SearchInGoogle
//
//  Created by Monro on 16.04.14.
//  Copyright (c) 2014 DatPixel. All rights reserved.
//

#define TAGB @"<b>"
#define TAGCLOSEB @"</b>"
#define THREEDOTS @"..."
#define ENTER @"\n"

#import "ViewController.h"
#import "SimpleTableCell.h"

@interface ViewController ()

@property (strong) NSMutableArray *coreDataArray;

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.url = [[NSMutableArray alloc] init];
    
    self.context = [[NSMutableArray alloc] init];
    
    self.titleUrl = [[NSMutableArray alloc] init];
    
    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"History"];
//    self.coreDataArray = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity =[NSEntityDescription entityForName:@"History" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *fetchedObject = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *object in fetchedObject) {
        NSLog(@"url %@", [object valueForKey:@"url"]);
        NSLog(@"title %@", [object valueForKey:@"titleUrl"]);
        NSLog(@"context %@", [object valueForKey:@"context"]);

        NSString *doneString = [object valueForKey:@"url"];
        [self.context addObject:doneString];
        
        NSString *urlStr = [object valueForKey:@"titleUrl"];
        [self.url addObject:urlStr];
        
        NSString *titleUrlStr = [object valueForKey:@"context"];
        [self.titleUrl addObject:titleUrlStr];
    }
    
    [self.tableView reloadData];
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
    NSInteger count = [self.url count];
    NSLog(@"%d", count);
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

    cell.titleLabel.text = [self.titleUrl objectAtIndex:indexPath.row];
    cell.contextLabel.text = [self.context objectAtIndex:indexPath.row];
    cell.wwwLable.text = [self.url objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - Button method
- (IBAction)deleteButton:(UIBarButtonItem *)sender {
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity =[NSEntityDescription entityForName:@"History" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *fetchedObject = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *managedObject in fetchedObject) {
    	[managedObjectContext deleteObject:managedObject];
    }
    if (![managedObjectContext save:&error]) {
    	NSLog(@"Error deleting");
    }
    [self.context removeAllObjects];
    [self.url removeAllObjects];
    [self.titleUrl removeAllObjects];
    [self.tableView reloadData];
}

- (IBAction)searthButton:(UIBarButtonItem *)sender {
    if ([self.searchTextField.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Type something" message:@"Nothing to search!" delegate:self cancelButtonTitle:@"M'kay" otherButtonTitles:nil];
        [alert show];
        [self.searchTextField resignFirstResponder];
    } else {
    NSLog(@"%@", self.searchTextField.text);
    [self search:self.searchTextField.text];
    NSLog(@"%@", self.url);
    [self.searchTextField setText:@""];
    [self.searchTextField resignFirstResponder];
    }
}

#pragma mark - Search
- (void)search:(NSString *)searchText {
    
    [self.context removeAllObjects];
    [self.url removeAllObjects];
    [self.titleUrl removeAllObjects];
    
    NSString *searchGoogle = [NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=%@", searchText];
    NSURL *searchURL = [NSURL URLWithString:[searchGoogle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSData *jsonData = [NSData dataWithContentsOfURL:searchURL];
    
    NSError *error = nil;
    
    NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    
    NSDictionary *responseData = [dataDictionary objectForKey:@"responseData"];
    
    NSDictionary *results = [responseData objectForKey:@"results"];
    
    for (NSDictionary *search in results) {
        
        NSString *content = [search objectForKey:@"content"];
        NSString *doneString = [self replacement:content];
//        NSLog(@"%@", doneString);
        [self.context addObject:doneString];
        
        NSString *urlStr = [search objectForKey:@"unescapedUrl"];
//        NSLog(@"%@", urlStr);
        [self.url addObject:urlStr];
        
        NSString *titleUrlStr = [search objectForKey:@"titleNoFormatting"];
//        NSLog(@"%@", titleUrlStr);
        [self.titleUrl addObject:titleUrlStr];
        
        // Core Data
        NSManagedObjectContext *context = [self managedObjectContext];
        
        // Create a new managed object
        NSManagedObject *newSearch = [NSEntityDescription insertNewObjectForEntityForName:@"History" inManagedObjectContext:context];
        [newSearch setValue:doneString forKey:@"context"];
        [newSearch setValue:urlStr forKey:@"url"];
        [newSearch setValue:titleUrlStr forKey:@"titleUrl"];
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        // End Core Data
    }
    
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (SimpleTableCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    UILabel *string = (UILabel *)[cell viewWithTag:100];
    
    NSLog(@"You selected %@", string.text);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string.text]];
    
}

-(NSString *)replacement:(NSString *)replacingString
{
    NSMutableString *modifiedString = [NSMutableString stringWithString:replacingString];
    if ([modifiedString rangeOfString:TAGB].location == NSNotFound) {
        NSLog(@"NO B");
    } else {
                [modifiedString replaceOccurrencesOfString:TAGB withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, modifiedString.length)];
    }
    if ([modifiedString rangeOfString:TAGCLOSEB].location == NSNotFound) {
        NSLog(@"NO //B");
    } else {
               [modifiedString replaceOccurrencesOfString:TAGCLOSEB withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, modifiedString.length)];
    }
    if ([modifiedString rangeOfString:THREEDOTS].location == NSNotFound) {
        NSLog(@"NO TREEDOTS");
    } else {
                [modifiedString replaceOccurrencesOfString:THREEDOTS withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, modifiedString.length)];
    }
    if ([modifiedString rangeOfString:ENTER].location == NSNotFound) {
        NSLog(@"NO NEWLINE");
    } else {
                [modifiedString replaceOccurrencesOfString:ENTER withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, modifiedString.length)];
    }
    
    NSLog(@"CHANGED STRING: %@", modifiedString);
    
    return modifiedString;
}

#pragma mark - Core Data
- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

@end
