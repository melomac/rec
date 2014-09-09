#import "AppDelegate.h"


static BOOL stop = NO;

void shutdown(int signum);
void usage();


#pragma mark -

int main(int argc, char *argv[])
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if (argc == 1)
	{
		usage();
		
		exit(EXIT_FAILURE);
	}
	
	signal(SIGINT, shutdown);
	signal(SIGTERM, shutdown);
	
	AppDelegate *rec = [[AppDelegate alloc] init];
	
	int arg;
	
	while ((arg = getopt(argc, argv, "ahi:lo:")) != -1)
	{
		switch (arg)
		{
			case 'a':
				[rec useDefaults];
				break;
				
			case 'h':
			{
				usage();
				
				return EXIT_SUCCESS;
			}
				
			case 'i':
				[rec addInputWithDeviceIndex:atoi(optarg)];
				break;
				
			case 'l':
			{
				[rec printDevicesWithIndex];
				
				return EXIT_SUCCESS;
			}
				
			case 'o':
				[rec setOutput:[NSString stringWithUTF8String:optarg]];
				break;
		}
	}
	
	[rec start];
	
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	
	while (YES)
	{
		[runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
		
		if (stop)
		{
			stop = NO;
			
			[rec stop];
		}
	}	
	
	[pool drain];
	
	return EXIT_SUCCESS;
}


#pragma mark -

void shutdown(int signum)
{
	fprintf(stderr, "Stopping...\n");
	
	stop = YES;
}

void usage()
{
	fprintf(stderr, "Usage: rec [-a] [-i index] [-o file]\n");
	fprintf(stderr, "       rec -l\n");
}

