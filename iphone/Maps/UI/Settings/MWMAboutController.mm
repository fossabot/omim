#import "MWMAboutController.h"
#import "AppInfo.h"
#import "Statistics.h"
#import "SwiftBridge.h"
#import "WebViewController.h"
#import "3party/Alohalytics/src/alohalytics_objc.h"

#include "Framework.h"

extern NSString * const kAlohalyticsTapEventKey;

@interface MWMAboutController ()

@property(weak, nonatomic) IBOutlet UILabel * versionLabel;
@property(weak, nonatomic) IBOutlet UILabel * dateLabel;

@property(weak, nonatomic) IBOutlet SettingsTableViewLinkCell * websiteCell;
@property(weak, nonatomic) IBOutlet SettingsTableViewLinkCell * facebookCell;
@property(weak, nonatomic) IBOutlet SettingsTableViewLinkCell * twitterCell;
@property(weak, nonatomic) IBOutlet SettingsTableViewLinkCell * osmCell;
@property(weak, nonatomic) IBOutlet SettingsTableViewLinkCell * rateCell;
@property(weak, nonatomic) IBOutlet SettingsTableViewLinkCell * copyrightCell;

@property(nonatomic) IBOutlet UIView * headerView;

@end

@implementation MWMAboutController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = L(@"about_menu_title");

  [NSBundle.mainBundle loadNibNamed:@"MWMAboutControllerHeader" owner:self options:nil];
  self.tableView.tableHeaderView = self.headerView;

  AppInfo * appInfo = [AppInfo sharedInfo];
  NSString * version = appInfo.bundleVersion;
  if (appInfo.buildNumber)
    version = [NSString stringWithFormat:@"%@.%@", version, appInfo.buildNumber];
  self.versionLabel.text = [NSString stringWithFormat:L(@"version"), version];

  auto const dataVersion = GetFramework().GetCurrentDataVersion();
  self.dateLabel.text = [NSString stringWithFormat:L(@"date"), dataVersion];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  auto cell = static_cast<SettingsTableViewLinkCell *>([tableView cellForRowAtIndexPath:indexPath]);
  if (cell == self.websiteCell)
  {
    [Alohalytics logEvent:kAlohalyticsTapEventKey withValue:@"website"];
    [self openUrl:[NSURL URLWithString:@"https://maps.me"]];
  }
  else if (cell == self.facebookCell)
  {
    [Alohalytics logEvent:kAlohalyticsTapEventKey withValue:@"likeOnFb"];
    [self openUrl:[NSURL URLWithString:@"https://facebook.com/MapsWithMe"]];
  }
  else if (cell == self.twitterCell)
  {
    [Alohalytics logEvent:kAlohalyticsTapEventKey withValue:@"followOnTwitter"];
    [self openUrl:[NSURL URLWithString:@"https://twitter.com/MAPS_ME"]];
  }
  else if (cell == self.osmCell)
  {
    [Alohalytics logEvent:kAlohalyticsTapEventKey withValue:@"osm"];
    [self openUrl:[NSURL URLWithString:@"https://www.openstreetmap.org"]];
  }
  else if (cell == self.rateCell)
  {
    [Statistics logEvent:kStatSettingsOpenSection withParameters:@{kStatName : kStatRate}];
    [Alohalytics logEvent:kAlohalyticsTapEventKey withValue:@"rate"];
    [UIApplication.sharedApplication rateVersionFrom:@"rate_menu_item"];
  }
  else if (cell == self.copyrightCell)
  {
    [Statistics logEvent:kStatSettingsOpenSection withParameters:@{kStatName : kStatCopyright}];
    [Alohalytics logEvent:kAlohalyticsTapEventKey withValue:@"copyright"];
    string s;
    GetPlatform().GetReader("copyright.html")->ReadAsString(s);
    NSString * text = [NSString stringWithFormat:@"%@\n%@", self.versionLabel.text, @(s.c_str())];
    WebViewController * aboutViewController =
        [[WebViewController alloc] initWithHtml:text baseUrl:nil andTitleOrNil:L(@"copyright")];
    aboutViewController.openInSafari = YES;
    [self.navigationController pushViewController:aboutViewController animated:YES];
  }
}

@end
