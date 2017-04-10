//
//  JMViewController.m
//  BIC_Task
//
//  Created by John Maltsev on 01.04.17.
//  Copyright © 2017 JMCorp. All rights reserved.
//

@import AVKit;

#import "JMViewController.h"
#import "JMServerManager.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface JMViewController ()

@property (weak, nonatomic) UIView *myView;

@property (nonatomic, strong) UIImagePickerController* first;
@property (nonatomic, strong) UIImagePickerController* second;

@property (nonatomic, strong) AVURLAsset *video01;
@property (nonatomic, strong) AVURLAsset *video02;
@end

@implementation JMViewController

- (void) loadView {
    [super loadView];
    
    [self initView];
    [self initButtons];
    
    //если запускаю на симмуляторе, а у него нет камеры, то выведет ошибку.UIImagePickerController-VC c камерой
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
        //в случае onSuccess мы получаем соль и после этого мы можем запрашивать токен (без соли не сможем запросить токен)
        NSLog(@"salt: %@", salt);
        
        [[JMServerManager sharedManager] getAccessTokenForUserPassword:@"123456" useUserName:@"test" onSuccess:^(JMAccessToken *token) {
            NSLog(@"%@", token.token);
            
        } onFailure:^(NSArray *errors) {
            //NSLog(@"%@", errors.token);
        }];
        
    } onFailure:^(NSArray *errors) {
        //прилетел сюда JMErrorObject / сделал приведение типа взяли 1й обект и достучались до  его message
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

//Allert - это всплыв диалоговое окно (здесь с ошибкой)
#pragma mark - Alert Method

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
    self.first = [[UIImagePickerController alloc] init];
    self.first.delegate = self;
    self.first.allowsEditing = YES;
    self.first.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.first.mediaTypes =
    [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
    [self presentViewController: self.first animated:YES completion:nil];
    
}

- (void)actionSecondVideo: (UIButton*) sender {
    self.second = [[UIImagePickerController alloc] init];
    self.second.delegate = self;
    self.second.allowsEditing = YES;
    self.second.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.second.mediaTypes =
    [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
    [self presentViewController:self.second animated:YES completion:nil];
    
    NSLog(@"actionSecondVideo");
}

- (void)actionCombineVideo: (UIButton*) sender {
    [self mergeVideo];
    NSLog(@"actionCombineVideo");
}

- (void)actionSendVideo: (UIButton*) sender {
    
    NSLog(@"actionSendVideo");
    
    NSString* mergedVideoPath= [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"merge_video.mp4"];  //myDocumentPath is NSString that gives path of output video(combined video)
    
    NSURL* urlVideo = [[NSURL alloc] initFileURLWithPath: mergedVideoPath];
    
    [self playVideoPlayer:urlVideo];
    
}

-(void) playVideoPlayer: (NSURL*) url {
    
    // create an AVPlayer
    AVPlayer *player = [AVPlayer playerWithURL:url];
    
    // create a player view controller
    AVPlayerViewController *controller = [[AVPlayerViewController alloc]init];
    controller.player = player;
    [player play];
    //show the view controller
    [self addChildViewController:controller];
    [self.view addSubview:controller.view];
    controller.view.frame = self.view.frame;
}


-(void)mergeVideo {
    
    AVMutableComposition* composition =  [AVMutableComposition composition];
    AVMutableCompositionTrack *composedTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                               preferredTrackID:kCMPersistentTrackID_Invalid];
    
    CMTimeRange firstTrackRange = CMTimeRangeMake(kCMTimeZero, self.video01.duration);
    AVAssetTrack* firstTrack = [[self.video01 tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    
    [composedTrack insertTimeRange:firstTrackRange
                           ofTrack:firstTrack atTime:kCMTimeZero error:nil];
    
    
    CMTimeRange secondTrackRange = CMTimeRangeMake(kCMTimeZero, self.video02.duration);
    AVAssetTrack* secondTrack = [[self.video02 tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    [composedTrack insertTimeRange: secondTrackRange
                           ofTrack:secondTrack atTime:self.video01.duration error:nil];
    
    
    NSString* myDocumentPath= [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"merge_video.mp4"];  //myDocumentPath is NSString that  gives path of output video(combined video)
    
    NSURL * urlVideoMain = [[NSURL alloc] initFileURLWithPath: myDocumentPath];    //urlVideoMain is Url of output video.
    
    if([[NSFileManager defaultManager] fileExistsAtPath:myDocumentPath]) {
        
        [[NSFileManager defaultManager] removeItemAtPath:myDocumentPath error:nil];
    }        //removes previous video at same path, essential
    
    //Сохранение полученного видео
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc]
                                      initWithAsset:composition
                                      presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL = urlVideoMain;
    exporter.outputFileType = @"com.apple.quicktime-movie";
    
    exporter.shouldOptimizeForNetworkUse = YES;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        
        switch ([exporter status]) {
                
            case AVAssetExportSessionStatusFailed:
                NSLog(@"AVAssetExportSessionStatusFailed");
                break;
                
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"AVAssetExportSessionStatusCancelled");
                break;
                
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"AVAssetExportSessionStatusCompleted");
                break;
                
            default:
                NSLog(@"default");
                break;
        }
    }];
}

// возвращает путь к песочнице нашего приложения
-(NSString*) applicationDocumentsDirectory {
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


#pragma mark - UIImagePickerControllerDelegate
//Когда нижимает кнопку useVideo то к нам в didFinishPickingMediaWithInfo прилетает инфоNSDictionary и мы извлекаем videoURL
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    //    [[JMServerManager sharedManager] uploadVideo:videoURL onSuccess:^(JMAccessToken *token) {
    //        NSLog(@"Video uploaded");
    //    } onFailure:^(NSArray *errors) {
    //        NSLog(@"Not Load");
    //    }];
    
    if ([picker isEqual:self.first]) {
        self.video01 = avAsset;
    }else {
        self.video02 = avAsset;
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
