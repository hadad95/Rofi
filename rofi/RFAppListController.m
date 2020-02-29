#include "RFAppListController.h"
#include <AppList/AppList.h>
#include <Preferences/PSSpecifier.h>

NSMutableArray *sortedDisplayIdentifiers;
NSMutableDictionary *applications;
ALApplicationList *appList;
PSSpecifier *firstSection;

@implementation RFAppListController
- (void)viewDidLoad {
	[super viewDidLoad];
	//[self setEditingButtonHidden:YES animated:NO];
	//[self setEditable:YES];
}

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

- (long long)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(long long)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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

/*
-(id)_editButtonBarItem {
	return nil;
}
*/
@end