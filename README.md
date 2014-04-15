Cloud NES - iOS controller
===============

####*This project was made in 36 hours at LA Hacks hackathon. This repository is the iOS controller app only.* 

For the server logic repository, please visit: https://github.com/ErwanLent/CloudNES-Server

Cloud NES is a website that allows you to play many classic NES games with your keyboard, or with our app on any iOS device. We also support multiplayer, so users with our app can sync their app with our web page and start playing together.

###How it works
When a user visits the page, they are given a unique key. They simply enter that unique key into their controller/app, which then syncs up that web page with their phone controller.

###Development
The iOS app communicates with the server via asynchronous TCP, the app uses clever vibrations of varying duration to allow for tactical feedback, so it feels more realistic when you tap the buttons, and you can tell which button you hit without looking. The first view has a text entry where you enter the unique ID the website generates to sync your controller with the current emulator instance.

The webpage uses HTML5 web sockets to communicate with the server. The C# server is using the Alchemy Websockets library for the web socket server, and then a native socket implementation for communicating with the controller.

![ScreenShot](http://i.imgur.com/eUfmyjS.png)
![ScreenShot](http://i.imgur.com/oKczOC2.jpg)
![ScreenShot](http://i.imgur.com/etePpTh.jpg)

###Games You Can Play:
![ScreenShot](http://i.imgur.com/r8IFJoc.png)
