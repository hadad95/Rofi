#include "RFAppListController.h"
//#include <AppList/AppList.h>
#include <Preferences/PSSpecifier.h>
#import "SparkAppList.h"
#import "SparkAppItem.h"

NSMutableArray *userApps;
NSMutableArray *selectedApps;

@implementation RFAppListController

- (RFAppListController *)initWithStyle:(UITableViewStyle)style {
	self = [super initWithStyle:style];
	selectedApps = [[NSMutableArray alloc] init];
	SparkAppList *appList = [[SparkAppList alloc] init];
	__weak RFAppListController *weakSelf = self;
	[appList getAppList:^(NSArray *args) {
		userApps = [args mutableCopy];
		NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
		[userApps sortUsingDescriptors:@[sortDescriptor]];
		NSLog(@"[RF] block done");
		[weakSelf.tableView reloadData];
	}];
	NSLog(@"[RF] init done");
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setEditing:YES animated:NO];
	self.navigationItem.hidesBackButton = NO;
	self.title = @"Selected Applications";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return @"Selected apps";
    else
        return @"User apps";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0)
		return selectedApps.count;
	else
		return userApps.count;
	NSLog(@"[RF] numberOfRowsInSection called, userApps.count = %lu", userApps.count);
	return userApps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (cell == nil)
    	cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
	if (indexPath.section == 0) {
		cell.textLabel.text = ((SparkAppItem *)selectedApps[indexPath.row]).displayName;
		cell.imageView.image = [(SparkAppItem *)selectedApps[indexPath.row] icon];
	}
	else {
		cell.textLabel.text = ((SparkAppItem *)userApps[indexPath.row]).displayName;
		cell.imageView.image = [(SparkAppItem *)userApps[indexPath.row] icon];
	}
	return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0)
		return UITableViewCellEditingStyleDelete;
	else
		return UITableViewCellEditingStyleInsert;
}

-(BOOL)tableView:(id)arg1 canEditRowAtIndexPath:(id)arg2 {
	return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
	NSLog(@"[RF] moveRowAtIndexPath called, sourceIndexPath = %@, destinationIndexPath = %@", sourceIndexPath, destinationIndexPath);
	NSLog(@"[RF] source section = %ld, row = %ld, item = %ld", sourceIndexPath.section, sourceIndexPath.row, sourceIndexPath.item);
	if (sourceIndexPath.section == 0 && destinationIndexPath.section == 0) {
		SparkAppItem *app = selectedApps[sourceIndexPath.row];
		[selectedApps removeObjectAtIndex:sourceIndexPath.row];
		[selectedApps insertObject:app atIndex:destinationIndexPath.row];
	}
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	if (sourceIndexPath.section != proposedDestinationIndexPath.section)
		return sourceIndexPath;
	else
		return proposedDestinationIndexPath;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	//NSLog(@"[RF] canMoveRowAtIndexPath called");
	if (indexPath.section == 0)
		return YES;
	else
		return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleInsert) {
		SparkAppItem *app = userApps[indexPath.row];
		NSLog(@"[RF] app = %@", app);
		[selectedApps addObject:app];
		[userApps removeObject:app];
		NSLog(@"[RF] selectedApps = %@", selectedApps);
		[tableView beginUpdates];
		[tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:selectedApps.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
		[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
		[tableView endUpdates];
	}
	else if (editingStyle == UITableViewCellEditingStyleDelete) {
		SparkAppItem *app = selectedApps[indexPath.row];
		[userApps addObject:app];
		[selectedApps removeObject:app];
		NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
		[userApps sortUsingDescriptors:@[sortDescriptor]];
		NSUInteger index = [userApps indexOfObject:app];
		[tableView beginUpdates];
		[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
		[tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:1]] withRowAnimation:UITableViewRowAnimationTop];
		[tableView endUpdates];
	}
}
@end