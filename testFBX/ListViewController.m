//
//  ListViewController.m
//  testFBX
//
//  Created by Kirill Gorbushko on 11.08.16.
//  Copyright © 2016 - present Thinkmobiles. All rights reserved.
//

#import "ListViewController.h"
#import "ViewController.h"

static NSString *const ListToGlViewControllerSegueIdentifier = @"toGlViewControllerSegueIdentifier";
static NSString *const TextureNameKey = @"texture";
static NSString *const FileNameKey = @"name";

@interface ListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableViewController;

@property (strong, nonatomic) NSArray *dataSource;

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataSource = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DataSource" ofType:@"plist"]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:ListToGlViewControllerSegueIdentifier sender:indexPath];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *data = self.dataSource[indexPath.row];
    NSString *item = [[[data valueForKey:FileNameKey] stringByDeletingPathExtension] capitalizedString];
    cell.textLabel.text = item;
}

#pragma mark - Navigations

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:ListToGlViewControllerSegueIdentifier]) {
        ViewController *glViewController = segue.destinationViewController;
        NSDictionary *data = self.dataSource[((NSIndexPath *)sender).row];

        glViewController.fileName = [data valueForKey:FileNameKey];
        glViewController.textureName = [data valueForKey:TextureNameKey];
    }
}

@end
