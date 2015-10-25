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
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGestureDown:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [self.SynopsisScrollView addGestureRecognizer:swipeGesture];
    
    UISwipeGestureRecognizer *swipeGesture2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGestureUp:)];
    swipeGesture2.direction = UISwipeGestureRecognizerDirectionUp;
    [self.SynopsisScrollView addGestureRecognizer:swipeGesture2];
}

-(void)handleSwipeGestureDown:(UISwipeGestureRecognizer *) sender
{
    self.SynopsisScrollView.frame = self.SynopsisScrollViewFrame;
    [self.SynopsisScrollView sizeToFit];
}


-(void)handleSwipeGestureUp:(UISwipeGestureRecognizer *) sender
{
    self.SynopsisScrollView.contentSize = self.view.bounds.size;
    self.SynopsisScrollView.frame = self.view.bounds;
    [self.SynopsisScrollView setContentOffset:CGPointMake(0,0) animated:YES];
    [self.SynopsisTextView sizeToFit];
    [self.SynopsisTextView setContentOffset:CGPointMake(0,0) animated:YES];
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
    if (tmpContentOffsetY > self.currentScrollOffsetY){
        self.SynopsisScrollView.contentSize = self.view.bounds.size;
        self.SynopsisScrollView.frame = self.view.bounds;
        [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
        [self.SynopsisTextView sizeToFit];
        [self.SynopsisTextView setContentOffset:CGPointMake(0,0) animated:YES];
//        CGFloat fixedWidth = self.SynopsisTextView.frame.size.width;
//        CGSize newSize = [self.SynopsisTextView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
//        CGRect newFrame = self.SynopsisTextView.frame;
//        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
//        self.SynopsisTextView.frame = newFrame;
//        self.SynopsisTextView.contentSize =CGSizeMake(contentWidth, contentHeight);
    }
    else{
        self.SynopsisScrollView.frame = self.SynopsisScrollViewFrame;
        [self.SynopsisScrollView sizeToFit];
    }
    self.currentScrollOffsetX = tmpContentOffsetX;
    self.currentScrollOffsetY = tmpContentOffsetY;
}

@end
