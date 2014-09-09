#import "AppDelegate.h"

@implementation AppDelegate


#pragma mark -

- (id)init
{
	self = [super init];
	
	if (self)
	{
		_session = [[QTCaptureSession alloc] init];
		_output = [[QTCaptureMovieFileOutput alloc] init];
		
		[_output setDelegate:self];
	}
	
	return self;
}

- (void)dealloc
{
	[_output release];
	[_session release];
	
	[super dealloc];
}


#pragma mark -

- (void)captureOutput:(QTCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error
{
	if (error)
	{
		BOOL success = [[[error userInfo] objectForKey:QTErrorRecordingSuccesfullyFinishedKey] boolValue];
		
		if (!success)
		{
			fprintf(stderr, "%s\n", [[error localizedDescription] UTF8String]);
			
			exit(EXIT_FAILURE);
		}
	}
	
	exit(EXIT_SUCCESS);
}


#pragma mark -

- (void)addInputWithDeviceIndex:(int)index
{
	if (index >= [[self devices] count])
		return;
	
	QTCaptureDevice *device = [[self devices] objectAtIndex:index];
	NSError *error;
	
	[device open:&error];
	
	if (error)
		return;
	
	QTCaptureDeviceInput *input = [[QTCaptureDeviceInput alloc] initWithDevice:device];
	
	[_session addInput:input error:nil];
}

- (NSArray *)devices
{
	NSMutableArray *result = [[NSMutableArray alloc] init];
	
	[result addObjectsFromArray:[QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeSound]];
	[result addObjectsFromArray:[QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeVideo]];
	[result addObjectsFromArray:[QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeMuxed]];
	
	return result;
}

- (void)printDevicesWithIndex
{
	NSMutableArray	*defaults = [[NSMutableArray alloc] init];
	QTCaptureDevice *device;
	
	// Default audio
	device = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo];
	
	if (device)
		[defaults addObject:device];
	
	// Default video
	device = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeSound];
	
	if (device)
		[defaults addObject:device];
	
	// Enumerate
	NSUInteger index = 0;
	NSEnumerator *enumerator = [[self devices] objectEnumerator];
	
    while (device = [enumerator nextObject])
	{
		if ([defaults containsObject:device])
			printf("%2d: %s (*)\n", (int)index, [[device localizedDisplayName] UTF8String]);
		else
			printf("%2d: %s\n", (int)index, [[device localizedDisplayName] UTF8String]);
		
		index++;
	}
}

- (void)setOutput:(NSString *)path
{
	[_output recordToOutputFileURL:[NSURL fileURLWithPath:path]];
	
	[_session addOutput:_output error:nil];
}

- (void)useDefaults
{
	// Set default device
	QTCaptureDevice *device = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeSound];
	NSError *error;
	
	if (device)
		[device open:&error];
	
	if (!error)
	{
		QTCaptureDeviceInput *input = [[QTCaptureDeviceInput alloc] initWithDevice:device];
		
		[_session addInput:input error:nil];
	}
	
	// Set file path
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	
	[dateFormat setDateFormat:@"yyyyMMdd-HHmmss"];
	
	[self setOutput:[NSString stringWithFormat:@"/tmp/%@.mov", [dateFormat stringFromDate:[NSDate date]]]];
}


#pragma mark -

- (void)start
{
	// Check status
	if ([[_session inputs] count] == 0 || [[_session outputs] count] == 0)
	{
		fprintf(stderr, "Missing I/O\n");
		
		exit(EXIT_FAILURE);
	}
	
	// Set file compression
	QTCaptureConnection *connection;
	QTCompressionOptions *options;
	NSEnumerator *enumerator = [[_output connections] objectEnumerator];
	
	while (connection = [enumerator nextObject])
	{
		if ([connection mediaType] == QTMediaTypeVideo)
		{
#ifdef __ppc__
			options = [QTCompressionOptions compressionOptionsWithIdentifier:@"QTCompressionOptionsSD480SizeMPEG4Video"];
			[_output setMinimumVideoFrameInterval:0.2];
#elif __x86_64__
			options = [QTCompressionOptions compressionOptionsWithIdentifier:@"QTCompressionOptionsSD480SizeH264Video"];
#else
			options = [QTCompressionOptions compressionOptionsWithIdentifier:@"QTCompressionOptionsSD480SizeH264Video"];
			[_output setMinimumVideoFrameInterval:0.1];
#endif
		}
		else if ([connection mediaType] == QTMediaTypeSound)
		{
			options = [QTCompressionOptions compressionOptionsWithIdentifier:@"QTCompressionOptionsHighQualityAACAudio"];
		}
		
		if (options)
			[_output setCompressionOptions:options forConnection:connection];	
	}
	
	// Start a record
	[_session startRunning];
}

- (void)stop
{
	[_session stopRunning];
}

@end

