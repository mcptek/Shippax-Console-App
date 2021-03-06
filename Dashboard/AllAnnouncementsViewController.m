//
//  AllAnnouncementsViewController.m
//  Dashboard
//
//  Created by Rafay Hasan on 8/22/16.
//  Copyright © 2016 Rafay Hasan. All rights reserved.
//

#import "AllAnnouncementsViewController.h"
#import "AllAnnouncementCellTableViewCell.h"
#import "FTPopOverMenu.h"
#import "FSCalendar.h"
#import "RHWebServiceManager.h"
#import "SVProgressHUD.h"
#import "AnnounceObject.h"
#import "UIImageView+AFNetworking.h"
#import "Reachability.h"

@interface AllAnnouncementsViewController ()<UITextViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate,FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance,RHWebServiceDelegate,UISearchBarDelegate>
{
    BOOL viewMode,AddMode,editMode;
    NSString *ageRecipient,*genderRecipient;
}

@property (weak , nonatomic) FSCalendar *calendar;
@property (strong,nonatomic) UIImagePickerController *picker;
@property (strong,nonatomic) RHWebServiceManager *myWebservice;
@property (strong,nonatomic) NSArray *allDataArray;
@property (strong,nonatomic) NSMutableArray *announcementArray,*filteredArray,*selectedDates;
@property (strong,nonatomic) NSDateFormatter* formatter;
@property (strong,nonatomic) NSData* pictureData;
@property (strong,nonatomic) NSString *pickerTime;
@property (strong,nonatomic) Reachability *internetReachability;
@property (strong,nonatomic) UIActivityIndicatorView *indicator;
@property (strong,nonatomic) FTPopOverMenuConfiguration *configuration;

@property (weak, nonatomic) IBOutlet UILabel *selectedCategoryLabel;
@property (weak, nonatomic) IBOutlet UITextView *bulletinTextView;
@property (weak, nonatomic) IBOutlet UITableView *bulletinTableview;
@property (weak, nonatomic) IBOutlet UIView *editView;
@property (weak, nonatomic) IBOutlet UIView *addView;
@property (weak, nonatomic) IBOutlet UIDatePicker *myDatePickerview;
@property (weak, nonatomic) IBOutlet UIView *scheduleView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *senderTextfield;
@property (weak, nonatomic) IBOutlet UIView *scheduleSaveView;
@property (weak, nonatomic) IBOutlet UIButton *scheduleSaveButton;
@property (weak, nonatomic) IBOutlet UIButton *scheduleCancelButton;
@property (weak, nonatomic) IBOutlet UIImageView *bulletinImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *mediaScrollView;
@property (weak, nonatomic) IBOutlet UIView *attachmentView;
@property (weak, nonatomic) IBOutlet UIView *sendAnnouncementView;
@property (weak, nonatomic) IBOutlet UIButton *categorySelectionButton;
@property (weak, nonatomic) IBOutlet UIView *announceDiscardView;
@property (weak, nonatomic) IBOutlet UILabel *categorySearchedLabel;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *recipientButton;



- (IBAction)addButtonAction:(id)sender;
- (IBAction)editButtonAction:(id)sender;
- (IBAction)categoryButtonAction:(id)sender;
- (IBAction)attachmentButtonAction:(id)sender;
- (IBAction)scheduleButtonAction:(id)sender;
- (IBAction)scheduleSaveButtonAction:(id)sender;
- (IBAction)scheduleCancelVuttonAction:(id)sender;
- (IBAction)bulletinSendButtonAction:(id)sender;
- (IBAction)bulletinDiscardButtonAction:(id)sender;
- (IBAction)titleChangesAction:(id)sender;
- (IBAction)searchFilterButtonAction:(id)sender;
- (IBAction)recipientAction:(UIButton *)sender;

@end

@implementation AllAnnouncementsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //en
    
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];

    self.configuration = [FTPopOverMenuConfiguration defaultConfiguration];

    
    NSString *lan = [[NSUserDefaults standardUserDefaults]valueForKey:@"selectedLanguage"];
    if(lan.length == 0)
    {
        lan = @"en";
        [[NSUserDefaults standardUserDefaults]setObject:@"en" forKey:@"selectedLanguage"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
    
    self.categorySearchedLabel.text = @"All";
    
    self.selectedDates = [NSMutableArray new];
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];


    self.filteredArray = [NSMutableArray new];
    
    [self CallAllAnnouncements];
    
    self.picker = [[UIImagePickerController alloc] init];
    self.picker.delegate = self;
    self.picker.allowsEditing = YES;
    self.bulletinTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.formatter = [[NSDateFormatter alloc]init];
    
    self.scheduleSaveButton.layer.cornerRadius = 8;
    self.scheduleSaveButton.layer.masksToBounds = YES;
    
    self.scheduleCancelButton.layer.cornerRadius = 8;
    self.scheduleCancelButton.layer.masksToBounds = YES;
    
    [self makeAddModeOn];
    
    viewMode = NO;
    AddMode = YES;
    editMode = NO;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) viewDidAppear:(BOOL)animated
{
    self.bulletinTextView.textColor = [UIColor whiteColor];
}



- (void) makeAddModeOn
{
    [self.selectedDates removeAllObjects];
    
    
    viewMode = NO;
    AddMode = YES;
    editMode = NO;
    self.attachmentView.hidden = NO;
    self.sendAnnouncementView.hidden = NO;
    self.pictureData = nil;
    self.bulletinImageView.image = nil;
    self.scheduleView.hidden = YES;
    self.scheduleSaveView.hidden = YES;
    [self clearAllSelectedDatesOfCalender];
    [self showScheduleViewWithAllowSelection:YES multipleSelectionAllowed:YES selectedDate:nil Time:nil];
    //self.characterLeftLabel.text = @"[Characters left 1000]";
    
    self.announceDiscardView.hidden = NO;
    self.addView.hidden = YES;
    self.editView.hidden = YES;
    self.senderTextfield.text = @"Test users";
    self.senderTextfield.userInteractionEnabled = NO;
    self.titleTextField.text = @"";
    self.titleTextField.userInteractionEnabled = YES;
    self.bulletinTextView.text = @"Type your message.";
    self.bulletinTextView.userInteractionEnabled = YES;
    self.myDatePickerview.userInteractionEnabled = YES;
    self.categorySelectionButton.userInteractionEnabled = YES;
    self.selectedCategoryLabel.text = @"Announcements";
    
    [self.recipientButton setTitle:@"Recipient" forState:UIControlStateNormal];
    self.recipientButton.userInteractionEnabled = YES;
//    CGRect frame = self.recipientButton.frame;
//    frame.size.width = self.recipientButton.intrinsicContentSize.width + 5;
//    self.recipientButton.frame = frame;

    
    [self.bulletinImageView cancelImageRequestOperation];



}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark Webservice methods

-(void) CallAllAnnouncements
{
    [SVProgressHUD show];
    NSString *urlStr = [NSString stringWithFormat:@"%@/api/bulletin/get",BASE_URL_API];
    self.myWebservice = [[RHWebServiceManager alloc]initWebserviceWithRequestType:HTTPRequestTypAllAnnouncementInfo Delegate:self];
    [self.myWebservice getDataFromWebURL:urlStr];
    
   
}


-(void) dataFromWebReceivedSuccessfully:(id) responseObj
{
    [SVProgressHUD dismiss];
    
    if(self.myWebservice.requestType == HTTPRequestTypAllAnnouncementInfo)
    {
        if(self.announcementArray.count > 0)
        {
            [self.announcementArray removeAllObjects];
            self.announcementArray = nil;
            self.allDataArray = nil;
        }
        
        self.announcementArray = [[NSMutableArray alloc]initWithArray:responseObj];
        self.allDataArray = [[NSArray alloc]initWithArray:self.announcementArray];
        [self.bulletinTableview reloadData];
        
    }
    else if (self.myWebservice.requestType == HTTPRequestTypAnnouncementDelete || self.myWebservice.requestType == HTTPRequestTypAnnouncementInsert)
    {
        
        NSString *message;
        if(self.myWebservice.requestType == HTTPRequestTypAnnouncementInsert)
        {
            [self makeAddModeOn];
            if(AddMode)
                message = @"Successfully sent.";
            else
                message = @"Successfully updated.";
        }
        else
        {
            message = @"Announcement has been deleted successfully.";
        }
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Message"
                                     message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Okay"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        
                                        [self dismissViewControllerAnimated:YES completion:nil];
                                    }];
        
        
        [alert addAction:yesButton];
        [self presentViewController:alert animated:YES completion:nil];

        [self CallAllAnnouncements];
    }
}

-(void) dataFromWebReceiptionFailed:(NSError*) error
{
    [SVProgressHUD dismiss];
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Error"
                                 message:error.localizedDescription
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Okay"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    
                                    [self dismissViewControllerAnimated:YES completion:nil];
                                }];
    
    
    [alert addAction:yesButton];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) dataFromWebDidnotReceiveSuccessMessage:( NSInteger )statusCode
{
    [SVProgressHUD dismiss];
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Message"
                                 message:[NSString stringWithFormat:@"Error %li,Please try again later.",(long)statusCode]
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Okay"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    
                                    [self dismissViewControllerAnimated:YES completion:nil];
                                }];
    
    
    [alert addAction:yesButton];
    [self presentViewController:alert animated:YES completion:nil];

}


#pragma mark Table View Delegate Methods starts


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return self.announcementArray.count;
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell     forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *MyIdentifier = @"announcementCell";
    
    AllAnnouncementCellTableViewCell *cell =(AllAnnouncementCellTableViewCell*) [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[AllAnnouncementCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"AllAnnouncementCellTableViewCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    AnnounceObject *announce = [self.announcementArray objectAtIndex:indexPath.row];
    cell.bulletinTitle.text = announce.announceTitle;
    cell.bulletinDescription.text = announce.announceDescription;
    
    if(announce.announceCategory.length > 0)
    {
        if([announce.announceCategory isEqualToString:@"Announcements"])
            cell.categoryImageView.image = [UIImage imageNamed:@"CateforyAnnouncement"];
        else if ([announce.announceCategory isEqualToString:@"Offers"])
            cell.categoryImageView.image = [UIImage imageNamed:@"CategoryOffer"];
    }
    else
    {
        cell.categoryImageView.image = nil;
    }
    if(announce.scheduleArray.count > 0)
    {
        if(announce.scheduleArray.count == 1)
        {
            NSString *str = [NSString stringWithFormat:@"%@",[announce.scheduleArray objectAtIndex:0]];
            str = [str substringWithRange:NSMakeRange(0, 10)];
            cell.multiScheduleImageview.image = nil;
            cell.bulletinDate.text = str;
        }
        else
        {
            cell.multiScheduleImageview.image = [UIImage imageNamed:@"scheduleSetIcon"];
            cell.bulletinDate.text = @"";
        }
    }
    else
    {
        cell.multiScheduleImageview.image = nil;
        cell.bulletinDate.text = @"";
    }
    
    cell.deleteButton.tag = indexPath.row + 1000;
    [cell.deleteButton addTarget:self action:@selector(deleteAnnouncemntFromListAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    viewMode = YES;
    AddMode = NO;
    editMode = NO;
    self.categorySelectionButton.userInteractionEnabled = NO;
    self.recipientButton.userInteractionEnabled = NO;
    self.attachmentView.hidden = YES;
    self.sendAnnouncementView.hidden = YES;
    self.announceDiscardView.hidden = YES;
    
    if(self.addView.hidden == YES)
        self.addView.hidden = NO;
    
    if(self.editView.hidden == YES)
        self.editView.hidden = NO;
    
    self.scheduleSaveView.hidden = YES;
    
    AnnounceObject *announce = [self.announcementArray objectAtIndex:indexPath.row];
    
    self.titleTextField.text = announce.announceTitle;
    self.senderTextfield.text = announce.userType;
    self.titleTextField.userInteractionEnabled = NO;
    self.bulletinTextView.text = announce.announceDescription;
    self.bulletinTextView.userInteractionEnabled = NO;
    self.selectedCategoryLabel.text = announce.announceCategory;
    
    [self.bulletinImageView cancelImageRequestOperation];
    self.bulletinImageView.image = nil;
    [self.indicator removeFromSuperview];
    
    if(announce.announceImageUrlStr.length > 0)
    {
        [self loadImageWithUrlStr:announce.announceImageUrlStr]; //[self.bulletinImageView setImageWithURL:[NSURL URLWithString:announce.announceImageUrlStr]];
        self.pictureData = UIImageJPEGRepresentation(self.bulletinImageView.image,1.0);
    }
    else
    {
        self.bulletinImageView.image = nil;
        self.pictureData = nil;
    }
    [self MakeMediaScrollViewProperSized];
    
    if(announce.scheduleArray.count > 0)
    {
        [self.selectedDates removeAllObjects];
        self.selectedDates = [[NSMutableArray alloc]initWithArray:announce.scheduleArray];
        [self clearAllSelectedDatesOfCalender];
        
        [self showScheduleViewWithAllowSelection:NO multipleSelectionAllowed:YES selectedDate:announce.scheduleArray Time:announce.scheduleTime];
        self.myDatePickerview.userInteractionEnabled = NO;
        self.scheduleView.hidden = NO;
    }
    else
    {
        self.scheduleView.hidden = YES;
    }
}

- (void) loadImageWithUrlStr:(NSString *)imageUrl
{
    
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.indicator setCenter:self.bulletinImageView.center];
    [self.mediaScrollView addSubview:self.indicator];
    [self.indicator startAnimating];
    
    NSURL *url = [NSURL URLWithString:imageUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [self.bulletinImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [self.indicator removeFromSuperview];
        self.bulletinImageView.image = image;
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
        [self.indicator removeFromSuperview];
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Image Download Error"
                                     message:error.localizedFailureReason
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        
                                        [self dismissViewControllerAnimated:YES completion:nil];
                                    }];
        [alert addAction:yesButton];
        [self presentViewController:alert animated:YES completion:nil];

    }];
    
    
}


-(void) MakeMediaScrollViewProperSized
{
    CGFloat fixedWidth = self.bulletinTextView.frame.size.width;
    CGSize newSize = [self.bulletinTextView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = self.bulletinTextView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    self.bulletinTextView.frame = newFrame;
    
    if(self.bulletinImageView.image == nil)
        self.mediaScrollView.contentSize = CGSizeMake(self.mediaScrollView.frame.size.width, newFrame.size.height + 10);
    else
    {
        CGRect frame = self.bulletinImageView.frame;
        frame.origin.y = self.bulletinTextView.frame.origin.y + newFrame.size.height + 10;
        self.bulletinImageView.frame = frame;
        self.mediaScrollView.contentSize = CGSizeMake(self.mediaScrollView.frame.size.width, self.bulletinImageView.frame.origin.y + self.bulletinImageView.frame.size.height + 10);
    }
}

-(void) deleteAnnouncemntFromListAction:(UIButton *)sender
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Message"
                                 message:@"Do you want to delete?"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Yes"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    
                                    AnnounceObject *announce = [self.announcementArray objectAtIndex:sender.tag - 1000];
                                    [SVProgressHUD show];
                                    NSString *urlStr = [NSString stringWithFormat:@"%@/api/bulletin/delete",BASE_URL_API];
                                    self.myWebservice = [[RHWebServiceManager alloc]initWebserviceWithRequestType:HTTPRequestTypAnnouncementDelete Delegate:self];
                                    [self.myWebservice deleteBulletinwithId:announce.announceId UrlStr:urlStr];

                                }];
    UIAlertAction* cancellButton = [UIAlertAction
                                actionWithTitle:@"No"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    [self dismissViewControllerAnimated:YES completion:nil];
                                }];

    
    
    [alert addAction:yesButton];
    [alert addAction:cancellButton];
    [self presentViewController:alert animated:YES completion:nil];

    

}



- (IBAction)addButtonAction:(id)sender
{
    
    viewMode = NO;
    AddMode = YES;
    editMode = NO;
    [self makeAddModeOn];

}

- (IBAction)editButtonAction:(id)sender
{
    viewMode = NO;
    AddMode = NO;
    editMode = YES;
    self.attachmentView.hidden = NO;
    self.sendAnnouncementView.hidden = NO;
    self.announceDiscardView.hidden = NO;
    
    self.recipientButton.userInteractionEnabled = YES;
    
    self.titleTextField.userInteractionEnabled = YES;
    [self.titleTextField becomeFirstResponder];
    self.bulletinTextView.userInteractionEnabled = YES;
    self.calendar.allowsSelection = YES;
    self.calendar.allowsMultipleSelection = YES;
    self.myDatePickerview.userInteractionEnabled = YES;
    self.categorySelectionButton.userInteractionEnabled = YES;
    self.scheduleSaveView.hidden = NO;
    
}

- (IBAction)categoryButtonAction:(id)sender
{
    self.configuration.tintColor = [UIColor colorWithRed:210/255.0 green:217/255.0 blue:225.0/255.0 alpha:1];
    self.configuration.textColor = [UIColor blackColor];
    self.configuration.menuWidth = 170;
    self.configuration.textAlignment = NSTextAlignmentLeft;
    
    [FTPopOverMenu showForSender:sender withMenuArray:@[@"Announcements",@"Offers"] imageArray:@[@"CateforyAnnouncement",@"CategoryOffer"] doneBlock:^(NSInteger selectedIndex) {
        if(selectedIndex == 0)
            self.selectedCategoryLabel.text = @"Announcements";
        else
            self.selectedCategoryLabel.text = @"Offers";

    } dismissBlock:^{
        ;
    }];
}

- (IBAction)attachmentButtonAction:(id)sender
{
    if(AddMode || editMode)
    {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:nil
                                     message:@"Add image"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesAction = [UIAlertAction
                                    actionWithTitle:@"Camera"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        
                                        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                                        {
                                            self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                            //self.picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                                            self.picker.modalPresentationStyle = UIModalPresentationCurrentContext;
                                            [self presentViewController:self.picker animated:YES completion:NULL];
                                        }
                                        else
                                        {
                                            ;
                                        }
                                    }];
        
        UIAlertAction* noAction = [UIAlertAction
                                   actionWithTitle:@"Photo library"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                       self.picker.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                                       [self presentViewController:self.picker animated:YES completion:NULL];
                                   }];
        
        UIAlertAction* cancelButton = [UIAlertAction
                                       actionWithTitle:@"Cancel"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                           [self dismissViewControllerAnimated:YES completion:nil];
                                       }];
        
        
        [alert addAction:yesAction];
        [alert addAction:noAction];
        [alert addAction:cancelButton];
        
        [self presentViewController:alert animated:YES completion:nil];

    }
    else
    {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:nil
                                     message:@"Please add or edit an announcement first."
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* oklButton = [UIAlertAction
                                       actionWithTitle:@"Cancel"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                           [self dismissViewControllerAnimated:YES completion:nil];
                                       }];
        
        
        [alert addAction:oklButton];
        [self presentViewController:alert animated:YES completion:nil];

    }
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (BOOL)shouldAutorotate {
    return YES;
}


- (IBAction)scheduleButtonAction:(id)sender
{

    if(AddMode || editMode)
    {
        if(self.scheduleView.hidden == YES)
        {
            [self.view endEditing:YES];
            self.scheduleView.hidden = NO;
            self.scheduleSaveView.hidden = YES;
            [self showScheduleViewWithAllowSelection:YES multipleSelectionAllowed:YES selectedDate:nil Time:nil];
        }
        else
        {
            self.scheduleView.hidden = YES;
        }
    }
    else
    {
        if(self.scheduleView.hidden == YES)
            self.scheduleView.hidden = NO;
        else
            self.scheduleView.hidden = YES;
    }
}

- (IBAction)scheduleSaveButtonAction:(id)sender
{
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Message"
                                 message:@"Schedule set."
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Okay"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    
                                    NSMutableArray *selectedDatess = [NSMutableArray arrayWithCapacity:self.calendar.selectedDates.count];
                                    [self.calendar.selectedDates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                        [selectedDatess addObject:[self.calendar stringFromDate:obj format:@"yyyy/MM/dd"]];
                                    }];
                                    
                                    self.selectedDates = [[NSMutableArray alloc]initWithArray:selectedDatess];
                                    self.scheduleView.hidden  = YES;
                                    [self dismissViewControllerAnimated:YES completion:nil];
                                }];
    
    
    [alert addAction:yesButton];
    [self presentViewController:alert animated:YES completion:nil];

}

- (IBAction)scheduleCancelVuttonAction:(id)sender {
    
    for(id date in self.calendar.selectedDates)
    {
        [self.calendar deselectDate:date];
    }
    [self.selectedDates removeAllObjects];
    self.scheduleSaveView.hidden = YES;
}

- (IBAction)bulletinSendButtonAction:(id)sender
{
    
    if([self.bulletinTextView.text isEqualToString:@"Type your message."])
        self.bulletinTextView.text = @"";
    
    NSString *title = self.titleTextField.text;
    NSString *des = self.bulletinTextView.text;
    title = [title stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    des = [des stringByTrimmingCharactersInSet:
             [NSCharacterSet whitespaceCharacterSet]];
    

    if(title.length > 0 && des.length > 0)
    {
        [self.formatter setDateFormat:@"HH:mm:ss"];
        self.pickerTime = [self.formatter stringFromDate:self.myDatePickerview.date];
        
        NSMutableDictionary *dic = [NSMutableDictionary new];
        NSMutableArray *timeArray = [NSMutableArray new];
        //NSDateFormatter *bulletinDateFormatter = [[NSDateFormatter alloc] init];
        //NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        
        if(self.calendar.selectedDates.count > 0)
        {
            NSMutableArray *selectedDates = [NSMutableArray arrayWithCapacity:self.calendar.selectedDates.count];
            [self.calendar.selectedDates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [selectedDates addObject:[self.calendar stringFromDate:obj format:@"yyyy/MM/dd"]];
            }];
            
            for(NSInteger i = 0; i < selectedDates.count; i++)
            {
                NSDateFormatter *bulletinDateFormatter = [[NSDateFormatter alloc] init];
                NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
                NSString *dateStr = [NSString stringWithFormat:@"%@",[selectedDates objectAtIndex:i]];
                dateStr = [dateStr substringWithRange:NSMakeRange(0, 10)];
                dateStr = [NSString stringWithFormat:@"%@ %@",dateStr,self.pickerTime];
                
                
                [bulletinDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSDate *date = [bulletinDateFormatter dateFromString:dateStr];
                
                [bulletinDateFormatter setTimeZone:timeZone];
                [bulletinDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                
                [timeArray addObject:[NSString stringWithFormat:@"%@",[bulletinDateFormatter stringFromDate:date]]];
            }
            
        }
        else
        {
            
            [self checkDate];
            NSDateFormatter *bulletinDateFormatter = [[NSDateFormatter alloc] init];
            NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
            NSString *dateStr = [NSString stringWithFormat:@"%@",[self.calendar stringFromDate:self.calendar.today format:@"yyyy/MM/dd"]];
            dateStr = [dateStr substringWithRange:NSMakeRange(0, 10)];
            dateStr = [NSString stringWithFormat:@"%@ %@",dateStr,self.pickerTime];
            
            [bulletinDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *date = [bulletinDateFormatter dateFromString:dateStr];
            
            [bulletinDateFormatter setTimeZone:timeZone];
            [bulletinDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            [timeArray addObject:[NSString stringWithFormat:@"%@",[bulletinDateFormatter stringFromDate:date]]];
        }
        
        
        [dic setObject:timeArray forKey:@"send_time[]"];
        [dic setObject:@"123" forKey:@"user_id"];
        [dic setObject:title forKey:@"title"];
        [dic setObject:des forKey:@"text[]"];
        [dic setObject:self.selectedCategoryLabel.text forKey:@"category_name"];
        [dic setObject:[[NSUserDefaults standardUserDefaults]valueForKey:@"selectedLanguage"] forKey:@"languageFilter"];
        [dic setObject:@"all" forKey:@"ageGroupFilter"];
        [dic setObject:@"both" forKey:@"genderFilter"];
        
        self.myWebservice = [[RHWebServiceManager alloc]initWebserviceWithRequestType:HTTPRequestTypAnnouncementInsert Delegate:self];
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Message"
                                     message:@"Are you sure you want to send this bulletin?"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Yes"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        
                                        [SVProgressHUD show];
                                        
                                        if([self.senderTextfield.text isEqualToString:@"All"])
                                        {
                                            if(AddMode)
                                            {
                                                [self.myWebservice sendBulletinWithData:dic withUrlStr:[NSString stringWithFormat:@"%@/api/bulletin/",BASE_URL_API] withImageData:self.pictureData forAPI:@"Schedule"];
                                            }
                                            else if (editMode)
                                            {
                                                NSIndexPath *selectedIndexPath = [self.bulletinTableview indexPathForSelectedRow];
                                                AnnounceObject *announce = [self.announcementArray objectAtIndex:selectedIndexPath.row];
                                                [dic setObject:announce.announceId forKey:@"id"];
                                                [self.myWebservice sendBulletinWithData:dic withUrlStr:[NSString stringWithFormat:@"%@/api/bulletin/",BASE_URL_API] withImageData:self.pictureData forAPI:@"Update"];
                                            }
                                        }
                                        else
                                        {
                                            [self.myWebservice sendBulletinWithData:dic withUrlStr:[NSString stringWithFormat:@"%@/api/bulletin/",BASE_URL_API] withImageData:self.pictureData forAPI:@"targeted"];
                                        }
                                        
                                        [self dismissViewControllerAnimated:YES completion:nil];
                                        
                                    }];
        
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:@"No"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
                                       
                                       [self dismissViewControllerAnimated:YES completion:nil];
                                       
                                   }];
        
        [alert addAction:noButton];
        [alert addAction:yesButton];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    else
    {
        NSString *message;
        if(title.length == 0)
        {
            if([self.selectedCategoryLabel.text isEqualToString:@"Announcements"])
               message = @"Please enter announcement title.";
            else if ([self.selectedCategoryLabel.text isEqualToString:@"Offers"])
                message = @"Please enter offer title.";
        }
        else
        {
            if([self.selectedCategoryLabel.text isEqualToString:@"Announcements"])
                message = @"Please enter announcement description.";
            else if ([self.selectedCategoryLabel.text isEqualToString:@"Offers"])
                message = @"Please enter offer description.";
            
            if([self.bulletinTextView.text isEqualToString:@""])
                self.bulletinTextView.text = @"Type your message.";

        }
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Alert"
                                     message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Okay"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {

                                        [self dismissViewControllerAnimated:YES completion:nil];
                                    }];
        
        
        [alert addAction:yesButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    
}



-(void) checkDate
{
    NSDate *date1 = [NSDate date];
    NSDate *date2 = self.myDatePickerview.date;
    
    NSLog(@"Date1 is %@ and date 2 is %@",date1,date2);
    
    if ([date1 compare:date2] == NSOrderedDescending) {
        
        [self.formatter setDateFormat:@"HH:mm:ss"];
        self.pickerTime = [self.formatter stringFromDate:date1];
       
    } else if ([date1 compare:date2] == NSOrderedAscending) {
        NSLog(@"firstDate is earlier than secondDate");
        
    } else {
        NSLog(@"firstDate and secondDate are the same");
    }

}


- (IBAction)bulletinDiscardButtonAction:(id)sender
{
    if(AddMode || editMode)
    {
        [self makeAddModeOn];
    }
}

- (IBAction)titleChangesAction:(UITextField *)sender {
    
    
    if(sender.text.length == 50)
    {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Message"
                                     message:@"Title characters limit is 50!"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Okay"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        
                                        [self dismissViewControllerAnimated:YES completion:nil];
                                    }];
        
        
        [alert addAction:yesButton];
        [self presentViewController:alert animated:YES completion:nil];
    }

}

- (IBAction)searchFilterButtonAction:(id)sender {
    
    self.configuration.tintColor = [UIColor colorWithRed:210/255.0 green:217/255.0 blue:225.0/255.0 alpha:1];
    self.configuration.textColor = [UIColor blackColor];
    self.configuration.menuWidth = 170;
    self.configuration.textAlignment = NSTextAlignmentLeft;
    
    [FTPopOverMenu showForSender:sender withMenuArray:@[@"All",@"Announcements",@"Offers"] imageArray:@[@"Alll",@"CateforyAnnouncement",@"CategoryOffer"] doneBlock:^(NSInteger selectedIndex)
    {
        if(selectedIndex == 0)
        {
            self.categorySearchedLabel.text = @"All";
            [self loadDataForCategory:@"All"];
        }
        else if(selectedIndex == 1)
        {
            self.categorySearchedLabel.text = @"Announcements";
            [self loadDataForCategory:@"Announcements"];
        }
        else
        {
            self.categorySearchedLabel.text = @"Offers";
            [self loadDataForCategory:@"Offers"];
        }

    } dismissBlock:^{
        ;
    }];
    
}

#pragma mark Attachment Button Action


-(void) loadDataForCategory:(NSString *)categoryName
{
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    [self.announcementArray removeAllObjects];
    self.announcementArray = [NSMutableArray new];

    
    if([categoryName isEqualToString:@"All"])
    {
        self.announcementArray = [[NSMutableArray alloc]initWithArray:self.allDataArray];
    }
    else
    {
        for(AnnounceObject *object in  self.allDataArray)
        {
            if([object.announceCategory isEqualToString:categoryName])
               [self.announcementArray addObject:object];
        }

    }
    
    [self.bulletinTableview reloadData];

}

#pragma mark Texfield methods


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length)
    {
        return NO;

    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 50;
}


#pragma mark Textview methods


//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//    return textView.text.length + (text.length - range.length) <= 1000;
//}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Type your message."]) {
        textView.text = @"";
    }
    else
    {
        textView.textColor = [UIColor whiteColor];
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Type your message.";
    }
    else
    {
        textView.textColor = [UIColor whiteColor];
    }
    [textView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView
{
   //self.characterLeftLabel.text = [NSString stringWithFormat:@"[Characters left %lu]", 1000 - self.bulletinTextView.text.length];
   [self MakeMediaScrollViewProperSized];
}

#pragma mark Picker methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    self.bulletinImageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    //self.pictureData = UIImagePNGRepresentation(self.bulletinImageView.image);
    self.pictureData = UIImageJPEGRepresentation(self.bulletinImageView.image,1.0);
    
    [self MakeMediaScrollViewProperSized];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark Calander delegate methods

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date
{
    
    NSString *todayDateStr = [NSString stringWithFormat:@"%@",[self.calendar stringFromDate:self.calendar.today format:@"yyyy/MM/dd"]];
    NSString *selectedDateStr = [NSString stringWithFormat:@"%@",[self.calendar stringFromDate:date format:@"yyyy/MM/dd"]];
    
    
    selectedDateStr = [selectedDateStr substringWithRange:NSMakeRange(0, 10)];
    self.formatter.dateFormat = @"yyyy-MM-dd";
    NSTimeInterval selectedSeconds = [[self.formatter dateFromString:selectedDateStr] timeIntervalSince1970];
    NSTimeInterval currentSeconds = [[self.formatter dateFromString:todayDateStr] timeIntervalSince1970];
    if(selectedSeconds >= currentSeconds)
        return YES;
    else
    {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Error"
                                     message:@"Please select a valid date."
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Okay"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        
                                        [self dismissViewControllerAnimated:YES completion:nil];
                                    }];
        
        
        [alert addAction:yesButton];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
    }
    
    
    return YES;
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date
{
    if(self.calendar.selectedDates.count > 0)
        self.scheduleSaveView.hidden = NO;
    else
        self.scheduleSaveView.hidden = YES;
}

- (void)calendar:(FSCalendar *)calendar didDeselectDate:(NSDate *)date
{
    if(self.calendar.selectedDates.count > 0)
        self.scheduleSaveView.hidden = NO;
    else
        self.scheduleSaveView.hidden = YES;

}

- (void) showScheduleViewWithAllowSelection:(BOOL)calenderSelection multipleSelectionAllowed:(BOOL)multipleSelection selectedDate:(NSArray *)Dates Time:(NSString *)time
{
   
    for (UIView *subView in self.scheduleView.subviews)
    {    // UIView.subviews
        if (subView.tag == 9999) {
            [subView removeFromSuperview];
        }
    }
    
    FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(8, 8, 362, 241)];
    calendar.tag = 9999;
    calendar.backgroundColor = [UIColor whiteColor];
    calendar.allowsMultipleSelection = YES;
    calendar.appearance.weekdayTextColor = [UIColor redColor];
    calendar.appearance.headerTitleColor = [UIColor redColor];
    calendar.appearance.eventDefaultColor = [UIColor greenColor];
    calendar.appearance.selectionColor = [UIColor colorWithRed:3.0/255.0 green:75.0/255.0 blue:110.0/255.0 alpha:1];
    calendar.appearance.todayColor = [UIColor orangeColor];
    calendar.appearance.todaySelectionColor = [UIColor blackColor];
    calendar.clipsToBounds = YES;
    calendar.dataSource = self;
    calendar.delegate = self;
    [self.scheduleView addSubview:calendar];
    self.calendar = calendar;
    
    [self.view bringSubviewToFront:self.calendar];

    
    for(NSInteger i = 0; i < Dates.count; i++)
    {
        NSString *myDate = [NSString stringWithFormat:@"%@",[Dates objectAtIndex:i]];
        myDate = [myDate substringWithRange:NSMakeRange(0, 20)];
        self.formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSDate *date = [self.formatter dateFromString:myDate];
        [self.calendar selectDate:date];
        
        //[self.calendar selectDate:[Dates objectAtIndex:i]];
    }
    
    self.calendar.allowsMultipleSelection = multipleSelection;
    self.calendar.allowsSelection = calenderSelection;
    
    if(time.length > 0)
    {
        self.formatter.dateFormat = @"HH:mm";
        NSDate *date = [self.formatter dateFromString:time]; //dateFormatter.dateFromString("17:00");
        self.myDatePickerview.date = date;

    }
    else
    {
        self.myDatePickerview.date = [NSDate date];
    }
     //self.scheduleView.hidden = NO;
}

- (void) clearAllSelectedDatesOfCalender
{
    self.calendar.allowsMultipleSelection = YES;
    self.calendar.allowsSelection = YES;
    for (NSDate *date in self.calendar.selectedDates) {
        [self.calendar deselectDate:date];
    }

}

#pragma mark Search Bar Delegate Methods


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(searchText.length == 0)
    {
        [self loadDataForCategory:self.categorySearchedLabel.text];
    }
    else
    {
        [self.filteredArray removeAllObjects];
        
        for (NSInteger i=0; i < [self.allDataArray count];i++)
        {
            AnnounceObject *object = [self.allDataArray objectAtIndex:i];
            NSRange title = [object.announceTitle  rangeOfString:searchText options:NSCaseInsensitiveSearch];
            NSRange descrip = [object.announceDescription  rangeOfString:searchText options:NSCaseInsensitiveSearch];
            
            if (title.location != NSNotFound || descrip.location != NSNotFound)
            {
                if([self.categorySearchedLabel.text isEqualToString:@"All"] || self.categorySearchedLabel.text.length == 0)
                    [self.filteredArray addObject:[self.allDataArray objectAtIndex:i]];
                else
                {
                    if([self.categorySearchedLabel.text isEqualToString:object.announceCategory])
                        [self.filteredArray addObject:[self.allDataArray objectAtIndex:i]];
                }
                
                
            }
        }
        
        [self.announcementArray removeAllObjects];
        self.announcementArray = nil;
        self.announcementArray = [[NSMutableArray alloc]initWithArray:self.filteredArray];
        
    }
    [self.bulletinTableview reloadData];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:YES];
}

#pragma MARK Reachibility Status

- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    
    if(netStatus == NotReachable)
    {
        // lost network connection
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Message"
                                     message:@"You are not connected to WIFI!"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Okay"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        
                                        [self dismissViewControllerAnimated:YES completion:nil];
                                    }];
        
        
        [alert addAction:yesButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    else if (netStatus == ReachableViaWiFi)
    {
        ;
    }
    else if (netStatus == ReachableViaWWAN)
    {
        ;
        
    }
    
    
}


- (IBAction)recipientAction:(UIButton *)sender
{
    self.configuration.tintColor = [UIColor colorWithRed:210/255.0 green:217/255.0 blue:225.0/255.0 alpha:1];
    self.configuration.textColor = [UIColor blackColor];
    self.configuration.textAlignment = NSTextAlignmentCenter;
    
    [FTPopOverMenu showForSender:sender withMenuArray:@[@"All",@"Test users"] doneBlock:^(NSInteger selectedIndex)
    {
        if(selectedIndex == 0)
            self.senderTextfield.text = @"All";
        else
            self.senderTextfield.text = @"Test users";
    } dismissBlock:^{
        ;
    }
     ];
}
@end
