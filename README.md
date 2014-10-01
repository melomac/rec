
## [rec]

AV input recorder for legacy platforms.

* OS X 10.5 to 10.9
* PPC / i386 / x86_64
* QTKit, ObjC
* Build with Xcode 3.2.5

*QTKit framework is deprecated in OS X 10.9*

### Usage

    Usage: rec [-a] [-i index] [-o file]
           rec -l

### Options

    -h  show usage
    
    -l  list devices: index, name, and default status (*)
    
    -a  auto:   -i default audio input
                -o /tmp/yyyyMMdd-HHmmss.mov
    
    -i  add device with index
    -o  set output file

### Examples

    ./rec -l
    ./rec -i 0 -i 5 -o /tmp/rec.mov
    ./rec -a


## [rec]<sup>2</sup>

AV input recorder for current platforms.

* iOS 4.0 and later
* armv6 / armv7
* AVFoundation, ObjC 2.0, ARC, GCD
* Build with Xcode 4.4.1 and iOSOpenDev 1.6-2

### Usage

    Usage: rec2 [-a] [-i index] [-o file] [-p index]
           rec2 -l

### Options

    -h  show usage
    
    -l  list devices: index, name, and default status (*)
        list presets: index, name
    
    -a  auto:   -i default audio input
                -o /tmp/yyyyMMdd-HHmmss.mov
                -p 0 (high)
    
    -i  add device with index
    -o  set output file
    -p  set preset with index

### Examples

    ./rec2 -l
    ./rec2 -i 0 -i 5 -o /tmp/rec2.mov -p 0
    ./rec2 -a

