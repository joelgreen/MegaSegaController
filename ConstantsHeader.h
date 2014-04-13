//
//  ConstantsHeader.h
//  SuperChat
//
//  Created by Joel Green on 1/21/14.
//  Copyright (c) 2014 Joel Green. All rights reserved.
//

#ifndef SuperChat_ConstantsHeader_h
#define SuperChat_ConstantsHeader_h

//**************************************************
//******************   Colors   ********************

#define RED_THEME_COLOR [UIColor colorWithRed:255/255 green:61.0/255 blue:51.f/255 alpha:1.f]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


//**************************************************
//*******************    API   *********************
#define VERSION @"/V1/"
#define URL @"http://api.getshoutoutapp.com"

#define ADMIN_PASSWORD @"2af20165a8ee7a2aa1e2ffc902c25b62cacbf1af"



#define TERMINATOR @"e958248b"

//**************************************************
//**************************************************

//0: mid, 1: up, 2: right, 3: down, 4: left
#define MID 0
#define UP 1
#define RIGHT 2
#define DOWN 3
#define LEFT 4
#define A 5
#define B 6
#define X 7
#define Y 8
#define START 9



#endif
