#import <UIKit/UIKit.h>
#import "Item.h"
#import <CoreLocation/CoreLocation.h>

@interface KeywordViewController : UITableViewController <UISearchBarDelegate, CLLocationManagerDelegate, NSXMLParserDelegate>{
    // ロケーションマネージャー
    CLLocationManager* locationManager;
    
    // 現在位置記録用
    CLLocationDegrees _longitude;
    CLLocationDegrees _latitude;

}

@property IBOutlet UISearchBar *cafeSearchBar;
- (IBAction)tapTable;

@end
