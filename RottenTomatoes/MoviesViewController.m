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

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *MoviesTableView;
@property (strong, nonatomic) NSArray *movies;
@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.MoviesTableView.dataSource = self;
    self.MoviesTableView.delegate = self;
    self.title = @"Movies";
    [self fetchMovies];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MoviesTableViewCell *cell = [self.MoviesTableView dequeueReusableCellWithIdentifier:@"movieCell"];
    cell.TitleLabel.text = self.movies[indexPath.row][@"title"];
    cell.SynopsisLabel.text = self.movies[indexPath.row][@"synopsis"];
    cell.movieJson = self.movies[indexPath.row];
    NSURL *url = [NSURL URLWithString:self.movies[indexPath.row][@"posters"][@"thumbnail"]];
    [cell.Thumbnail setImageWithURL: url];
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
                                                    [self.MoviesTableView reloadData];
                                                } else {
                                                    NSLog(@"An error occurred: %@", error.description);
                                                }
                                            }];
    [task resume];
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.MoviesTableView deselectRowAtIndexPath:indexPath animated:YES];
    MoviesTableViewCell *selectedCell=[tableView cellForRowAtIndexPath:indexPath];
    MovieDetailsViewController *vc = [[MovieDetailsViewController alloc] init];
    vc.edgesForExtendedLayout = UIRectEdgeNone;
    [vc setJson:selectedCell.movieJson];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
