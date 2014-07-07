#import "KeywordViewController.h"
#import "KeywordDetailViewController.h"
#import "SSGentleAlertView.h"
#import "SSDialogView.h"

@interface KeywordViewController () {
    NSMutableArray *_items;
    Item *_item;
    NSXMLParser *_parser;
    NSString *_elementName;
}
@end

@interface UIImage (CommonImplement)
- (UIImage *) makeThumbnailOfSize:(CGSize)size;
@end

@implementation UIImage (CommonImplement)
- (UIImage *) makeThumbnailOfSize:(CGSize)size;
{
    UIGraphicsBeginImageContext(size);
    // draw scaled image into thumbnail context
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newThumbnail = UIGraphicsGetImageFromCurrentImageContext();
    // pop the context
    UIGraphicsEndImageContext();
    if(newThumbnail == nil)
        NSLog(@"could not scale image");
    return newThumbnail;
}

@end

@implementation KeywordViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Keyword Search";

    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        //TableViewの境界線（区切り線）を左端から表示させる。
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    
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
    static NSString *CellIdentifier = @"KeywordCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    Item *item = _items[indexPath.row];
    cell.textLabel.text = [item title];
    
    
    // imageの追加
    NSURL *naverimgurl = [NSURL URLWithString:[item imgurl]];
    NSData * imgdata = [NSData dataWithContentsOfURL:naverimgurl];
    UIImage *thumbnail = [UIImage imageWithData:imgdata];
    CGSize sz = CGSizeMake(50, 50);
    UIImage *thumb = [thumbnail makeThumbnailOfSize: sz];
    
    cell.imageView.image = thumb;
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue");
    if ([[segue identifier] isEqualToString:@"showKeywordDetail"]) {
        NSLog(@"showKeywordDetail");
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Item *item = _items[indexPath.row];
        
        KeywordDetailViewController *keywordDetailViewController = [segue destinationViewController];
        [[segue destinationViewController] setDetailItem:item];
        keywordDetailViewController.linkurl = item.linkurl;
        
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    _elementName = elementName;
    if([_elementName isEqualToString:@"item"]){
        _item = [[Item alloc] init];
        _item.title = @"";
        _item.linkurl = @"";
        _item.description = @"";
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if([_elementName isEqualToString:@"title"]){
        _item.title = [_item.title stringByAppendingString:string];
    } else if ([_elementName isEqualToString:@"link"]){
        _item.linkurl = [_item.linkurl stringByAppendingString:string];
    } else if ([_elementName isEqualToString:@"description"]){
        _item.description = [_item.description stringByAppendingString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if([elementName isEqualToString:@"item"]){
        [_items addObject:_item];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    });
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"searchBarSearchButtonClicked");

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
    
    
    
    
    [self.cafeSearchBar resignFirstResponder];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	// 位置情報更新
	_longitude = newLocation.coordinate.longitude;
	_latitude = newLocation.coordinate.latitude;
    
    [locationManager stopUpdatingLocation];
    
    
    //NSLog(@"_longitude : %f", _longitude);
    //NSLog(@"_latitude : %f", _latitude);
    
    NSLog(@"keyword : %@", self.cafeSearchBar.text);
    NSString *keyword = self.cafeSearchBar.text;
    NSString *encodedStr = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)keyword,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8 ));
    
    NSString *urlString = [NSString stringWithFormat:@"http://nagitter.com/cafesearch/keyword.php?lat=%f&lng=%f&keyword=%@", _latitude, _longitude, encodedStr];
    
    NSLog(@"list url : %@",  urlString);
    NSURL* jsonUrl = [NSURL URLWithString: urlString];
    NSError *error = nil;
    NSData *jsonData = [NSData dataWithContentsOfURL:jsonUrl options:kNilOptions error:&error];
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    
    for( NSDictionary * json in jsonResponse )
    {
        _item = [[Item alloc] init];
        
        NSLog(@"title : %@",  [json objectForKey:@"title"] );
        NSLog(@"linkurl : %@",  [json objectForKey:@"linkurl"] );
        
        _item.title = [json objectForKey:@"title"];
        _item.linkurl = [json objectForKey:@"linkurl"];
        
        
        //NSLog(@"title : %@", _item.title);
        //NSLog(@"linkurl : %@", _item.linkurl);
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

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.cafeSearchBar resignFirstResponder];
}
- (IBAction)tapTable{
    [self.cafeSearchBar resignFirstResponder];
}

@end
