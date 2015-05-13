//
//  CropImageViewController.m
//  Blocstagram
//
//  Created by Andrew Carvajal on 4/19/15.
//  Copyright (c) 2015 graffme, Inc. All rights reserved.
//

#import "CropImageViewController.h"
#import "CropBox.h"
#import "Media.h"
#import "UIImage+BLCImageUtilities.h"

@interface CropImageViewController ()

@property (nonatomic, strong) CropBox *cropBox;
@property (nonatomic, assign) BOOL hasLoadedOnce;
@property (nonatomic, strong) UIToolbar *topView;
@property (nonatomic, strong) UIToolbar *bottomView;


@end

@implementation CropImageViewController

- (instancetype)initWithImage:(UIImage *)sourceImage {
    self = [super init];
    if (self) {
        self.media = [[Media alloc] init];
        self.media.image = sourceImage;
        
        self.cropBox = [CropBox new];
        
        self.topView = [UIToolbar new];
        self.bottomView = [UIToolbar new];
        UIColor *whiteBG = [UIColor colorWithWhite:1.0 alpha:.15];
        self.topView.barTintColor = whiteBG;
        self.bottomView.barTintColor = whiteBG;
        self.topView.alpha = 0.5;
        self.bottomView.alpha = 0.5;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.clipsToBounds = YES;
    
    [self.view addSubview:self.cropBox];
    [self.view addSubview:self.topView];
    [self.view addSubview:self.bottomView];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Crop", @"Crop command") style:UIBarButtonItemStyleDone target:self action:@selector(cropPressed:)];
    
    self.navigationItem.title = NSLocalizedString(@"Crop Image", nil);
    self.navigationItem.rightBarButtonItem = rightButton;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    self.topView.frame = CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), width, 44);
    
    CGFloat yOriginOfBottomView = CGRectGetMaxY(self.topView.frame) + width;
    CGFloat heightOfBottomView = CGRectGetHeight(self.view.frame) - yOriginOfBottomView;
    self.bottomView.frame = CGRectMake(0, yOriginOfBottomView, width, heightOfBottomView);
    
    self.cropBox.frame = CGRectMake(0, CGRectGetMaxY(self.topView.frame), width, width);
    
    self.scrollView.frame = self.cropBox.frame;
    self.scrollView.center = self.cropBox.center;
    self.scrollView.clipsToBounds = NO;
    
//    [self recalculateZoomScale];
    
    if (self.hasLoadedOnce == NO ) {
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
        self.hasLoadedOnce = YES;
    }
}

- (void)cropPressed:(UIBarButtonItem *)sender {
    CGRect visibleRect;
    float scale = 1.0f / self.scrollView.zoomScale / self.media.image.scale;
    visibleRect.origin.x = self.scrollView.contentOffset.x * scale;
    visibleRect.origin.y = self.scrollView.contentOffset.y * scale;
    visibleRect.size.width = self.scrollView.bounds.size.width * scale;
    visibleRect.size.height = self.scrollView.bounds.size.height * scale;
    
    UIImage *scrollViewCrop = [self.media.image imageWithFixedOrientation];
    scrollViewCrop = [scrollViewCrop imageCroppedToRect:visibleRect];
    
    [self.delegate cropControllerFinishedWithImage:scrollViewCrop];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
