//
//  CGHFaceBookViewController.m
//  CompuGhana
//
//  Created by Sreelal H on 11/02/15.
//  Copyright (c) 2015 Sreelal H. All rights reserved.
//

#import "CGHFaceBookViewController.h"
#import "SocialFrameworkHandler.h"

@interface CGHFaceBookViewController ()

@end

@implementation CGHFaceBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.webContent loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.facebook.com/pages/CompuGhana/136288153081650?ref=br_tf"]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [self.activityView stopAnimating];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    [self.activityView stopAnimating];

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
