#import <Foundation/Foundation.h>

@interface AppDelegate : NSObject

@property (strong, nonatomic)	NSString	*outfile;
@property (readonly)			NSArray		*devices;
@property (readonly)			NSArray		*presets;

@property (strong, nonatomic)	void (^finishHandler)(BOOL success, NSError *error);

- (BOOL)addInputWithDeviceIndex:(NSUInteger)index;
- (BOOL)addInputWithDisplayIndex:(NSUInteger)index;
- (void)enumerateDevicesUsingBlock:(void (^)(NSString *device, BOOL isDefault, NSUInteger index))block;
- (void)enumerateDisplaysUsingBlock:(void (^)(NSString *display, BOOL isDefault, NSUInteger index))block;
- (void)enumeratePresetsUsingBlock:(void (^)(NSString *preset, NSUInteger index))block;
- (void)setPreset:(int)index;
- (void)useDefaults;

- (void)start;
- (void)stop;

@end
