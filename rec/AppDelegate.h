#import <Foundation/Foundation.h>
#import <QTKit/QTKit.h>

@interface AppDelegate : NSObject
{
	QTCaptureSession			*_session;
	QTCaptureMovieFileOutput	*_output;
}

- (void)addInputWithDeviceIndex:(int)index;
- (NSArray *)devices;
- (void)printDevicesWithIndex;
- (void)setOutput:(NSString *)path;
- (void)useDefaults;

- (void)start;
- (void)stop;

@end

