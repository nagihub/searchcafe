#import "ListViewController.h"
#import "ListDetailViewController.h"
#import "SSGentleAlertView.h"
#import "SSDialogView.h"

@interface ListViewController () {
    NSMutableArray *_items;
    Item *_item;
    NSXMLParser *_parser;
    NSString *_elementName;
}
@end

@implementation ListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SSGentleAlertView* alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack];
    alert.delegate = self;
    alert.title = @"Cafe List";
    alert.message = @"Please pull down your table.";
    //[alert addButtonWithTitle:@"Cancel"];
    //alert.cancelButtonIndex = 0;
    [alert addButtonWithTitle:@"OK"];
    
    [alert show];
    
	// Do any additional setup after loading the view, typically from a nib.
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                       action:@selector(startDownload)
             forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    // title
    self.navigationItem.title = @"Cafe List";
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Item *item = _items[indexPath.row];
    cell.textLabel.text = [item title];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue");
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    Item *item = _items[indexPath.row];
    NSLog(@"listDetailViewController.linkurl : %@", item.linkurl);

    if ([[segue identifier] isEqualToString:@"showListDetail"]) {
        NSLog(@"showListDetail");
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Item *item = _items[indexPath.row];

        ListDetailViewController *listDetailViewController = [segue destinationViewController];
        [[segue destinationViewController] setDetailItem:item];
        listDetailViewController.linkurl = item.linkurl;
        
    }
}

- (void)startDownload{
    _items = [[NSMutableArray alloc] init];
    
    _longitude = 0.0;
	_latitude = 0.0;
    
	// ロケーションマネージャーを作成
	BOOL locationServicesEnabled;
	locationManager = [[CLLocationManager alloc] init];
    locationServicesEnabled = [CLLocationManager locationServicesEnabled];
    
	if (locationServicesEnabled) {
        locationManager.delegate = self;
        // 位置情報取得開始
		[locationManager startUpdatingLocation];
	} else {
        NSString* message = [NSString stringWithFormat:@"Please check your location setting."];
		if (message) {
			// アラートを表示
			UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil
                                                cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
        }
        [self.refreshControl endRefreshing];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	// 位置情報更新
	_longitude = newLocation.coordinate.longitude;
	_latitude = newLocation.coordinate.latitude;
    
    [locationManager stopUpdatingLocation];
    
    
    NSString *urlString = [NSString stringWithFormat:@"http://nagitter.com/cafesearch/list.php?lat=%f&lng=%f", _latitude, _longitude];    
    NSLog(@"list url : %@",  urlString);
    NSURL* jsonUrl = [NSURL URLWithString: urlString];
    NSError *error = nil;
    NSData *jsonData = [NSData dataWithContentsOfURL:jsonUrl options:kNilOptions error:&error];
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    
    for( NSDictionary * json in jsonResponse )
    {
        _item = [[Item alloc] init];
        _item.title = [json objectForKey:@"title"];
        _item.linkurl = [json objectForKey:@"linkurl"];
        NSLog(@"list url : %@",  [json objectForKey:@"linkurl"]);
        [_items addObject:_item];
    }
    
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

// 位置情報が取得失敗した場合にコールされる。
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	if (error) {
		NSString* message = nil;
		switch ([error code]) {
                // アプリでの位置情報サービスが許可されていない場合
			case kCLErrorDenied:
				// 位置情報取得停止
				[locationManager stopUpdatingLocation];
				message = [NSString stringWithFormat:@"User has denied to use current location."];
				break;
			default:
				message = [NSString stringWithFormat:@"Failed to get your location."];
				break;
		}
		if (message) {
			// アラートを表示
			UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil
                                                cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
		}
	}
}

@end
