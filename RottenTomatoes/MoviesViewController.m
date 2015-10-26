//
//  ViewController.m
//  RottenTomatoes
//
//  Created by Nizha Shree Seenivasan on 10/20/15.
//  Copyright © 2015 Nizha Shree Seenivasan. All rights reserved.
//

#import "MoviesViewController.h"
#import "MoviesTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "MovieDetailsViewController.h"
#import "iToast.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *LoadingImage;
@property (weak, nonatomic) IBOutlet UILabel *ErrorLabel;
@property (weak, nonatomic) IBOutlet UITableView *MoviesTableView;
@property (strong, nonatomic) NSArray *movies;
@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.MoviesTableView.dataSource = self;
    self.MoviesTableView.delegate = self;
    self.MoviesTableView.alpha = 1;
    self.title = @"Movies";
    self.ErrorLabel.hidden = YES;
    if(self.movies == NULL){
        [self.LoadingImage setCenter:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)];
        self.LoadingImage.hidden = NO;
        self.MoviesTableView.hidden = YES;
    }
    else{
        self.LoadingImage.hidden = YES;
        self.MoviesTableView.hidden = NO;
    }
    [self fetchMovies];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

-(void) setThumbnail:(MoviesTableViewCell*) Moviecell1:(NSInteger) row {
//    NSURL *url = [NSURL URLWithString:self.movies[row][@"posters"][@"original"]];
    Moviecell1.Thumbnail.hidden = NO;
    NSString *originalUrlString = self.movies[row][@"posters"][@"thumbnail"];
    NSURLRequest *lowResolutionUrl = [NSURLRequest requestWithURL:[NSURL URLWithString: originalUrlString]];
    NSRange range = [originalUrlString rangeOfString:@".*cloudfront.net/"
                                             options:NSRegularExpressionSearch];
    
    NSString *newUrlString = [originalUrlString stringByReplacingCharactersInRange:range
                                                                        withString:@"https://content6.flixster.com/"];
    Moviecell1.Thumbnail.contentMode = UIViewContentModeScaleToFill;
    NSURLRequest *highResolutionUrl = [NSURLRequest requestWithURL:[NSURL URLWithString: newUrlString]
                                                       cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                   timeoutInterval:60];
    [Moviecell1.Thumbnail setImageWithURLRequest: lowResolutionUrl
            placeholderImage:nil
            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                Moviecell1.LoadingLabel.hidden = YES;
                Moviecell1.Thumbnail.image = image;
                [Moviecell1.Thumbnail setImageWithURLRequest:highResolutionUrl
                                            placeholderImage:nil
                                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                         Moviecell1.LoadingLabel.hidden = YES;
                                                         if(response != NULL){
                                                             [UIView transitionWithView:Moviecell1
                                                                               duration:1
                                                                                options:UIViewAnimationOptionTransitionCrossDissolve
                                                                             animations:^{
                                                                                 Moviecell1.Thumbnail.image = image;
                                                                             }
                                                                             completion:NULL];
                                                         }else{
                                                             Moviecell1.Thumbnail.image = image;
                                                         }
                                                     }
                                                     failure:NULL];
                }
            failure:NULL];

    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MoviesTableViewCell *cell = [self.MoviesTableView dequeueReusableCellWithIdentifier:@"movieCell"];
    cell.Thumbnail.image = NULL;
    cell.Thumbnail.hidden = YES;
    cell.LoadingLabel.hidden = NO;
    cell.TitleLabel.text = self.movies[indexPath.row][@"title"];
    cell.SynopsisLabel.text = self.movies[indexPath.row][@"synopsis"];
    cell.movieJson = self.movies[indexPath.row];
    [self setThumbnail:cell:indexPath.row];
    return cell;
}

-(void) fetchMovies{
    NSString *urlString =
    @"https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json";
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                  delegate:nil
                             delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                                                if (!error) {
                                                    NSError *jsonError = nil;
                                                    NSDictionary *responseDictionary =
                                                    [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:kNilOptions
                                                                                      error:&jsonError];
                                                    self.movies = responseDictionary[@"movies"];
                                                    double delayInSeconds = 2.0;
                                                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                        NSLog(@"After sleep");
                                                        
                                                        self.MoviesTableView.alpha = 1;
                                                        self.LoadingImage.hidden = YES;
                                                        self.MoviesTableView.hidden = NO;
//                                                        [self showPopUp];
                                                        [self.MoviesTableView reloadData];
                                                    });
                                                    
                                                } else {
                                                    [self showPopUp];
                                                    NSLog(@"An error occurred: %@", error.description);
                                                }
                                            }];
    [task resume];
}
- (void) showPopUp{
    self.ErrorLabel.hidden = NO;
    self.MoviesTableView.hidden = YES;
    self.ErrorLabel.text = @" There was an error fetching movies data! Please try again later  ";
//    [[[[iToast makeText:NSLocalizedString(@"There was error in fetching data. please try again", @"")]
//     setGravity:iToastGravityCenter ]setPostion:CGPointMake(0,0) ] show];
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.MoviesTableView deselectRowAtIndexPath:indexPath animated:YES];
    MoviesTableViewCell *selectedCell=[tableView cellForRowAtIndexPath:indexPath];
    MovieDetailsViewController *vc = [[MovieDetailsViewController alloc] init];
    vc.edgesForExtendedLayout = UIRectEdgeNone;
    [vc setJson:selectedCell.movieJson];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.MoviesTableView.contentOffset.y < 0 && self.LoadingImage.hidden == YES)
    {
        NSLog(@"Bounced up");
        self.LoadingImage.hidden = NO;
        self.MoviesTableView.alpha = 0.5;
        [self fetchMovies];
    }
}
@end
