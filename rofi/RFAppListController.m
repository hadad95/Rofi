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
	//NSLog(@"[RF] viewDidLoad called, self = %p", self);
	__weak RFAppListController *weakSelf = self;
	[appList getAppList:^(NSArray *args) {
		//NSLog(@"[RF] block called. args length = %lu", [args count]);
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
	//[self setEditingButtonHidden:YES animated:NO];
	//[self setEditable:YES];
	[self setEditing:YES animated:NO];
	self.navigationItem.hidesBackButton = NO;
}

/*
- (NSArray *)specifiers {
	NSLog(@"[RF] specifiers called");
	appList = [ALApplicationList sharedApplicationList];
	NSMutableArray *result = [[NSMutableArray alloc] init];
	//NSArray *sortedDisplayIdentifiers;
	NSArray *testArray;
	applications = [[appList applicationsFilteredUsingPredicate:[NSPredicate predicateWithFormat:@"isSystemApplication = FALSE"] onlyVisible:YES titleSortedIdentifiers:&testArray] mutableCopy];
	sortedDisplayIdentifiers = [testArray mutableCopy];
	PSSpecifier *specifier0 = [PSSpecifier preferenceSpecifierNamed:@"Added apps"
                                                            target:self
                                                               set:nil
                                                               get:nil
                                                            detail:Nil
                                                              cell:PSGroupCell
                                                              edit:Nil];
	[result addObject:specifier0];
	firstSection = specifier0;
	PSSpecifier *specifier1 = [PSSpecifier preferenceSpecifierNamed:@"System apps"
                                                            target:self
                                                               set:nil
                                                               get:nil
                                                            detail:Nil
                                                              cell:PSGroupCell
                                                              edit:Nil];
	[result addObject:specifier1];
	for (NSString *appId in sortedDisplayIdentifiers) {
		UIImage *icon = [appList iconOfSize:ALApplicationIconSizeSmall forDisplayIdentifier:appId];
		PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:applications[appId]
                                                                target:self
                                                                   set:@selector(setPreferenceValue:specifier:)
                                                                   get:@selector(readPreferenceValue:)
                                                                detail:Nil
                                                                  cell:PSListItemCell
                                                                  edit:Nil];
		[specifier setIdentifier:appId];
		[specifier setProperty:@YES forKey:@"enabled"];
		[specifier setProperty:icon forKey:@"iconImage"];
		//NSLog(@"[RF] specifier = %@", specifier);
		[result addObject:specifier];

	}
	_specifiers = [result copy];
	//NSLog(@"[RF] _specifiers = %@", _specifiers);
	return _specifiers;
}
*/

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
/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleInsert) {
		NSInteger ind = indexPath.row + [tableView numberOfRowsInSection:0] + 3;
		NSLog(@"[RF] numberOfRowsInSection = %ld, row = %ld, ind = %ld", [tableView numberOfRowsInSection:0], indexPath.row, ind);
		//[tableView moveRowAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
		//[self insertSpecifier:_specifiers[indexPath.row + [tableView numberOfRowsInSection:0] + 2] atIndex:0 animated:YES];
		UIImage *icon = [appList iconOfSize:ALApplicationIconSizeSmall forDisplayIdentifier:sortedDisplayIdentifiers[indexPath.row]];
		PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:applications[sortedDisplayIdentifiers[indexPath.row]]
	                                                            target:self
	                                                               set:nil
	                                                               get:nil
	                                                            detail:Nil
	                                                              cell:PSListItemCell
	                                                              edit:Nil];
		[specifier setProperty:@YES forKey:@"enabled"];
		[specifier setProperty:icon forKey:@"iconImage"];
		//[self insertSpecifier:specifier afterSpecifier:firstSection animated:YES];
		[self insertSpecifier:specifier atIndex:1 animated:YES];
		[self removeSpecifierAtIndex:ind animated:YES];
		[applications removeObjectForKey:sortedDisplayIdentifiers[indexPath.row]];
		[sortedDisplayIdentifiers removeObjectAtIndex:indexPath.row];
	}
}
*/
/*
-(id)_editButtonBarItem {
	return nil;
}
*/
@end