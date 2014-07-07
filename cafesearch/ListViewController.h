#import <UIKit/UIKit.h>
#import "Item.h"
#import <CoreLocation/CoreLocation.h>

@interface ListViewController : UITableViewController <NSXMLParserDelegate,CLLocationManagerDelegate>{
    // ロケーションマネージャー
    CLLocationManager* locationManager;
    
    // 現在位置記録用
    CLLocationDegrees _longitude;
    CLLocationDegrees _latitude;

}

@end
