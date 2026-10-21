//
//  tabAppDelegate.m
//  tabelinha
//
//  Created by claudio on 16/01/13.
//  Copyright (c) 2013 claudio. All rights reserved.
//

#import "tabAppDelegate.h"
#import "Flurry.h"
#import "iRate.h"
#import "Parse/Parse.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

#define kParseApplicationId @"e7K1BZd7DNzfOJqGbHWbQn7dyqP6ZyTsO8zhpOm4"
#define kParseClientKey @"o1BgNvpwOYiyHsr6gK7YDi2KIrS17WevKWZKvSQE"

@implementation tabAppDelegate


+ (void)initialize
{
    //configure iRate  595717748
    [iRate sharedInstance].daysUntilPrompt = 20;
    [iRate sharedInstance].usesUntilPrompt = 20;
    [iRate sharedInstance].remindPeriod = 20;
    [iRate sharedInstance].promptAtLaunch = NO;
    [iRate sharedInstance].previewMode = NO;
    [iRate sharedInstance].promptForNewVersionIfUserRated = YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert |
         UIUserNotificationTypeBadge |
         UIUserNotificationTypeSound
                                          categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIUserNotificationTypeAlert |
         UIUserNotificationTypeBadge | UIUserNotificationTypeSound];
        
    }

    // Override point for customization after application launch.
    [Flurry startSession:@"9DHKB4Y8TVKM2VCPHHS3"];
    [Parse setApplicationId:kParseApplicationId clientKey:kParseClientKey];

  //  [self checaMudanca];
//    NSLog(@"%@", [[PFInstallation currentInstallation] deviceToken]);
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

/*-(void) atualiza:(NSString *) chave valorNovo:(NSString *) valorNovo valorVelho: (NSString *) valorVelho
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if(valorVelho)
    {
        [currentInstallation removeObject:valorVelho forKey:@"channels"];
        [currentInstallation saveInBackground];
    }
    [currentInstallation addUniqueObject:valorNovo forKey:@"channels"];
    [currentInstallation saveInBackground];
}*/

/*- (void) checaMudanca
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSDictionary *propriedades = [defs dictionaryForKey:@"propriedades"];
    NSString *idiomaAtual = [[NSString alloc] initWithFormat:
                            @"%@", NSLocalizedString(@"idioma", @"idioma") ];
    NSString *versaoAtual =[[NSString alloc] initWithFormat: @"V%@",
                              [
                               [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleShortVersionString"]
                               stringByReplacingOccurrencesOfString: @"." withString: @"_"]];
    
    
    BOOL mudanca = NO;
    if (propriedades) {
        NSString *idiomaAntigo = [[NSString alloc] initWithFormat:
                                  @"%@", [propriedades objectForKey: @"idioma"]];
        NSString *versaoAntigo = [[NSString alloc] initWithFormat:
                                  @"%@", [propriedades objectForKey: @"versao"]];

        if (!([idiomaAtual isEqualToString:idiomaAntigo])) {
            [self atualiza:@"idioma" valorNovo:idiomaAtual valorVelho:idiomaAntigo];
            mudanca = YES;
        }
        if (!([versaoAtual isEqualToString:versaoAntigo])) {
            [self atualiza:@"versao" valorNovo:versaoAtual valorVelho:versaoAntigo];
            mudanca = YES;
        }
        if (mudanca) {
     //       [Flurry logEvent:[NSString stringWithFormat:@"Dados, %@, %@, %@", [currentInstallation deviceToken], idiomaAtual, versaoAtual]];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:idiomaAtual, @"idioma", versaoAtual, @"versao", nil];
            [defs setObject:dict forKey:@"propriedades"];
            [defs synchronize];
        }
    }else{
        if ([currentInstallation deviceToken]){
            [self atualiza:@"versao" valorNovo:versaoAtual valorVelho:nil];
            [self atualiza:@"idioma" valorNovo:idiomaAtual valorVelho:nil];
     //       [Flurry logEvent:[NSString stringWithFormat:@"Dados, %@, %@, %@", [currentInstallation deviceToken], idiomaAtual, versaoAtual]];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:idiomaAtual, @"idioma", versaoAtual, @"versao", nil];
            [defs setObject:dict forKey:@"propriedades"];
            [defs synchronize];
        }
    }
}*/

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
}


- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)newDeviceToken{
//    NSLog(@"My token is: %@", newDeviceToken);
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation saveInBackground];
}
- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBSDKAppEvents activateApp];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0){
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
