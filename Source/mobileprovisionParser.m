#import <Foundation/Foundation.h>

int main (int argc, const char * argv[]) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
	//get arguments
	NSUserDefaults *arguments = [NSUserDefaults standardUserDefaults];
	NSString *file = [arguments stringForKey:@"f"]; // .mobileprovision file path
	NSString *option = [arguments stringForKey:@"o"]; // option: type|uuid|devices
	if (!file) {
		file = [arguments stringForKey:@"-file"];
		if	(!file) {
			return 1001;
		}
	}
	if (!option) {
		option = [arguments stringForKey:@"-option"];
		if	(!option) {
			option = @"type";
		}
	}
	
	//get plist XML
	NSString *fileString = [[NSString alloc] initWithContentsOfFile:file];
	NSScanner *scanner = [[NSScanner alloc] initWithString:fileString];
	[fileString release];	
	if ([scanner scanUpToString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>" intoString:NULL]) {
		NSString *plistString;
		if ([scanner scanUpToString:@"</plist>" intoString:&plistString]) {
			[scanner release];
			NSDictionary *plist = [[plistString stringByAppendingString:@"</plist>"] propertyList];
			
			//get profile type
			//possible types:
			//		ad-hoc
			//		appstore
			//		debug
			if ([option isEqualToString:@"type"]) {
				if ([plist valueForKeyPath:@"ProvisionedDevices"]) {
					if ([[plist valueForKeyPath:@"Entitlements.get-task-allow"] boolValue]) {
						printf("debug\n");
					} else {
						printf("ad-hoc\n");
					}
				} else {
					printf("appstore\n");
				}
			} else 
				//get the UUID of the profile
				if ([option isEqualToString:@"uuid"]) {
					printf("%s\n", [[plist valueForKeyPath:@"UUID"] cStringUsingEncoding:NSUTF8StringEncoding]);
				} else 
					//get the supported devices list
					if ([option isEqualToString:@"devices"]) {
						NSArray *devices = [plist valueForKeyPath:@"ProvisionedDevices"];
						if (devices) {
							for (NSString *deviceId in devices) {
								printf("%s\n", [deviceId cStringUsingEncoding:NSUTF8StringEncoding]);
							}
						}
					}
		} else {
			[scanner release];
			return 1002;
		}
	} else {
		[scanner release];
		return 1002;
	}
    
	[pool drain];
	return 0;
}