#include <getopt.h>
#include <signal.h>

#import "AppDelegate.h"


int main_ap(int argc, char *argv[]);
void usage();


#pragma mark -

int main(int argc, char *argv[])
{
	@autoreleasepool
	{
		return main_ap(argc, argv);
	}
}

int main_ap(int argc, char *argv[])
{
	if (argc == 1)
	{
		usage();
		
		return EXIT_FAILURE;
	}
	
	AppDelegate *rec = [[AppDelegate alloc] init];
	
	// Parse options
	int arg;
	
	while ((arg = getopt(argc, argv, "ad:hi:lo:p:")) != -1)
	{
		switch (arg)
		{
			case 'a':
				[rec useDefaults];
				break;
				
			case 'd':
				if ([rec addInputWithDisplayIndex:(NSUInteger)strtoul(optarg, NULL, 10)] == NO)
					fprintf(stderr, "Warning: Display %s can't be added.\n", optarg);
				break;
				
			case 'h':
			{
				usage();
				
				return EXIT_SUCCESS;
			}
				
			case 'i':
				if ([rec addInputWithDeviceIndex:(NSUInteger)strtoul(optarg, NULL, 10)] == NO)
					fprintf(stderr, "Warning: Input %s can't be added.\n", optarg);
				break;
				
			case 'l':
			{
				// List devices
				printf("Devices:\n");
				
				[rec enumerateDevicesUsingBlock:^(NSString *device, BOOL isDefault, NSUInteger index) {
					
					if (isDefault)
						printf("%2d: %s (*)\n", (int)index, [device UTF8String]);
					else
						printf("%2d: %s\n", (int)index, [device UTF8String]);
				}];
				
				// List displays
				printf("Displays:\n");
				
				[rec enumerateDisplaysUsingBlock:^(NSString *display, BOOL isDefault, NSUInteger index) {
					
					if (isDefault)
						printf("%2d: %s (*)\n", (int)index, [display UTF8String]);
					else
						printf("%2d: %s\n", (int)index, [display UTF8String]);
				}];
				
				// List presets
				printf("Presets:\n");
				
				[rec enumeratePresetsUsingBlock:^(NSString *preset, NSUInteger index) {
					
					printf("%2d: %s\n", (int)index, [preset UTF8String]);
				}];
				
				return EXIT_SUCCESS;
			}
				
			case 'o':
				rec.outfile = @(optarg);
				break;
				
			case 'p':
				[rec setPreset:atoi(optarg)];
				break;
		}
	}
	
	// Catch signals
	signal(SIGINT, SIG_IGN);
	signal(SIGTERM, SIG_IGN);
	
	dispatch_source_t _intSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_SIGNAL, SIGINT, 0, dispatch_get_main_queue());
	dispatch_source_t _termSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_SIGNAL, SIGTERM, 0, dispatch_get_main_queue());
	
	dispatch_block_t handler = ^{
		
		fprintf(stderr, "Stopping...\n");
		
		[rec stop];
	};
	
	dispatch_source_set_event_handler(_intSource, handler);
	dispatch_source_set_event_handler(_termSource, handler);
	
	dispatch_resume(_intSource);
	dispatch_resume(_termSource);
	
	// Set finish handler
	rec.finishHandler = ^(BOOL success, NSError *error){
		
		if (success)
		{
			exit(EXIT_SUCCESS);
		}
		else
		{
			fprintf(stderr, "%s\n", [[error localizedDescription] UTF8String]);
			
			exit(EXIT_FAILURE);
		}
	};
	
	// Start record
	[rec start];
	
	// Start run loop
	[[NSRunLoop mainRunLoop] run];
	
	return EXIT_SUCCESS;
}


#pragma mark -

void usage()
{
	fprintf(stderr, "Usage: rec2 [-a] [-i index] [-o file] [-p index]\n");
	fprintf(stderr, "       rec2 -l\n");
}
