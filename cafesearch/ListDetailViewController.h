#import <Foundation/Foundation.h>

@interface ListDetailViewController : UIViewController{
    NSString *linkurl;
    NSString *imgurl;
}

@property (strong, nonatomic) id detailItem;
@property (nonatomic,retain) NSString *linkurl;
@property (nonatomic,retain) NSString *imgurl;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;



@end
