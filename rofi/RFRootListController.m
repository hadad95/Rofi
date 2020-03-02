#include "RFRootListController.h"
#import "SparkAppListTableViewController.h"

@implementation RFRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

-(void)selectExcludeApps
{
    // Replace "com.spark.notchlessprefs" and "excludedApps" with your strings
    //SparkAppListTableViewController* s = [[SparkAppListTableViewController alloc] initWithIdentifier:@"com.spark.notchlessprefs" andKey:@"excludedApps"];
    UITableViewController *s = [[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:s animated:YES];
    self.navigationItem.hidesBackButton = FALSE;
}

- (void)respring {
}

@end
