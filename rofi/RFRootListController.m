#import "RFRootListController.h"

@implementation RFRootListController

- (instancetype)init {
    self = [super init];
    if (self) {
        UIBarButtonItem *respringButton = [[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(respring)];
        self.navigationItem.rightBarButtonItem = respringButton;

        RFAppearanceSettings *appearanceSettings = [[RFAppearanceSettings alloc] init];
        appearanceSettings.tintColor = [UIColor colorWithRed:0.00 green:0.60 blue:0.60 alpha:1.00];
        self.hb_appearanceSettings = appearanceSettings;
    }
    return self;
}

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
    
    /*
    SparkAppListTableViewController* s = [[SparkAppListTableViewController alloc] initWithIdentifier:@"com.spark.notchlessprefs" andKey:@"excludedApps"];

    [self.navigationController pushViewController:s animated:YES];
    self.navigationItem.hidesBackButton = FALSE;
    */
}

- (void)respring {
    NSLog(@"[RF] respring called");
    [HBRespringController respring];
}

@end
