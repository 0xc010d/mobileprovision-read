#import <Foundation/Foundation.h>
#import <Security/Security.h>
 
int main(int argc, const char *argv[]) {
    NSUserDefaults *arguments = [NSUserDefaults standardUserDefaults];
    NSString *file = [arguments stringForKey:@"f"];
    NSString *option = [arguments stringForKey:@"o"];
 
    if (!file) {
        printf("\
\033[1m%1$s\033[0m -- mobileprovision files querying tool.\n\
\n\
\033[1mUSAGE\033[0m\n\
\033[1m%1$s\033[0m \033[1m-f\033[0m \033[4mfileName\033[0m [\033[1m-o\033[0m \033[4moption\033[0m]\n\n\
\033[1mOPTIONS\033[0m\n\
    \033[1mtype\033[0m – prints mobileprovision profile type (debug, ad-hoc, enterprise, appstore)\n\
    \033[1mappid\033[0m – prints application identifier\n\
Will print raw provision's plist if option is not specified.\n\
You can also use \033[1mkey path\033[0m as an option.\n\
\n\
\033[1mEXAMPLES\033[0m\n\
%1$s -f test.mobileprovision -o type\n\
    Prints profile type\n\
\n\
%1$s -f test.mobileprovision -o UUID\n\
    Prints profile UUID\n\
\n\
%1$s -f test.mobileprovision -o ProvisionedDevices\n\
    Prints provisioned devices UDIDs\n\
\n\
%1$s -f test.mobileprovision -o Entitlements.get-task-allow\n\
    Prints 0 if profile doesn't allow debugging 1 otherwise\n\
", argv[0]);
        return 1001;
    }
 
    CMSDecoderRef decoder = NULL;
    CFDataRef dataRef = NULL;
    NSString *plistString = nil;
 
    @try {
        CMSDecoderCreate(&decoder);
        NSData *fileData = [NSData dataWithContentsOfFile:file];
        CMSDecoderUpdateMessage(decoder, fileData.bytes, fileData.length);
        CMSDecoderFinalizeMessage(decoder);
        CMSDecoderCopyContent(decoder, &dataRef);
        plistString = [[NSString alloc] initWithData:(NSData *)dataRef encoding:NSUTF8StringEncoding];
    }
    @catch (NSException *exception) {
        printf("Could not decode file.\n");
    }
    @finally {
        if (decoder) CFRelease(decoder);
        if (dataRef) CFRelease(dataRef);
    }
 
    if (plistString) {
        NSDictionary *plist = [plistString propertyList];
 
        if (!option) {
            printf("%s", [plistString UTF8String]);
        }
        if ([option isEqualToString:@"type"]) {
            if ([plist valueForKeyPath:@"ProvisionedDevices"]){
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
        else if ([option isEqualToString:@"appid"]) {
            NSString *applicationIdentifier = [plist valueForKeyPath:@"Entitlements.application-identifier"];
            NSString *prefix = [[[plist valueForKeyPath:@"ApplicationIdentifierPrefix"] objectAtIndex:0] stringByAppendingString:@"."];
            printf("%s\n", [[applicationIdentifier stringByReplacingOccurrencesOfString:prefix withString:@""] UTF8String]);
        }
        else {
            id result = [plist valueForKeyPath:option];
            if (result) {
                if ([result isKindOfClass:[NSArray class]] && [result count]) {
                    printf("%s\n", [[result componentsJoinedByString:@"\n"] UTF8String]);
                }
                else {
                    printf("%s\n", [[result description] UTF8String]);
                }
            }
        }
    }
 
    [plistString release];
 
    return 0;
}
