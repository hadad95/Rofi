#import "RFRootListController.h"

@implementation RFRootListController

- (instancetype)init {
    self = [super init];
    if (self) {
        UIBarButtonItem *respringButton = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(respring)];
        self.navigationItem.rightBarButtonItem = respringButton;

        RFAppearanceSettings *appearanceSettings = [[RFAppearanceSettings alloc] init];
        appearanceSettings.tintColor = [UIColor colorWithRed: 0.57 green: 0.37 blue: 0.92 alpha: 1.00];
        self.hb_appearanceSettings = appearanceSettings;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"";
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
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Apply Settings" message:@"Applying settings will respring your device. Are you sure?" preferredStyle:UIAlertControllerStyleAlert];
 
    [alert addAction:[UIAlertAction actionWithTitle:@"Respring" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {[HBRespringController respring];}]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
