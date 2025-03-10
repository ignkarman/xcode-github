/**
 @file          XGAStatusViewItem.m
 @package       xcode-github-app
 @brief         The status view detail line.

 @author        Edward Smith
 @date          September 2018
 @copyright     Copyright © 2018 Branch. All rights reserved.
*/

#import "XGAStatusViewItem.h"
#import "XGASettings.h"

@implementation XGAStatusViewItem

+ (instancetype) newItemWithBot:(XGXcodeBot*)bot status:(XGXcodeBotStatus*)botStatus {
    if (bot == nil || botStatus == nil) return nil;
    XGAStatusViewItem *status = [XGAStatusViewItem new];
    NSAssert(status, @"Nil XGAStatusViewItem!");

    status->_bot = bot;
    status->_botStatus = botStatus;

    status.server = botStatus.serverName;
    status.botName = botStatus.botName;

    status.statusSummary = [APFormattedString boldText:@"%@", botStatus.summaryString];
    status.statusDetail = [botStatus formatDetailString:XGASettings.shared.successfulBuildMessage :XGASettings.shared.failedBuildMessage :XGASettings.shared.perfectBuildMessage];

    status.repository = [NSString stringWithFormat:@"%@/%@", bot.repoOwner, bot.repoName];

    // isXGAMonitored
    __auto_type tasks = [XGASettings shared].gitHubSyncTasks;
    for (XGAGitHubSyncTask *task in tasks) {
        if (status.server.length && status.bot.name.length &&
            [task.xcodeServer isEqualToString:status.server] &&
            [task.botNameForTemplate isEqualToString:status.bot.name])
            status->_isXGAMonitored = YES;
    }

    status->_botIsFromTemplate = @(NO);
    if (bot.botIsFromTemplateBot && bot.pullRequestNumber.length) {
        status->_botIsFromTemplate = @(YES);
        status.branchOrPRName = [NSString stringWithFormat:@"PR#%@ %@", bot.pullRequestNumber, bot.pullRequestTitle];
    } else {
        if (status.isXGAMonitored)
            status.branchOrPRName = [NSString stringWithFormat:@"✓ %@", bot.branch];
        else
            status.branchOrPRName = bot.branch;
    }
    if (!status.branchOrPRName.length) status.branchOrPRName = @"< Unknown >";

    status->_hasGitHubRepo = [bot.sourceControlRepository hasPrefix:@"github.com:"];
    status->_botIsFromTemplate = [NSNumber numberWithBool:bot.botIsFromTemplateBot];

    status.templateBotName = bot.templateBotName;
    if (!status.templateBotName.length) status.templateBotName = status.bot.name;

    NSString *result = [botStatus.result lowercaseString];
    if ([botStatus.currentStep containsString:@"completed"]) {

        NSString*imageName = @"RoundRed";
        if ([result containsString:@"succeeded"])
            imageName = @"RoundGreen";
        else
        if ([result containsString:@"unknown"])
            imageName = @"RoundAlert";
        else
        if ([result containsString:@"warning"])
            imageName = @"RoundYellow";
        else
        if ([result containsString:@"unknown"])
            imageName = @"RoundAlert";

        status.statusImage = [NSImage imageNamed:imageName];

    } else
    if ([botStatus.currentStep containsString:@"pending"]) {
        status.statusImage = [NSImage imageNamed:@"RoundGrey"];
    } else
        status.statusImage = [NSImage imageNamed:@"RoundBlue"];

    return status;
}

@end
