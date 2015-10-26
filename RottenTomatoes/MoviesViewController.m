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

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *LoadingImage;
@property (weak, nonatomic) IBOutlet UILabel *ErrorLabel;
@property (weak, nonatomic) IBOutlet UITableView *MoviesTableView;
@property (strong, nonatomic) NSArray *movies;
@property (strong, nonatomic) NSArray *searchResults;
@property (weak, nonatomic) IBOutlet UISearchBar *SearchBar;
@property Boolean isRefresh;
@property int refreshCount;
- (void)filterContentForSearchText:(NSString*)searchText;
@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.MoviesTableView.dataSource = self;
    self.MoviesTableView.delegate = self;
    self.SearchBar.delegate = self;
    self.MoviesTableView.alpha = 1;
    self.title = @"Movies";
    self.ErrorLabel.hidden = YES;
    self.isRefresh = NO;
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
    if(self.SearchBar.text.length > 0)
        return self.searchResults.count;
    else
        return self.movies.count;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.001f;
}
-(void) setThumbnail:(MoviesTableViewCell*) Moviecell1:(NSInteger) row:(NSArray*) movieList {
//    NSURL *url = [NSURL URLWithString:self.movies[row][@"posters"][@"original"]];
    Moviecell1.Thumbnail.hidden = NO;
    NSString *originalUrlString = movieList[row][@"posters"][@"thumbnail"];
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
    if(self.SearchBar.text.length > 0){
        cell.TitleLabel.text = self.searchResults[indexPath.row][@"title"];
        cell.SynopsisLabel.text = self.searchResults[indexPath.row][@"synopsis"];
        cell.movieJson = self.searchResults[indexPath.row];
        [self setThumbnail:cell:indexPath.row:self.searchResults];
    }
    else{
        cell.TitleLabel.text = self.movies[indexPath.row][@"title"];
        cell.SynopsisLabel.text = self.movies[indexPath.row][@"synopsis"];
        cell.movieJson = self.movies[indexPath.row];
        [self setThumbnail:cell:indexPath.row:self.movies];
    }
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
                                                if(self.isRefresh == YES && self.refreshCount % 2 == 0){
                                                    double delayInSeconds = 2.0;
                                                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                        NSLog(@"After sleep");
                                                        
                                                        self.LoadingImage.hidden = YES;
                                                        [self showPopUp];
                                                    });
                                                    
                                                }
                                                else if (!error) {
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
                                                        self.isRefresh = NO;
                                                        [self.MoviesTableView reloadData];
                                                    });
                                                    
                                                } else {
                                                    self.LoadingImage.hidden = YES;
                                                    [self showPopUp];
                                                    NSLog(@"An error occurred: %@", error.description);
                                                }
                                            }];
    [task resume];
}
- (void) showPopUp{
    self.ErrorLabel.hidden = NO;
    if(self.isRefresh == YES){
        self.MoviesTableView.alpha = 0.3;
        self.ErrorLabel.text = @" There was an error refreshing movies data! Please try again later  ";
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            NSLog(@"After error sleep");
            
            self.MoviesTableView.alpha = 1;
            self.ErrorLabel.hidden = YES;
            self.isRefresh = NO;
        });
    }
    else{
        self.MoviesTableView.hidden = YES;
        self.ErrorLabel.text = @" There was an error fetching movies data! Please try again later  ";
    }
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
    if (self.MoviesTableView.contentOffset.y < 0 && self.LoadingImage.hidden == YES && self.isRefresh == NO)
    {
        NSLog(@"Bounced up");
        self.isRefresh = YES;
        self.LoadingImage.hidden = NO;
        self.MoviesTableView.alpha = 0.5;
        self.refreshCount +=1;
        [self fetchMovies];
    }
}
- (void)filterContentForSearchText:(NSString*)searchText
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"title contains[c] %@", searchText];
    self.searchResults = [self.movies filteredArrayUsingPredicate:resultPredicate];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self handleSearch:searchBar];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self handleSearch:searchBar];
}

- (void)handleSearch:(UISearchBar *)searchBar {
    NSLog(@"User searched for %@", searchBar.text);
    [searchBar resignFirstResponder]; // if you want the keyboard to go away
    [self filterContentForSearchText:searchBar.text];
    [self.MoviesTableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    NSLog(@"User canceled search");
    [searchBar resignFirstResponder]; // if you want the keyboard to go away
    self.searchResults = NULL;
    [self.MoviesTableView reloadData];
}
@end
