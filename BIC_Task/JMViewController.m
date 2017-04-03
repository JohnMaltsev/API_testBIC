//
//  JMViewController.m
//  BIC_Task
//
//  Created by John Maltsev on 01.04.17.
//  Copyright © 2017 JMCorp. All rights reserved.
//

#import "JMViewController.h"
#import "JMServerManager.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>

@interface JMViewController ()

@property (weak, nonatomic) UIView *myView;

@end

@implementation JMViewController

- (void) loadView {
    [super loadView];
    
    [self initView];
    [self initButtons];
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        [self showErrorDialogWith:@"Error" and:@"Device has no camera"];

    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getSaltAndToken];
}


-(void)getSaltAndToken {
    
    [[JMServerManager sharedManager] getSaltForUserLogin:@"test" onSuccess:^(NSString *salt) {
        
        NSLog(@"salt: %@", salt);
        
        [[JMServerManager sharedManager] getAccessTokenForUserPassword:@"123456" useUserName:@"test" onSuccess:^(JMAccessToken *token) {
            NSLog(@"%@", token.token);
            
        } onFailure:^(NSArray *errors) {
            //NSLog(@"%@", errors.token);
        }];
        
    } onFailure:^(NSArray *errors) {
        
        NSString * message = ((JMErrorObject *)errors.firstObject).message;
        NSString *title =  [NSString stringWithFormat:@"%ld", (long)((JMErrorObject *)errors.firstObject).errorCode];
        [self showErrorDialogWith:title and:message];
        
    }];
}



#pragma mark -  UIView Methods

- (void) initView {
    
    CGRect frame = self.view.bounds;
    frame.origin = CGPointZero;
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:view];
    self.myView = view;
    
}

#pragma mark - Initiazizad buttons

- (void) initButtons {
    
    UIButton *makeFirstVideo = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.view.bounds) - 45.f,CGRectGetMidY(self.view.bounds), 90, 30)];// поставил, что б кнопку на девайсе увидеть
    makeFirstVideo.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.3f];
    [makeFirstVideo setTitle:@"First Video" forState:UIControlStateNormal];
    makeFirstVideo.titleLabel.font = [UIFont systemFontOfSize:12.f];
    [makeFirstVideo setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    makeFirstVideo.layer.cornerRadius = 4;
    makeFirstVideo.layer.borderWidth = 0.4f;
    [self.view addSubview:makeFirstVideo];
    
    [makeFirstVideo addTarget:self action:@selector(actionFirstVideo:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *makeSecondVideo = [[UIButton alloc]initWithFrame:CGRectMake(160, 600, 90, 30)];
    makeSecondVideo.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.3f];
    [makeSecondVideo setTitle:@"Second Video" forState:UIControlStateNormal];
    makeSecondVideo.titleLabel.font = [UIFont systemFontOfSize:12.f];
    [makeSecondVideo setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    makeSecondVideo.layer.cornerRadius = 4;
    makeSecondVideo.layer.borderWidth = 0.4f;
    [self.view addSubview:makeSecondVideo];
    
    [makeSecondVideo addTarget:self action:@selector(actionSecondVideo:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *combineVideo = [[UIButton alloc]initWithFrame:CGRectMake(270, 600, 90, 30)];
    combineVideo.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.3f];
    [combineVideo setTitle:@"Combine Video" forState:UIControlStateNormal];
    combineVideo.titleLabel.font = [UIFont systemFontOfSize:12.f];
    [combineVideo setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    combineVideo.layer.cornerRadius = 4;
    combineVideo.layer.borderWidth = 0.4f;
    [self.view addSubview:combineVideo];
    
    [combineVideo addTarget:self action:@selector(actionCombineVideo:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *sendVideo = [[UIButton alloc]initWithFrame:CGRectMake(130, 650, 150, 30)];
    sendVideo.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.3f];
    [sendVideo setTitle:@"Send Video" forState:UIControlStateNormal];
    sendVideo.titleLabel.font = [UIFont systemFontOfSize:12.f];
    [sendVideo setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    sendVideo.layer.cornerRadius = 4;
    sendVideo.layer.borderWidth = 0.4f;
    [self.view addSubview:sendVideo];
    
    [sendVideo addTarget:self action:@selector(actionSendVideo:) forControlEvents:UIControlEventTouchUpInside];
}

-(void) showErrorDialogWith:(NSString*)title and:(NSString*)message  {
    
    UIAlertController* alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - Actions Buttons

- (void)actionFirstVideo: (UIButton*) sender {
    
    NSLog(@"actionFirstVideo");
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.mediaTypes =
    [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (void)actionSecondVideo: (UIButton*) sender {
    
    NSLog(@"actionSecondVideo");
}

- (void)actionCombineVideo: (UIButton*) sender {
    
    NSLog(@"actionCombineVideo");
}


- (void)actionSendVideo: (UIButton*) sender {
    
    NSLog(@"actionSendVideo");
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];

//    AVAsset *avAsset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
//    NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
    
    [[JMServerManager sharedManager] uploadVideo:videoURL onSuccess:^(JMAccessToken *token) {
        NSLog(@"Video uploaded");
    } onFailure:^(NSArray *errors) {
        NSLog(@"Not Load");
    }];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}


@end
