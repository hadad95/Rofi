#include "RFAppListController.h"
#include <AppList/AppList.h>
#include <Preferences/PSSpecifier.h>

@implementation RFAppListController
- (void)viewDidLoad {
	[super viewDidLoad];
	NSLog(@"[RF] conforms to protocol? %@", [self conformsToProtocol:@protocol(UITableViewDataSource)] ? @"YES" : @"NO");
	//[self setEditingButtonHidden:YES animated:NO];
	//[self setEditable:YES];
}

- (NSArray *)specifiers {
	ALApplicationList *appList = [ALApplicationList sharedApplicationList];
	NSMutableArray *result = [[NSMutableArray alloc] init];
	NSArray *sortedDisplayIdentifiers;
	NSDictionary *applications = [appList applicationsFilteredUsingPredicate:[NSPredicate predicateWithFormat:@"isSystemApplication = TRUE"] onlyVisible:YES titleSortedIdentifiers:&sortedDisplayIdentifiers];
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
	return UITableViewCellEditingStyleInsert;
}

-(BOOL)tableView:(id)arg1 canEditRowAtIndexPath:(id)arg2 {
	return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
	NSLog(@"[RF] moveRowAtIndexPath called");
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"[RF] canMoveRowAtIndexPath called");
	return YES;
}
/*
-(id)_editButtonBarItem {
	return nil;
}
*/
@end