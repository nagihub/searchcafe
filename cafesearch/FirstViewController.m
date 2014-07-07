
#import "FirstViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController
@synthesize searchIndicator;
@synthesize resultView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    resultView.delegate = self;
    
    self.searchBackButton.hidden = true;
    self.searchIndicator.hidden = true;

    CGRect screenSize = [UIScreen mainScreen].bounds;
    if (screenSize.size.height <= 480) {
        self.resultView.frame = CGRectMake(0,20,self.resultView.frame.size.width,screenSize.size.height-self.tabBarController.tabBar.frame.size.height);
        }
    
    [self becomeFirstResponder];
    
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)doSearch{
    self.resultView.hidden = false;
    
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
    }
    
}

- (IBAction)backSearch{
    //self.tabBarController.selectedIndex = 0;
    
    self.resultView.hidden = true;
    self.searchButton.hidden = false;
    self.searchBackButton.hidden = true;
    self.infoLabel.hidden = false;
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	// 位置情報更新
	_longitude = newLocation.coordinate.longitude;
	_latitude = newLocation.coordinate.latitude;
    
    [locationManager stopUpdatingLocation];

    NSString* urlString = [NSString stringWithFormat:@"http://nagitter.com/cafesearch/?lat=%f&lng=%f", _latitude, _longitude];
    NSURL* googleURL = [NSURL URLWithString: urlString];
    NSURLRequest* myRequest = [NSURLRequest requestWithURL: googleURL];
    
    [self.resultView loadRequest:myRequest];
    
    self.searchButton.hidden = true;
    self.searchBackButton.hidden = false;
    self.infoLabel.hidden = true;
    
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

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.searchIndicator startAnimating];
    self.searchIndicator.hidden = false;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES; //上部のバーの"ActivityIndicator"も動かす。

}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.searchIndicator stopAnimating];
    self.searchIndicator.hidden = true;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    self.resultView.hidden = false;
    
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
    }
}

/*
- (IBAction)naverbutton:(UIButton *)sender {
    self.tabBarController.selectedIndex = 1;
}

- (IBAction)togetterbutton:(UIButton *)sender {
    self.tabBarController.selectedIndex = 2;
}

- (IBAction)itaibutton:(UIButton *)sender {
    self.tabBarController.selectedIndex = 3;
}
 */



@end
