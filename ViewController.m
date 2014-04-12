//
//  ViewController.m
//  MegaSegaController
//
//  Created by Joel Green on 4/12/14.
//  Copyright (c) 2014 Joel Green. All rights reserved.
//

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "MFLJoystick.h"
#import "SocketManager.h"
#import "ConstantsHeader.h"

@interface ViewController () <JoystickDelegate>

@property (weak, nonatomic) UIButton *buttonA;
@property (weak, nonatomic) UIButton *buttonB;
@property (strong, nonatomic) NSString *userCode;
@property (strong, nonatomic) SocketManager *socketManager;

@end

@implementation ViewController

int playerNumber = 1;

void AudioServicesPlaySystemSoundWithVibration(SystemSoundID inSystemSoundID,id arg,NSDictionary* vibratePattern);

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.userCode = @"123";
    _socketManager = [[SocketManager alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didConnectToSocket)
                                                 name:@"didConnectToSocket"
                                               object:nil];
}

- (void)didConnectToSocket
{
    //{ “command” : “connect”, “user” : “0123”}
    [self.socketManager sendCommand:@{@"command" : @"connect", @"user" : self.userCode }];

}

// These were used if I have buttons above the A and B
#define heightRatioBig 1
#define heightRatioSmall (1 - heightRatioBig)

- (void)viewDidLayoutSubviews
{
    
    //This is done if viewDidLayoutSubviews so that the views bounds are correctly oriented for landscape
    
    CGRect bounds = self.view.bounds;
    
    //**************************************************
    //******************  Button A   *******************
    UIButton *buttonA = [[UIButton alloc] initWithFrame:CGRectMake(bounds.size.width *.8, bounds.size.height * heightRatioSmall, bounds.size.width * .2, bounds.size.height * heightRatioBig)];
    
    [buttonA addTarget:self action:@selector(buttonAPressed:) forControlEvents:UIControlEventTouchDown];
    [buttonA addTarget:self action:@selector(buttonAReleased:) forControlEvents:UIControlEventTouchUpInside];
    [buttonA addTarget:self action:@selector(buttonAReleased:) forControlEvents:UIControlEventTouchUpOutside];

    buttonA.backgroundColor = [UIColor blueColor];
    [buttonA setTitle:@"A" forState:UIControlStateNormal];
    [self.view addSubview:buttonA];
    self.buttonA = buttonA;
    
    //**************************************************
    //******************  Button B   *******************
    UIButton *buttonb = [[UIButton alloc] initWithFrame:CGRectMake(bounds.size.width *.6, bounds.size.height *heightRatioSmall, bounds.size.width * .2, bounds.size.height *heightRatioBig)];
    
    [buttonb addTarget:self action:@selector(buttonBPressed:) forControlEvents:UIControlEventTouchDown];
    [buttonb addTarget:self action:@selector(buttonBReleased:) forControlEvents:UIControlEventTouchUpInside];
    [buttonb addTarget:self action:@selector(buttonBReleased:) forControlEvents:UIControlEventTouchUpOutside];
    
    buttonb.backgroundColor = [UIColor redColor];
    [buttonb setTitle:@"B" forState:UIControlStateNormal];

    [self.view addSubview:buttonb];
    self.buttonB = buttonb;
    
    //**************************************************
    //******************  Joystick   *******************
    
    float size = 150; //128
    MFLJoystick *joystick = [[MFLJoystick alloc] initWithFrame:CGRectMake(40, 90, size, size)];
    [joystick setThumbImage:[UIImage imageNamed:@"joy_thumb.png"]
                 andBGImage:[UIImage imageNamed:@"stick_base.png"]];
    [joystick setDelegate:self];
    [self.view addSubview:joystick];
    
}

#pragma mark - Button Events

//**************************************************
//******************  Button A   *******************
- (void)buttonAPressed:(UIButton *)button
{
    button.backgroundColor = [UIColor colorWithRed:0 green:0 blue:.8 alpha:1];
//    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    [self vibrateA];
    [self sendCommandDictForKey:[self key:A] type:@"DOWN"];

    NSLog(@"A pressed");
}

- (void)buttonAReleased:(UIButton *)button
{
    button.backgroundColor = [UIColor blueColor];
    NSLog(@"A released");
    [self sendCommandDictForKey:[self key:A] type:@"UP"];


}

//**************************************************
//******************  Button B   *******************
- (void)buttonBPressed:(UIButton *)button
{
    button.backgroundColor = [UIColor colorWithRed:0.8 green:0 blue:0 alpha:1];
//    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    [self vibrateB];
    [self sendCommandDictForKey:[self key:B] type:@"DOWN"];
    
    NSLog(@"B pressed");

}

- (void)buttonBReleased:(UIButton *)button
{
    button.backgroundColor = [UIColor redColor];
    [self sendCommandDictForKey:[self key:B] type:@"UP"];

    NSLog(@"B released");

}


//**************************************************
//******************  Vibrate   ********************

- (void)vibrateA
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    NSMutableArray* arr = [NSMutableArray array ];
    
    [arr addObject:[NSNumber numberWithBool:YES]]; //vibrate for 2000ms
    [arr addObject:[NSNumber numberWithInt:40]];
    
    [dict setObject:arr forKey:@"VibePattern"];
    [dict setObject:[NSNumber numberWithInt:1] forKey:@"Intensity"];
    
    AudioServicesPlaySystemSoundWithVibration(4095,nil,dict);
}

- (void)vibrateB
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    NSMutableArray* arr = [NSMutableArray array ];
    
    [arr addObject:[NSNumber numberWithBool:YES]]; //vibrate
    [arr addObject:[NSNumber numberWithInt:25]];
    
    [dict setObject:arr forKey:@"VibePattern"];
    [dict setObject:[NSNumber numberWithInt:1] forKey:@"Intensity"];
    
    AudioServicesPlaySystemSoundWithVibration(4095,nil,dict);
}

//DONT THINK ILL BE USING THIS FUNCTION FUCK HACKATHONS
- (UIColor *)randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    return color;
}


#pragma mark - joystick direction handler

int prevDirection = 0; //0: mid, 1: up, 2: right, 3: down, 4: left --more shit in constant header
// fucktion that pleasures your moms joystick
- (void)joystick:(MFLJoystick *)aJoystick didUpdate:(CGPoint)dir
{
//    NSLog(@"%@", NSStringFromCGPoint(dir));
    
    float x = dir.x;
    float y = dir.y;
    if (x == 0 && y == 0) {
        // Mid
        if (prevDirection != MID) {
            if (prevDirection != MID) [self sendCommandDictForKey:[self key:prevDirection] type:@"UP"];
            NSLog(@"mid");
//            [self sendCommandDictForKey:[self key:MID] type:@"DOWN"];
            prevDirection = MID;
        }
    } else if (x > 1 && y > 0) {
        //right so 2
        if (prevDirection != RIGHT) { //idk why its right fuck it the vector makes no sense
            if (prevDirection != MID) [self sendCommandDictForKey:[self key:prevDirection] type:@"UP"];
            NSLog(@"right");
            [self sendCommandDictForKey:[self key:RIGHT] type:@"DOWN"];
            prevDirection = RIGHT;
        }
    } else if (x < 1 && x > 0 && y > 0) {
        //down so 3
        if (prevDirection != DOWN) {
            if (prevDirection != MID) [self sendCommandDictForKey:[self key:prevDirection] type:@"UP"];
            NSLog(@"down");
            [self sendCommandDictForKey:[self key:DOWN] type:@"DOWN"];
            prevDirection = DOWN;
        }
    } else if (x >= 0 && y <= 0) {
        //up so 1
        if (prevDirection != UP) {
            if (prevDirection != MID) [self sendCommandDictForKey:[self key:prevDirection] type:@"UP"];
            NSLog(@"up");
            [self sendCommandDictForKey:[self key:UP] type:@"DOWN"];
            prevDirection = UP;
        }
    } else if (x < 0 && y < 0) {
        //left so 4
        if (prevDirection != LEFT) {
            if (prevDirection != MID) [self sendCommandDictForKey:[self key:prevDirection] type:@"UP"];
            NSLog(@"left");
            [self sendCommandDictForKey:[self key:LEFT] type:@"DOWN"];
            prevDirection = LEFT;
        }
    } else if (x <= 0 && y >= 0 ) {
        //left so 4
        // yes left is repeated because fuck people and suck mikes balls
        if (prevDirection != LEFT) {
            if (prevDirection != MID) [self sendCommandDictForKey:[self key:prevDirection] type:@"UP"];
            NSLog(@"left");
            [self sendCommandDictForKey:[self key:LEFT] type:@"DOWN"];
            prevDirection = LEFT;
        }
    }

}

/* **** These are the numbers the game expects ****
 
 88 KEY_A      // X
 89 KEY_B      // Y (Central European keyboard)
 90 KEY_B      // Z
 17 KEY_SELECT // Right Ctrl
 13 KEY_START  // Enter
 38 KEY_UP     // Up
 40 KEY_DOWN   // Down
 37 KEY_LEFT   // Left
 39 KEY_RIGHT  // Right
 
 103 KEY_A     // Num-7
 105 KEY_B     // Num-9
 99 KEY_SELECT // Num-3
 97 KEY_START  // Num-1
 104 KEY_UP    // Num-8
 98 KEY_DOWN   // Num-2
 100 KEY_LEFT  // Num-4
 102 KEY_RIGHT // Num-6

 */

- (NSString *)key:(int)keyNumber
{
    NSString *key = nil;
    
    switch (keyNumber) {
        case UP:
            if (playerNumber == 1) {
                return @"38";
            } else {
                return @"104";
            }
            break;
        case RIGHT:
            if (playerNumber == 1) {
                return @"39";
            } else {
                return @"102";
            }
            break;
        case DOWN:
            if (playerNumber == 1) {
                return @"40";
            } else {
                return @"98";
            }
            break;
            
        case LEFT:
            if (playerNumber == 1) {
                return @"37";
            } else {
                return @"100";
            }
            break;
            
        case A:
            if (playerNumber == 1) {
                return @"88";
            } else {
                return @"103";
            }
            break;
            
        case B:
            if (playerNumber == 1) {
                return @"89";
            } else {
                return @"105";
            }
            break;
            
        default:
            break;
    }
    
    return key;
}

- (void)sendCommandDictForKey:(NSString *)key type:(NSString *)type
{
    //json format { “command” : “key”, “type” : “up”, “user” : “0123”, “keyCode” : “88”}
    NSLog(@"%@, %@",key, type);
    NSDictionary *commandDict = @{@"command" : @"key", @"type" : type, @"user" : self.userCode, @"keyCode" : key};
    [self.socketManager sendCommand:commandDict];
}

@end
