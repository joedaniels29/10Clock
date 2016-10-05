#10Clock
![pods](https://img.shields.io/cocoapods/v/10Clock.svg?style=flat)
![MIT](https://img.shields.io/cocoapods/v/10Clock.svg?style=flat)
[![Build Status](https://travis-ci.org/joedaniels29/10Clock.svg?branch=master)](https://travis-ci.org/joedaniels29/10Clock)

Dark and Mysterious🕶             |  Light Colors🌻
:-------------------------:|:-------------------------:
![](/assets/computed/10Clock.png)  |  ![](/assets/computed/green.png)

## Usage

The control itsself is `TenClock`. Add that to your view hierarchy, and constrain it to be square (thats kindof important).

to set times, do:

```swift
self.tenClock.startDate = NSDate()
self.tenClock.endDate = NSDate. //sometime later
```

make the date today.
then, to get updates for when the date changes, adopt the protocol `TenClockDelegate`:

```swift
import TenClock
class ViewController: UIViewController, TenClockDelegate {    
    //Executed for every touch.
    func timesUpdated(_ clock:TenClock, startDate:Date,  endDate:Date  ) -> (){
        //...
    }

    func timesChanged(clock:TenClock, startDate:NSDate,  endDate:NSDate  ) -> (){
        print("start at: \(startDate), end at: \(endDate)")
        self.beginTimeLabel.text = dateFormatter.stringFromDate(startDate)
        self.endTimeLabel.text = dateFormatter.stringFromDate(endDate)
    }
    // ...
```


## Contributing

The goals of the project at this point should be testing for edgecase behavior and expanding customizability.

Please do contribute, open an issue if you have a question. Then  Submit a PR!  :D

## Install via CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1.0+ is required to build 10Clock

To integrate 10Clock into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod '10Clock'
end
```



## License

10Clock is released under the MIT license. See LICENSE for details.
