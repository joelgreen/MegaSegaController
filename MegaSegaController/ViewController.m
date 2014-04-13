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

// Don't think this function is app store legal but it is required to vibrate for a custom duration
// Declared here to prevent warning
void AudioServicesPlaySystemSoundWithVibration(SystemSoundID inSystemSoundID,id arg,NSDictionary* vibratePattern);


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.userCode = @"123";
    _socketManager = [[SocketManager alloc] init];
    
    // Listens to know if it should send reconnect info to server
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didConnectToSocket)
                                                 name:@"didConnectToSocket"
                                               object:nil];
    
    // Listens to find out if user has been changed to player 1
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setToPlayer1)
                                                 name:@"SetToPlayer1"
                                               object:nil];
    
    // Listens to find out if user has been changed to player 2
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setToPlayer2)
                                                 name:@"SetToPlayer2"
                                               object:nil];
}

- (void)didConnectToSocket
{
    // This tells the server what user I am and that I am connecting
    // On disconnect the socket manager will attempt to reconnect
    // This method is called on every successful connect to the TCP server
    
    // Json format: { “command” : “connect”, “user” : “0123”}
    [self.socketManager sendCommand:@{@"command" : @"connect", @"user" : self.userCode }];
}


- (void)setToPlayer1
{
    NSLog(@"Player set to player 1");
    playerNumber = 1;
}

- (void)setToPlayer2
{
    NSLog(@"Player set to player 2");
    playerNumber = 2;
}

// These are used if I have buttons above the A and B
#define heightRatioBig .75
#define heightRatioSmall (1 - heightRatioBig)

- (void)viewDidLayoutSubviews
{
    //This is done in viewDidLayoutSubviews so that the views bounds are correctly oriented for landscape
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
    UIButton *buttonB = [[UIButton alloc] initWithFrame:CGRectMake(bounds.size.width *.6, bounds.size.height *heightRatioSmall, bounds.size.width * .2, bounds.size.height *heightRatioBig)];
    
    [buttonB addTarget:self action:@selector(buttonBPressed:) forControlEvents:UIControlEventTouchDown];
    [buttonB addTarget:self action:@selector(buttonBReleased:) forControlEvents:UIControlEventTouchUpInside];
    [buttonB addTarget:self action:@selector(buttonBReleased:) forControlEvents:UIControlEventTouchUpOutside];
    
    buttonB.backgroundColor = [UIColor redColor];
    [buttonB setTitle:@"B" forState:UIControlStateNormal];

    [self.view addSubview:buttonB];
    self.buttonB = buttonB;
    
    //**************************************************
    //****************  Start Button   *****************
    
    UIButton *startButton = [[UIButton alloc] initWithFrame:CGRectMake(bounds.size.width *.8, 0, bounds.size.width * .2, bounds.size.height *heightRatioSmall)];
    
    [startButton addTarget:self action:@selector(startButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [startButton addTarget:self action:@selector(startButtonReleased:) forControlEvents:UIControlEventTouchUpInside];
    [startButton addTarget:self action:@selector(startButtonReleased:) forControlEvents:UIControlEventTouchUpOutside];
    
    startButton.backgroundColor = [UIColor yellowColor];
    [startButton setTitle:@"Start" forState:UIControlStateNormal];
    
    [self.view addSubview:startButton];
    
    //**************************************************
    //******************  Joystick   *******************
    
    float size = 150; //or 190 for larger
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
//****************  Start Button   *****************

- (void)startButtonPressed:(UIButton *)button
{
    button.backgroundColor = UIColorFromRGB(0xDDDD00);
    //    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    [self vibrateStart];
    [self sendCommandDictForKey:[self key:START] type:@"DOWN"];
    
    NSLog(@"Start pressed");
    
}

- (void)startButtonReleased:(UIButton *)button
{
    button.backgroundColor = [UIColor yellowColor];
    [self sendCommandDictForKey:[self key:START] type:@"UP"];

    NSLog(@"Start released");
    
}

//**************************************************
//******************  Vibrate   ********************

// Vibrate when pressing buttons are different durations to allow tatical feedback
// User can differentiate between presses without looking at controller
- (void)vibrateA
{
    [self vibrateWithDuration:40];
}
- (void)vibrateB
{
    [self vibrateWithDuration:25];
}
- (void)vibrateStart
{
    [self vibrateWithDuration:100];
}

- (void)vibrateWithDuration:(int)duration //number of ms to vibrate for
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    NSMutableArray* arr = [NSMutableArray array ];
    
    [arr addObject:[NSNumber numberWithBool:YES]]; //vibrate for duration in ms
    [arr addObject:[NSNumber numberWithInt:duration]];
    // To add period of no vibration use same format with bool set to NO
    // These chan be chained to have custom patterns
    
    [dict setObject:arr forKey:@"VibePattern"];
    [dict setObject:[NSNumber numberWithInt:1] forKey:@"Intensity"];
    
    AudioServicesPlaySystemSoundWithVibration(4095,nil,dict);
}

// ************************************************************************

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

int prevDirection = 0; //0: mid, 1: up, 2: right, 3: down, 4: left --shit defined in constant header
// fucktion that pleasures your moms joystick
- (void)joystick:(MFLJoystick *)aJoystick didUpdate:(CGPoint)dir
{
    // OK so this figures out the direction of the joystick
    // (the dir vector makes no sense so its messy)
    // If it changes direction it sends a keyup for the previous direction
    // and then sends a key down for the new direction
    
//    NSLog(@"%f, %f",dir.x,dir.y); // Lets me know the direction vector for debugging
    float x = dir.x;
    float y = dir.y;
    if (x == 0 && y == 0) {
        // Mid
        if (prevDirection != MID) {
            if (prevDirection != MID) [self sendCommandDictForKey:[self key:prevDirection] type:@"UP"];
            NSLog(@"mid");
            prevDirection = MID;
            // Dendi Pudge mid GG pro hooks
        }
    } else if (x > 1 && y > 0) { // "x > 1 && y > 0" or "x > 2.2 && y > 0.2" for larger
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
 
 --PLAYER 1--
 88 KEY_A      // X
 89 KEY_B      // Y (Central European keyboard)
 90 KEY_B      // Z
 17 KEY_SELECT // Right Ctrl
 13 KEY_START  // Enter
 38 KEY_UP     // Up
 40 KEY_DOWN   // Down
 37 KEY_LEFT   // Left
 39 KEY_RIGHT  // Right
 
 --PLAYER 2--
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
    // Returns the approiate number the server expects for a corrisponding key press
    // Will send a different key if player 1 or player 2
    // Mostly self explanatory
    
    NSString *key = @"";
    
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
            
        case START:
            if (playerNumber == 1) {
                return @"13";
            } else {
                return @"97";
            }
            break;
            
        default:
            break;
    }
    
    return key;
}

// You mom is so fat that NASA probed her for extraterrestrial life
- (void)sendCommandDictForKey:(NSString *)key type:(NSString *)type
{
    //json format { “command” : “key”, “type” : “up”, “user” : “0123”, “keyCode” : “88”}
    NSLog(@"%@, %@",key, type);
    NSDictionary *commandDict = @{@"command" : @"key", @"type" : type, @"user" : self.userCode, @"keyCode" : key};
    [self.socketManager sendCommand:commandDict];
}

@end
