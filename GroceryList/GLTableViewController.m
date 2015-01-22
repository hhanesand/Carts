//
//  GLTableViewController.m
//  GroceryList
//
//  Created by Hakon Hanesand on 1/18/15.
//
//

#import "GLTableViewController.h"
#import "GLTableViewCell.h"
#import <Parse/Parse.h>
#import "AFNetworking.h"

static NSString *reuseIdentifier = @"GLTableViewCell";

@interface GLTableViewController()
@property (nonatomic) NSMutableArray *barcodes;
@property (nonatomic) NSString *apiKey;
@property (nonatomic) NSString *barcodeURL;
@property (nonatomic) NSString *barcodeURL2;
@end

@implementation GLTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.barcodes = [NSMutableArray new];
    self.apiKey = @"4308c0742cfa452985e8cd4d569336aa";
    self.barcodeURL = @"http://www.outpan.com/api/get-product.php?apikey=%@&barcode=%@";
    self.barcodeURL2 = @"http://upcmachine.com/search/list?commit=Go%2521&country=2&query=%@";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)didTapAddGroceryBarButton:(id)sender {
    ZBarReaderViewController *barcodeViewController = [ZBarReaderViewController new];
    barcodeViewController.readerDelegate = self;
    barcodeViewController.supportedOrientationsMask = ZBarOrientationMaskAll;

    [barcodeViewController.scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
    
    barcodeViewController.navigationItem.title = @"Scan Barcode";
    [self.navigationController pushViewController:barcodeViewController animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.barcodes count] == 0) {
        //notify the user that there are no saved items
        UILabel *noSavedBarcodesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
        noSavedBarcodesLabel.text = @"You have not saved any barcodes.";
        noSavedBarcodesLabel.textColor = [UIColor blackColor];
        noSavedBarcodesLabel.numberOfLines = 0;
        noSavedBarcodesLabel.textAlignment = NSTextAlignmentCenter;
        noSavedBarcodesLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:15];
        [noSavedBarcodesLabel sizeToFit];
        
        self.tableView.backgroundView = noSavedBarcodesLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        return 0;
    } else {
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.barcodes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GLTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.label.text = self.barcodes[indexPath.row];
    return cell;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    
    NSString *data;
    
    for (ZBarSymbol *symbol in results)
    {
        data = [NSString stringWithFormat:@"%@", symbol.data];
    }

    NSLog(@"%@", [data description]);
    
    [[[UIAlertView alloc] initWithTitle:@"Found" message:data delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:self.barcodeURL, self.apiKey, data] parameters:nil success:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"Name from first database : %@", response[@"name"]);
        
        [self.barcodes addObject:response[@"name"]];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://upcdatabase.idb.s1.jcink.com/upc.php?act=lookup&upc=%@", data]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSRange range = [string rangeOfString:@"Description" options:NSLiteralSearch];
        
        if (range.location == NSNotFound) {
            NSLog(@"The second database does not have this barcode");
            //the item does not exist in the second database we want to check
        } else {
            int start = range.location + range.length + 29;
            
            NSRange range1 = [string rangeOfString:@"<" options:NSLiteralSearch range:NSMakeRange(start, 100)];
            int end = range1.location;
            
            NSLog(@"Name from second database : %@", [string substringWithRange:NSMakeRange(start, end - start)]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error %@", error);
    }];
    [operation start];
    
    NSURL *URL2 = [NSURL URLWithString:[NSString stringWithFormat:@"http://upcmachine.com/search/list?commit=%@country=2&query=%@", @"Go%2521&",data]];
    NSURLRequest *request2 = [NSURLRequest requestWithURL:URL2];
    AFHTTPRequestOperation *operation2 = [[AFHTTPRequestOperation alloc] initWithRequest:request2];
    
    [operation2 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSRange range = [string rangeOfString:[NSString stringWithFormat:@"<td>%@</td>", data] options:NSLiteralSearch];
        
        if (range.location == NSNotFound) {
            NSLog(@"The third database does not have this barcode.");
        } else {
            long start = range.location + range.length;
            NSRange range1 = [string rangeOfString:@"<td>" options:NSLiteralSearch range:NSMakeRange(start, 100)];
            NSRange range2 = [string rangeOfString:@"</td>" options:NSLiteralSearch range:NSMakeRange(range1.location, 100)];
            
            NSLog(@"Name from thrid database : %@", [string substringWithRange:NSMakeRange(range1.location + range1.length, range2.location - (range1.location + range1.length))]);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error %@", error);
    }];
    [operation2 start];
    
    NSURL *URL3 = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.compariola.com/?barcode=%@", data]];
    NSURLRequest *request3 = [NSURLRequest requestWithURL:URL3];
    AFHTTPRequestOperation *operation3 = [[AFHTTPRequestOperation alloc] initWithRequest:request3];
    
    [operation3 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSRange range = [string rangeOfString:@"<h1>" options:NSLiteralSearch];
        
        if (range.location == NSNotFound) {
            NSLog(@"Database 4 does not have the barcode");
        } else {
            NSRange range1 = [string rangeOfString:@"</h1>" options:NSLiteralSearch range:NSMakeRange(range.location, 100)];
            NSLog(@"Name of item from 4th database : %@", [string substringWithRange:NSMakeRange(range.length + range.location, range1.location - (range.length + range.location))]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error %@", error);
    }];
    [operation3 start];
    
    NSURL *URL4 = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.hammerwall.com/upc/%@/", [data substringFromIndex:1]]];
    NSURLRequest *request4 = [NSURLRequest requestWithURL:URL4];
    AFHTTPRequestOperation *operation4 = [[AFHTTPRequestOperation alloc] initWithRequest:request4];
    
    [operation4 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSRange range = [string rangeOfString:@"Item: " options:NSLiteralSearch];
        
        if (range.location == NSNotFound) {
            NSLog(@"The barcode does not exist in database 5");
        } else {
            NSRange range1 = [string rangeOfString:@"<br>" options:NSLiteralSearch range:NSMakeRange(range.location, 100)];
            NSLog(@"Name of item from database 5 : %@", [string substringWithRange:NSMakeRange(range.length + range.location, range1.location - (range.length + range.location))]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error %@", error);
    }];
    [operation4 start];
}

@end
