//
//  MovieDetailsViewController.m
//  RottenTomatoes
//
//  Created by Nizha Shree Seenivasan on 10/20/15.
//  Copyright © 2015 Nizha Shree Seenivasan. All rights reserved.
//

#import "MovieDetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface MovieDetailsViewController () <UIScrollViewDelegate, UITextViewDelegate>
@property (strong, nonatomic) NSDictionary* movieJson;
@property (weak, nonatomic) IBOutlet UIScrollView *SynopsisScrollView;
@property (weak, nonatomic) IBOutlet UITextView *SynopsisTextView;
@property (weak, nonatomic) IBOutlet UIImageView *DetailsImageView;
@property (nonatomic, assign) CGFloat lastContentOffset;
@property CGRect SynopsisScrollViewFrame;
@property CGFloat currentScrollOffsetX;
@property CGFloat currentScrollOffsetY;
typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;

@end


@implementation MovieDetailsViewController

-(void) setJson:(NSDictionary *)movieJson{
    self.movieJson = movieJson;
    self.title = movieJson[@"title"];
}
-(void) setImage {
   NSURL *url = [NSURL URLWithString:self.movieJson[@"posters"][@"original"]];
    [self.DetailsImageView setImageWithURL:url];
    
}
-(void) setSynopsis {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 20.0f;
    paragraphStyle.maximumLineHeight = 20.0f;
    paragraphStyle.minimumLineHeight = 20.0f;
    NSString *string = self.movieJson[@"synopsis"];
    UIFont *font = [UIFont fontWithName:@"Arial" size:15];
    NSDictionary *attribute = @{
                                NSParagraphStyleAttributeName : paragraphStyle,
                                NSFontAttributeName: font
                                };
    self.SynopsisTextView.attributedText = [[NSAttributedString alloc] initWithString:string attributes:attribute];
    self.SynopsisTextView.textAlignment = NSTextAlignmentLeft;
    self.SynopsisTextView.textColor = [UIColor whiteColor];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.SynopsisScrollView.delegate = self;
    self.SynopsisTextView.delegate = self;
    NSLog(@"%@", self.SynopsisScrollView.delegate);
    [self setImage];
    [self setSynopsis];
//    CGFloat contentWidth = self.SynopsisScrollView.bounds.size.width;
//    CGFloat contentHeight = self.SynopsisScrollView.bounds.size.height * 3;
//    self.SynopsisScrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
    [self.SynopsisScrollView sizeToFit];
    self.SynopsisScrollViewFrame = self.SynopsisScrollView.frame;
    self.SynopsisScrollView.scrollEnabled = NO;
    self.SynopsisTextView.scrollEnabled = NO;
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGestureDown:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [self.SynopsisScrollView addGestureRecognizer:swipeGesture];
    
    UISwipeGestureRecognizer *swipeGesture2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGestureUp:)];
    swipeGesture2.direction = UISwipeGestureRecognizerDirectionUp;
    [self.SynopsisScrollView addGestureRecognizer:swipeGesture2];
}

-(void)handleSwipeGestureDown:(UISwipeGestureRecognizer *) sender
{
    NSLog(@"swipe down event");
    [self animateScrollDown];
}


-(void)handleSwipeGestureUp:(UISwipeGestureRecognizer *) sender
{
     NSLog(@"swipe up event");
    [self animateScrollUp];
}

-(void) animateScrollUp {
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.SynopsisScrollView.contentSize = self.view.bounds.size;
        self.SynopsisScrollView.frame = self.view.bounds;
        [self.SynopsisScrollView setContentOffset:CGPointMake(0,0) animated:YES];
//        CGFloat contentWidth = self.view.bounds.size.width;
//        CGFloat contentHeight = self.view.bounds.size.height * 3;
//        self.SynopsisTextView.contentSize = CGSizeMake(contentWidth, contentHeight);
        [self.SynopsisTextView sizeToFit];
        [self.SynopsisTextView setContentOffset:CGPointMake(0,0) animated:YES];
        self.SynopsisScrollView.bounces = YES;
        self.SynopsisTextView.bounces = YES;
        self.SynopsisTextView.scrollEnabled = YES;
        
    } completion:^(BOOL finished) {
        NSLog(@"done");
    }];
}

-(void) animateScrollDown{
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.SynopsisScrollView.frame = self.SynopsisScrollViewFrame;
        [self.SynopsisScrollView sizeToFit];
        self.SynopsisScrollView.bounces = YES;
        self.SynopsisTextView.bounces = YES;
        self.SynopsisTextView.scrollEnabled = NO;
    } completion:^(BOOL finished) {
        NSLog(@"done2");
    }];
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

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    CGFloat tmpContentOffsetX = scrollView.contentOffset.x;
    CGFloat tmpContentOffsetY = scrollView.contentOffset.y;
    if (tmpContentOffsetY < self.currentScrollOffsetY){
        NSLog(@"scroll down event");
        [self animateScrollDown];
    }
    else{
         NSLog(@"scroll up event");
        [self animateScrollUp];
    }
    self.currentScrollOffsetX = tmpContentOffsetX;
    self.currentScrollOffsetY = tmpContentOffsetY;
}

@end
