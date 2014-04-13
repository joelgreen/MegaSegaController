//
//  StartScreenViewController.m
//  MegaSegaController
//
//  Created by Joel Green on 4/13/14.
//  Copyright (c) 2014 Joel Green. All rights reserved.
//

#import "StartScreenViewController.h"
#import "ViewController.h"
#import "iCarousel.h"


@interface StartScreenViewController () <iCarouselDataSource, iCarouselDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textEntry;

@property (nonatomic, assign) BOOL wrap;
@property (nonatomic, strong) NSMutableArray *items;

@property (weak, nonatomic) IBOutlet iCarousel *carousel;

@end

@implementation StartScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //set up data
    }
    return self;
}

- (NSMutableArray *)items
{
    if (!_items) {
        _items = [[NSMutableArray alloc] init];
    }
    return _items;
}

- (void)awakeFromNib
{
    //set up data
    //your carousel should always be driven by an array of
    //data of some kind - don't store data in your item views
    //or the recycling mechanism will destroy your data once
    //your item views move off-screen
    [self.items addObject:[UIImage imageNamed:@"super mario bros 3.png"]];
    [self.items addObject:[UIImage imageNamed:@"dk.png"]];
    [self.items addObject:[UIImage imageNamed:@"drmario.png"]];
    [self.items addObject:[UIImage imageNamed:@"golf.png"]];
    [self.items addObject:[UIImage imageNamed:@"mario bros.png"]];
    [self.items addObject:[UIImage imageNamed:@"megaman.png"]];
    [self.items addObject:[UIImage imageNamed:@"pacman.png"]];
    [self.items addObject:[UIImage imageNamed:@"super mario bros.png"]];
    [self.items addObject:[UIImage imageNamed:@"tetris.png"]];
    [self.items addObject:[UIImage imageNamed:@"zelda.png"]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //configure carousel
    self.carousel.type = iCarouselTypeCoverFlow2;
    self.carousel.backgroundColor =[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"pattern"]];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"pattern"]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ViewController *viewController = [segue destinationViewController];
    viewController.userCode = self.textEntry.text;
}

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //return the total number of items in the carousel
    return [self.items count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
//    UILabel *label = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 223*.6, 320*.6)];
        ((UIImageView *)view).image = (UIImage *)self.items[index];
    }
    
    return view;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
    //Imbrace insanity. UI design.
}

@end
