#include "RFRootListController.h"
#import "SparkAppListTableViewController.h"
#import "RFAppListController.h"
#import "SparkAppList.h"

@implementation RFRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

-(void)selectApps
{
	NSLog(@"[RF] selectApps called. Pushing view controller...");
    RFAppListController *appListController = [[RFAppListController alloc] initWithStyle:UITableViewStyleGrouped];
    NSLog(@"[RF] pushing view controller...");
    [self.navigationController pushViewController:appListController animated:YES];
    self.navigationItem.hidesBackButton = FALSE;
    
    /*
    SparkAppListTableViewController* s = [[SparkAppListTableViewController alloc] initWithIdentifier:@"com.spark.notchlessprefs" andKey:@"excludedApps"];

    [self.navigationController pushViewController:s animated:YES];
    self.navigationItem.hidesBackButton = FALSE;
    */
}

- (void)respring {
}

@end
