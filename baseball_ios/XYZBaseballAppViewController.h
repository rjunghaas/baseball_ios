//
//  XYZBaseballAppViewController.h
//  baseball_ios
//
//  Created by Ryan Jung on 9/30/14.
//  Copyright (c) 2014 Ryan Jung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XYZBaseballAppViewController : UIViewController <UITextFieldDelegate, NSURLConnectionDelegate>
{
    NSURLConnection *currentConnection;
}
- (IBAction)searchPlayer:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *searchStr;
@property (weak, nonatomic) IBOutlet UILabel *searchResults;
@property (copy, nonatomic) NSString *enteredSearchStr;
@property (retain, nonatomic) NSMutableData *apiReturnXMLData;
@property (copy, nonatomic) NSString *resultName;
@property (nonatomic) NSInteger *resultId;

- (IBAction)scrape:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *startDateSearchStr;
@property (weak, nonatomic) IBOutlet UITextField *endDateSearchStr;
@property (weak, nonatomic) IBOutlet UILabel *scrapeResults;
@property (copy, nonatomic) NSString *enteredStartDate;
@property (copy, nonatomic) NSString *enteredEndDate;
@property (weak, nonatomic) NSNumber *vorp;
@property (retain, nonatomic) NSMutableData *apiScrapeXMLData;

@end
