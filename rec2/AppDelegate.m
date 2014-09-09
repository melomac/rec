#import <AVFoundation/AVFoundation.h>
#import <ApplicationServices/ApplicationServices.h>

#import "AppDelegate.h"

#define MAX_DISPLAYS 32


@interface AppDelegate () <AVCaptureFileOutputRecordingDelegate>
{
	AVCaptureSession	*_session;
}

@end


#pragma mark -

@implementation AppDelegate

- (id)init
{
	self = [super init];
	
	if (self)
	{
		_session = [[AVCaptureSession alloc] init];
	}
	
	return self;
}


#pragma mark -

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
	// Get finish handler
	void (^finishHandler)(BOOL success, NSError *error) = _finishHandler;
	
	if (!finishHandler)
		finishHandler = ^(BOOL success, NSError *error) { };
	
	// No error
	if (!error)
	{
		finishHandler(YES, nil);
		
		return;
	}
	
	// Error: check success
	BOOL success = [[[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey] boolValue];
	
	if (success)
	{
		finishHandler(YES, nil);
		
		return;
	}
	
	finishHandler(NO, error);
}


#pragma mark -

- (BOOL)addInputWithDeviceIndex:(NSUInteger)index
{
	if (index >= [self.devices count])
		return NO;
	
	[_session addInput:[AVCaptureDeviceInput deviceInputWithDevice:[self.devices objectAtIndex:index] error:nil]];
	
	return YES;
}

- (BOOL)addInputWithDisplayIndex:(NSUInteger)index
{
	// Get displays
	CGDirectDisplayID displays[MAX_DISPLAYS];
	uint32_t numDisplays;
	
	CGGetActiveDisplayList(MAX_DISPLAYS, displays, &numDisplays);
	
	if (index >= (NSUInteger)numDisplays)
		return NO;
	
	AVCaptureScreenInput *input = [[AVCaptureScreenInput alloc] initWithDisplayID:displays[index]];
	
	if (!input)
		return NO;
	
	[_session addInput:input];
	
	return YES;
}

- (NSArray *)devices
{
	NSMutableArray *result = [[NSMutableArray alloc] init];
	
	[result addObjectsFromArray:[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio]];
	[result addObjectsFromArray:[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]];
	[result addObjectsFromArray:[AVCaptureDevice devicesWithMediaType:AVMediaTypeMuxed]];
	
	return result;
}

- (void)enumerateDevicesUsingBlock:(void (^)(NSString *device, BOOL isDefault, NSUInteger index))block
{
	if (!block)
		return;
	
	NSMutableArray	*defaults = [[NSMutableArray alloc] init];
	AVCaptureDevice	*device;
	
	// Default audio
	device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
	
	if (device)
		[defaults addObject:device];
	
	// Default video
	device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	
	if (device)
		[defaults addObject:device];
	
	// Enumerate
	NSUInteger index = 0;
	
	for (AVCaptureDevice *device in self.devices)
	{
		block([device localizedName], [defaults containsObject:device], index);
		
		index++;
	}
}

- (void)enumerateDisplaysUsingBlock:(void (^)(NSString *display, BOOL isDefault, NSUInteger index))block
{
	if (!block)
		return;
	
	// Get displays
	CGDirectDisplayID displays[MAX_DISPLAYS];
	uint32_t numDisplays;
	
	CGGetActiveDisplayList(MAX_DISPLAYS, displays, &numDisplays);
	
	// Enumerate
	NSUInteger index = 0;
	
	for(index = 0; index < (NSUInteger)numDisplays; index++)
	{
		long w = 0, h = 0;
		w = CGDisplayPixelsWide(displays[index]);
		h = CGDisplayPixelsHigh(displays[index]);
		
		NSString *res = [NSString stringWithFormat:@"%ld x %ld", w, h];
		
		block(res, displays[index] == kCGDirectMainDisplay, index);
	}
}

- (void)enumeratePresetsUsingBlock:(void (^)(NSString *preset, NSUInteger index))block
{
	if (!block)
		return;
	
	NSUInteger index = 0;
	
	for (NSString *preset in self.presets)
	{
		block(preset, index);
		
		index++;
	}
}

- (NSArray *)presets
{
	NSArray *result = [NSArray arrayWithObjects:AVCaptureSessionPresetHigh, AVCaptureSessionPresetMedium, AVCaptureSessionPresetLow, nil];
	
	return result;
}

- (void)setPreset:(int)index
{
	if (index >= [self.presets count])
		return;
	
	_session.sessionPreset = [self.presets objectAtIndex:index];
}

- (void)useDefaults
{
	// Set default device
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
	
	[_session addInput:[AVCaptureDeviceInput deviceInputWithDevice:device error:nil]];
	
	// Set file path
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	
	[dateFormat setDateFormat:@"yyyyMMdd-HHmmss"];
	
	_outfile = [NSString stringWithFormat:@"/tmp/%@.mov", [dateFormat stringFromDate:[NSDate date]]];
}


#pragma mark -

- (void)start
{
	// Check status
	if ([_session.inputs count] == 0 || _outfile == nil)
	{
		if (_finishHandler)
			_finishHandler(NO, [NSError errorWithDomain:@"Missing I/O" code:1 userInfo:nil]);
		
		return;
	}
	
	// Start a record
	AVCaptureFileOutput *output = [[AVCaptureMovieFileOutput alloc] init];
	
	[_session addOutput:output];
	[_session startRunning];
	
	[output startRecordingToOutputFileURL:[NSURL fileURLWithPath:_outfile] recordingDelegate:self];
}

- (void)stop
{
	[_session stopRunning];
}

@end
