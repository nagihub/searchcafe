#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AudioToolbox/AudioServices.h>

@interface FirstViewController : UIViewController <CLLocationManagerDelegate,UIWebViewDelegate>{
    // ロケーションマネージャー
    CLLocationManager* locationManager;
    
    // 現在位置記録用
    CLLocationDegrees _longitude;
    CLLocationDegrees _latitude;

    UIActivityIndicatorView* searchIndicator;
    UIWebView* resultView;
}

@property (strong, nonatomic) IBOutlet UIWebView *resultView;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *searchBackButton;
@property (nonatomic) IBOutlet UIActivityIndicatorView *searchIndicator;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

- (IBAction)doSearch;
- (IBAction)backSearch;

@end
