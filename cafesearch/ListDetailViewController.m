#import "ListDetailViewController.h"

@implementation ListDetailViewController
@synthesize linkurl;
@synthesize imgurl;

- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (self.detailItem) {
        self.title = [self.detailItem title];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    linkurl = [linkurl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    linkurl = [linkurl stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSURL *url = [NSURL URLWithString: linkurl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];

    float w = self.indicator.frame.size.width;
    float h = self.indicator.frame.size.height;
    float x = self.view.frame.size.width/2 - w/2;
    float y = self.view.frame.size.height/2 - h/2;
    self.indicator.frame = CGRectMake(x, y, w, h);

}

- (void)backButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)webViewDidStartLoad:(UIWebView*)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.indicator startAnimating];
}

-(void)webViewDidFinishLoad:(UIWebView*)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.indicator stopAnimating];
    self.indicator.hidesWhenStopped = YES;
}

@end
