//
//  XYZBaseballAppViewController.m
//  baseball_ios
//
//  Created by Ryan Jung on 9/30/14.
//  Copyright (c) 2014 Ryan Jung. All rights reserved.
//

#import "XYZBaseballAppViewController.h"

@interface XYZBaseballAppViewController ()

@end

@implementation XYZBaseballAppViewController

@synthesize enteredSearchStr = _enteredSearchStr;
@synthesize enteredStartDate = _enteredStartDate;
@synthesize enteredEndDate = _enteredEndDate;

- (BOOL) textFieldShouldReturn:(UITextField *)TextField {
    [TextField resignFirstResponder];
    return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    self.apiReturnXMLData = [[NSMutableData alloc] init];
    [self.apiReturnXMLData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.apiReturnXMLData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"URL Connection Failed");
    currentConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    currentConnection = nil;
}

/* Function: searchPlayer
 * This function takes a search string from the UI, constructs an API call, and
 * places the closest match to the search string in a UI label on the main UI.
*/

- (IBAction)searchPlayer:(id)sender {
    // parse string and add url encoding for spaces
    NSString *encodedString = [self.searchStr.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    self.enteredSearchStr = encodedString;
    self.searchResults.text = @"";
    
    // Construct API call string and set up request
    NSString *restCallString = [NSString stringWithFormat:@"http://127.0.0.1:8000/players/index?user_response=%@", self.enteredSearchStr];
    NSURL *restURL = [NSURL URLWithString:restCallString];
    NSURLRequest *restRequest = [NSURLRequest requestWithURL:restURL];
    
    // ensure current connection is cleared
    if(currentConnection){
        [currentConnection cancel];
        currentConnection = nil;
        self.apiReturnXMLData = nil;
    }
    
    // send request asynchronously
    NSOperationQueue *requestQueue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:restRequest queue:requestQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(connectionError){
            self.apiReturnXMLData = nil;
            NSLog(@"error: %@", connectionError.localizedDescription);
        }
        [self.apiReturnXMLData appendData:data];
        
        // Get API response from JSON Dict
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        self.resultName = [jsonDict objectForKey:@"name"];
        
        // go to main queue to change UI element
        dispatch_async(dispatch_get_main_queue(), ^{
            self.searchResults.text = self.resultName;
        });
    }];
}

/* Function: scrape
 * This function takes the current closest match, start date, and end date, and
 * constructs an API call.  It then sends an asynchronous call to server, takes
 * returned JSON data, truncates to 2 decimal places, and converts to string.
 * Lastly, function constructs a response string that is used to update a label
 * in app's UI.
*/

- (IBAction)scrape:(id)sender {
    // Parse parameters and url encode them
    NSString *encodedPlayerName = [self.resultName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *encodedStartDate = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self.startDateSearchStr.text, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
    NSString *encodedEndDate = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self.endDateSearchStr.text, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
    
    self.enteredStartDate = encodedStartDate;
    self.enteredEndDate = encodedEndDate;
    self.scrapeResults.text = @"";
    
    // Construct API call string and set up request
    NSString *scrapeCallString = [NSString stringWithFormat:@"http://127.0.0.1:8000/players/scrape?player=%@&start_date=%@&end_date=%@", encodedPlayerName, self.enteredStartDate, self.enteredEndDate];
    NSURL *scrapeURL = [NSURL URLWithString:scrapeCallString];
    NSURLRequest *scrapeRequest = [NSURLRequest requestWithURL:scrapeURL];
    
    // ensure current connection is cleared
    if(currentConnection){
        [currentConnection cancel];
        currentConnection = nil;
        self.apiScrapeXMLData = nil;
    }
    
    // send request asynchronously and append result data to self.apiScrapeXMLData
    NSOperationQueue *scrapeQueue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:scrapeRequest queue:scrapeQueue completionHandler:^
     (NSURLResponse *scrapeResponse, NSData *scrapeData, NSError *scrapeConnectionError){
         if(scrapeConnectionError){
             self.apiScrapeXMLData = nil;
             NSLog(@"error: %@", scrapeConnectionError.localizedDescription);
         }
        [self.apiScrapeXMLData appendData:scrapeData];
         
         // Get API response from JSON Dict
         NSDictionary *scrapeJsonDict = [NSJSONSerialization JSONObjectWithData:scrapeData options:0 error:nil];
         self.vorp = [scrapeJsonDict objectForKey:@"vorp"];
         
         // use NSNumberFormatter to round NSNumber to 2 decimals and convert to string
         NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
         [formatter setNumberStyle:NSNumberFormatterDecimalStyle ];
         [formatter setMaximumFractionDigits:2];
         NSString *vorpString = [formatter stringForObjectValue:self.vorp];
        
         // go to main queue to construct response string and change UI element
         dispatch_async(dispatch_get_main_queue(), ^{
             NSString *resultsText = [NSString stringWithFormat:@"%@ from %@ to %@: VORP = %@", self.resultName, self.startDateSearchStr.text, self.endDateSearchStr.text, vorpString];
             self.scrapeResults.text = resultsText;
         });
     }];
}


@end
