#import "XamAppDelegate.h"
#import "XamViewController.h"
#import "XamCollectionViewController.h"


@interface XamAppDelegate ()

- (NSString *) stringForDefaultsDictionary:(NSString *) aIgnore;
- (NSString *) stringForPreferencesPath:(NSString *) aIgnore;

@end


@implementation XamAppDelegate

- (NSString *) stringForPreferencesPath:(NSString *) aIgnore {
  NSString *plistRootPath = nil, *relativePlistPath = nil;
  NSString *plistName = [NSString stringWithFormat:@"%@.plist", [[NSBundle mainBundle] bundleIdentifier]];

  // 1. get into the simulator's app support directory by fetching the sandboxed Library's path
  NSArray *userLibDirURLs = [[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];

  NSURL *userDirURL = [userLibDirURLs lastObject];
  NSString *userDirectoryPath = [userDirURL path];

  // 2. get out of our application directory, back to the root support directory for this system version
  if ([userDirectoryPath rangeOfString:@"CoreSimulator"].location == NSNotFound) {
    plistRootPath = [userDirectoryPath substringToIndex:([userDirectoryPath rangeOfString:@"Applications"].location)];
  } else {
    NSRange range = [userDirectoryPath rangeOfString:@"data"];
    plistRootPath = [userDirectoryPath substringToIndex:range.location + range.length];
  }

  // 3. locate, relative to here, /Library/Preferences/[bundle ID].plist
  relativePlistPath = [NSString stringWithFormat:@"Library/Preferences/%@", plistName];

  // 4. and unescape spaces, if necessary (i.e. in the simulator)
  NSString *unsanitizedPlistPath = [plistRootPath stringByAppendingPathComponent:relativePlistPath];
  return [[unsanitizedPlistPath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] copy];
}

- (NSString *) stringForDefaultsDictionary:(NSString *) aIgnore {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults synchronize];
  NSDictionary *dictionary = [defaults dictionaryRepresentation];
  NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary
                                                 options:NSJSONWritingPrettyPrinted
                                                   error:nil];
  NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  return string;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
  XamViewController *firstController = [XamViewController new];
  XamCollectionViewController *secondViewController = [XamCollectionViewController new];
  
  UITabBarController *tabController = [UITabBarController new];
  tabController.tabBar.translucent = NO;
  tabController.viewControllers = @[firstController, secondViewController];

  self.window.rootViewController = tabController;
  [self.window makeKeyAndVisible];

  [[NSUserDefaults standardUserDefaults] setObject:@"Hey!" forKey:@"com.example.set-in-uiapplication-delegate"];
  [[NSUserDefaults standardUserDefaults] synchronize];

#if TARGET_IPHONE_SIMULATOR
  NSLog(@"%@", [self stringForPreferencesPath:nil]);
#endif
  NSLog(@"%@", [self stringForDefaultsDictionary:nil]);
  return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
  /*
   Sent when the application is about to move from active to inactive state.
   This can occur for certain types of temporary interruptions (such as an
   incoming phone call or SMS message) or when the user quits the application
   and it begins the transition to the background state. Use this method to
   pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates.
   Games should use this method to pause the game.
   */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  /*
   Use this method to release shared resources, save user data, invalidate
   timers, and store enough application state information to restore your
   application to its current state in case it is terminated later. If your
   application supports background execution, this method is called instead of
   applicationWillTerminate: when the user quits.
   */
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  /*
   Called as part of the transition from the background to the inactive state;
   here you can undo many of the changes made on entering the background.
   */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  /*
   Restart any tasks that were paused (or not yet started) while the application
   was inactive. If the application was previously in the background, optionally
   refresh the user interface.
   */
}

- (void)applicationWillTerminate:(UIApplication *)application {
  /*
   Called when the application is about to terminate. Save data if appropriate.
   See also applicationDidEnterBackground:.
   */
}


@end
