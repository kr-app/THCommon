// THNSMenuExtensions.h

#import <Cocoa/Cocoa.h>

//--------------------------------------------------------------------------------------------------------------------------------------------
@interface NSMenuItem (THNSMenuExtensions)

+ (NSMenuItem*)th_menuItemWithTitle:(NSString*)title target:(id)target action:(SEL)action representedObject:(id)representedObject tag:(NSInteger)tag isEnabled:(BOOL)isEnabled;
+ (NSMenuItem*)th_menuItemWithTitle:(NSString*)title target:(id)target action:(SEL)action representedObject:(id)representedObject isEnabled:(BOOL)isEnabled;
+ (NSMenuItem*)th_menuItemWithTitle:(NSString*)title target:(id)target action:(SEL)action tag:(NSInteger)tag isEnabled:(BOOL)isEnabled;
+ (NSMenuItem*)th_menuItemWithTitle:(NSString*)title target:(id)target action:(SEL)action tag:(NSInteger)tag;
+ (NSMenuItem*)th_menuItemWithTitle:(NSString*)title target:(id)target action:(SEL)action;

+ (NSMenuItem*)th_menuItemWithTitle:(NSString*)title tag:(NSInteger)tag;
+ (NSMenuItem*)th_menuItemWithTitle:(NSString*)title tag:(NSInteger)tag isEnabled:(BOOL)isEnabled;
+ (NSMenuItem*)th_menuItemWithTitle:(NSString*)title tag:(NSInteger)tag representedObject:(id)representedObject;

+ (NSMenuItem*)th_menuItemWithTitle:(NSString*)title representedObject:(id)representedObject;
+ (NSMenuItem*)th_menuItemWithTitle:(NSString*)title representedObject:(id)representedObject isEnabled:(BOOL)isEnabled;

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
