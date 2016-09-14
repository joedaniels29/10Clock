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
then, to get updates for when the date changes, adopt the protocol `TenClockDelegate` and observe:

```swift
import TenClock
class ViewController: UIViewController, TenClockDelegate {
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




## License

10Clock is released under the MIT license. See LICENSE for details.
