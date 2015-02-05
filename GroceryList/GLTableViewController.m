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
#import "GLBarcodeManager.h"
#import "ReactiveCocoa/ReactiveCocoa.h"

static NSString *reuseIdentifier = @"GLTableViewCell";

#define GLMakeRange(a, b) NSMakeRange(a, b - (a))

@interface GLTableViewController()
@property (nonatomic) NSMutableArray *barcodes;
@property (nonatomic) NSString *apiKey;
@property (nonatomic) NSString *barcodeURL;
@property (nonatomic) NSString *barcodeURL2;
@property (nonatomic) GLBarcodeManager *manager;
@property (nonatomic) NSMutableArray *tempNames;
@end

@implementation GLTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.barcodes = [NSMutableArray new];
    self.barcodeURL2 = @"http://upcmachine.com/search/list?commit=Go%2521&country=2&query=%@";
    self.tempNames = [NSMutableArray new];
    
    self.manager = [[GLBarcodeManager alloc] init];
    
    [self.manager.receiveInternetResponseSignal subscribeNext:^(id x) {
        NSLog(@"Recieved name : %@", x);
        [self.tempNames addObject:x];
    } error:^(NSError *error) {
        NSLog(@"Error during net request : %@", error);
    } completed:^{
        NSLog(@"Completed fetching names from the internet");
        [self didGetNamesFromServers];
    }];

    [self.manager addBarcodeDatabase:[[GLBarcodeDatabase alloc] initWithNameOfDatabase:@"http://www.outpan.com/api/get-product.php?apikey=4308c0742cfa452985e8cd4d569336aa&barcode=%@" withReturnType:GLBarcodeDatabaseJSON andPath:@"name"]];
    
    [self.manager addBarcodeDatabase:[[GLBarcodeDatabase alloc] initWithNameOfDatabase:@"http://upcdatabase.idb.s1.jcink.com/upc.php?act=lookup&upc=%@" withReturnType:GLBarcodeDatabaseHTLM andPath:@"/html/body/center[1]/table/tbody/tr[4]/td[3]"]];
    
    [self.manager addBarcodeDatabase:[[GLBarcodeDatabase alloc] initWithNameOfDatabase:@"http://upcmachine.com/search/list?commit=Go%2521&country=2&query=%@" withReturnType:GLBarcodeDatabaseHTLM andPath:@"//*[@id=\"main\"]/div[1]/table/tbody/tr[1]/td/table/tbody/tr[2]/td[2]"]];
    
    [self.manager addBarcodeDatabase:[[GLBarcodeDatabase alloc] initWithNameOfDatabase:@"http://www.compariola.com/?barcode=%@" withReturnType:GLBarcodeDatabaseHTLM andPath:@"//*[@id=\"headerTxt\"]/h1"]];
    
    //looks like hammerwall is down?
//    [self.manager addBarcodeDatabase:[[GLBarcodeDatabase alloc] initWithNameOfDatabase:@"http://www.hammerwall.com/upc/%@/" withReturnType:GLBarcodeDatabaseHTLM andPath:<#(NSString *)#> andBarcodeModifier:^NSString *(NSString *barcode) {
//        return [barcode substringFromIndex:1];
//    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)didTapAddGroceryBarButton:(id)sender {
    ZBarReaderViewController *barcodeViewController = [ZBarReaderViewController new];
    barcodeViewController.readerDelegate = self;
    barcodeViewController.supportedOrientationsMask = ZBarOrientationMaskAll;

    [barcodeViewController.scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
    barcodeViewController.showsCameraControls = NO;
    barcodeViewController.showsZBarControls = NO;
    
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
    [self.navigationController popViewControllerAnimated:YES];
    
    id<NSFastEnumeration> results = [info objectForKey:ZBarReaderControllerResults];
    
    NSString *data;
    
    for (ZBarSymbol *symbol in results)
    {
        data = [NSString stringWithFormat:@"%@", symbol.data];
    }

    NSLog(@"%@", [data description]);
    
    [self.manager fetchNameOfItemWithBarcode:data]; //returns values on signal receiveInternetResponseSignal
}

- (IBAction)didPressTestButton:(id)sender {

}

//Called after database fetching complete. Adds the best name for the item it can find by analyzing the occurences of words in the strings.
- (void)didGetNamesFromServers {
    NSMutableDictionary *wordDictionary = [[NSMutableDictionary alloc] init];
    
    for (NSString *nameOfScannedItem in self.tempNames) {
        NSArray *scannedItemWords = [nameOfScannedItem componentsSeparatedByString:@" "];
        
        for (NSString *word in scannedItemWords) {
            int numberOfOccurences = [[wordDictionary objectForKey:[word lowercaseString]] intValue];
            
            if (numberOfOccurences == 0) {
                //this word has not been added to the dictionary yet...
                NSArray *allKeys = [wordDictionary allKeys];
                
                for (NSString *string in allKeys) {
                    //... but let's check if something similar already exists
                    if ([self compareString:string toString:word] > 0.8f) {
                        int newValue = [[wordDictionary objectForKey:string] intValue];
                        [wordDictionary setObject:[NSNumber numberWithInt:++newValue] forKey:string];
                        continue;
                    }
                }
                
                //nope, nothing like this word is in the dictionary, so we add a new entry
                [wordDictionary setObject:[NSNumber numberWithInt:1] forKey:word];
            } else {
                //already exists, so we increment occurence
                [wordDictionary setObject:[NSNumber numberWithInt:++numberOfOccurences] forKey:[word lowercaseString]];
            }
            
        }
    }
    
    NSLog(@"Word dictionary %@", wordDictionary);
    NSMutableArray *allKeys = [[wordDictionary allKeys] mutableCopy];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:3];
    
    int high = 0;
    NSInteger pos = 0;
    
    //find the 3 words with the highest occurence
    for (int i = 0; i < 2; i++) {
        for (NSString *key in allKeys) {
            if ([[wordDictionary objectForKey:key] intValue] >= high) {
                pos = [allKeys indexOfObject:key];
                high = [[wordDictionary objectForKey:key] intValue];
            }
        }
    
        [result addObject:allKeys[pos]];
        [allKeys removeObjectAtIndex:pos];
        
        high = 0;
        pos = 0;
    }
    
    NSLog(@"Result %@", result);
    
    [self.barcodes addObject:[result componentsJoinedByString:@" "]];
    [self.tableView reloadData];
    
    [self fetchPicture:[result componentsJoinedByString:@" "]];
}

- (void)fetchPicture:(NSString *)string {

}

//returns the percentage of similar characters in a string : comparing "123" and "123" will return 1.0, while comparing "123$" and "1234" will return 0.75.
- (int)compareString:(NSString *)a toString:(NSString *)b {
    double similarCharacters = 0.0;
    
    for (int i = 0; i < MIN(a.length, b.length); i++) {
        if ([a characterAtIndex:i] == [b characterAtIndex:i]) {
            similarCharacters++;
        }
    }
    
    return similarCharacters / (double) MIN(a.length, b.length);
}

@end
