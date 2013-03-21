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
            printf("\n\
The script usage:\n\
\033[1mmobileprovisionParser\033[0m -f \033[4mfileName\033[0m [-o \033[4moption\033[0m]\n\n");
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
	NSString *fileString = [[NSString alloc] initWithContentsOfFile:file encoding:NSStringEncodingConversionAllowLossy error:nil];
	NSScanner *scanner = [[NSScanner alloc] initWithString:fileString];
	[fileString release];	
	if ([scanner scanUpToString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>" intoString:NULL]) {
		NSString *plistString;
		if ([scanner scanUpToString:@"</plist>" intoString:&plistString]) {
			[scanner release];
			NSDictionary *plist = [[plistString stringByAppendingString:@"</plist>"] propertyList];
			
			//get profile type
			//possible types:
			//		debug
			//		ad-hoc
			//		enterprise
			//		appstore
			if ([option isEqualToString:@"type"]) {
				if ([plist valueForKeyPath:@"ProvisionedDevices"]) {
					if ([[plist valueForKeyPath:@"Entitlements.get-task-allow"] boolValue]) {
						printf("debug\n");
					} 
					else {
						printf("ad-hoc\n");
					}
				} 
				else if ([[plist valueForKeyPath:@"ProvisionsAllDevices"] boolValue]) {
					printf("enterprise\n");
				}
				else {
					printf("appstore\n");
				}
			} 
			//get the UUID of the profile
			else if ([option isEqualToString:@"uuid"]) {
				printf("%s\n", [[plist valueForKeyPath:@"UUID"] UTF8String]);
			} 
			//get application identifier prefix
			else if([option isEqualToString:@"appid"]) {
				NSString *pid = [[plist valueForKeyPath:@"Entitlements"] valueForKeyPath:@"application-identifier"];
				NSMutableString *apid =  [[[plist valueForKeyPath:@"ApplicationIdentifierPrefix"] objectAtIndex:0] mutableCopy];
				[apid appendString:@"."];
				NSString *app_id = [pid stringByReplacingOccurrencesOfString:apid withString:@""];
				printf("%s\n", [app_id UTF8String]);
			} 
			//get the supported devices list
			else if ([option isEqualToString:@"devices"]) {
				NSArray *devices = [plist valueForKeyPath:@"ProvisionedDevices"];
				if (devices) {
					for (NSString *deviceId in devices) {
						printf("%s\n", [deviceId UTF8String]);
					}
				}
			}
            else if ([option isEqualToString:@"bundleid"]) {
                NSString *bundleid = [plist valueForKeyPath:@"Entitlements.application-identifier"];
                if (bundleid) {
                    printf("%s\n", [bundleid UTF8String]);
                }
            }
		} 
		else {
			[scanner release];
			return 1002;
		}
	} 
	else {
		[scanner release];
		return 1002;
	}
    
	[pool drain];
	return 0;
}
