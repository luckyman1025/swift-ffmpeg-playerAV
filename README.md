# swift-ffmpeg

## What ?

A basic audio player project that demonstrates the fundamentals of decoding audio with ffmpeg for the purpose of real-time playback. The code is in Swift 
and the demo project will run on macOS, but could prove educational even to programmers of different languages/platforms.

### What else ?

You will find a bare bones AVAudioEngine setup here. < 100 lines of code with just a player that schedules buffers.

### In a nutshell, ... this
![High level component diagram](/basicFFmpegPlayer.png?raw=true)

## Who ?

Are you totally new to ffmpeg ? You just read/heard that there is this awesome library that plays everything and now you want to get started programming with it ? Great, you will like this.

Are you totally new to AVAudioEngine and you want to see a basic usage of it ? Great, you will find it here.

Are you totally new to audio programming in general ? Or want to write your own player someday ? Welcome.

## Why ?

It seems that there aren't too many similar beginner-level demo projects or tutorials out there. I know that I myself searched and researched for almost 3 whole years to finally learn enough to write this basic player demo app. The few that I found were much too overwhelming or contained a lot of concepts without a concrete implementation to play with.

I learn the most when I'm able to actually open and run a project in XCode or Visual Studio or Eclipse, rather than just reading concepts. I would have killed to have access to such a demo project 3 years ago when my audio programming journey began.

That said, I have shared links, below, to much bigger, more comprehensive, and more detailed demos/projects/tutorials out there, which I myself learned from.

## How ?

Download it and get it running in XCode. Open different types of music files, and see if/how it works.

Browse through the source code, which I have done my best to document. Tweak it to your heart's content, build it, run it, see (and hear) what happens!

Then, perhaps ... build something much bigger and better yourself!

## Please note ...

This minimalist project is intended only as a quick start guide for beginners wanting to get their hands dirty programming with ffmpeg. I am not trying to educate those of you who have been taming ffmpeg for years.

This is NOT a comprehensive ffmpeg reference.
This is NOT a full-fledged audio player application.

## Other helpful resources

Hopefully, this project will get you started, and once you get your feet wet, you will find these resources valuable.

* targodan's [ffmpeg decoding guide](https://steemit.com/programming/@targodan/decoding-audio-files-with-ffmpeg). Related code sample [here](https://gist.github.com/targodan/8cef8f2b682a30055aa7937060cd94b7).

* [A detailed tutorial on the basics of ffmpeg](https://github.com/leandromoreira/ffmpeg-libav-tutorial) by leandromoreira.

* An [outdated but pretty detailed ffmpeg tutorial](https://dranger.com/ffmpeg/tutorial01.html) that others have recommended.

* rollmind's Swift/ffmpeg [demo app](https://github.com/rollmind/ffmpeg-swift-tutorial/tree/master/tutorial/tutorialhttps://github.com/rollmind/ffmpeg-swift-tutorial/tree/master/tutorial/tutorial) (somewhat outdated, but still helpful)

* Another [Swift player implementation](https://github.com/rollmind/SweetPlayer) by rollmind

* Sunlubo's [Swift wrapper for ffmpeg](https://github.com/sunlubo/SwiftFFmpeg)

* For a more full-fledged AVAudioEngine setup, I point you to my other (far bigger) project: [Aural Player](https://github.com/maculateConception/aural-player)

* A Swift ffmpeg [wrapper library](https://github.com/FFMS/ffms2) (that I'm not sure I understand but it should be mentioned).
