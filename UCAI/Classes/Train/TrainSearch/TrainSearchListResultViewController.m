//
//  TrainSearchListResultViewController.m
//  UCAI
//
//  Created by  on 12-1-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "QuartzCore/QuartzCore.h"
#import "TrainSearchListResultViewController.h"
#import "TrainStationListResultViewController.h"
#import "TrainSearchResponseModel.h"
#import "TrainDetailResponseModel.h"

#import "ResponseParser.h"
#import "ASIFormDataRequest.h"
#import "GDataXMLNode.h"
#import "StaticConf.h"
#import "CommonTools.h"
#import "PiosaFileManager.h"

#define kIDTag 101			//排序编号
#define kTrainCodeTag 102	//列车车次
#define kTrainTypeTag 103	//列车等级
#define kStartCityTag 104	//出发车站
#define kStartTimeTag 105	//出发时间，时间格式为“HH:mm”
#define kEndCityTag 106     //到达车站
#define kEndTimeTag 107     //到达时间，时间格式为“HH:mm”
#define kDistanceTag 108	//站站距离
#define kCostTimeTag 109	//运行时间，时间格式为“HH:mm”，HH表示小时数，mm表示分钟数
#define kYZTag 110          //硬座票价
#define kRZTag 111          //软座票价
#define kRZ1Tag 112         //一等软座票价
#define kRZ2Tag 113         //二等软座票价
#define kYWSTag 114         //硬卧上铺票价
#define kYWZTag 115         //硬卧中铺票价
#define kYWXTag 116         //硬卧下铺票价
#define kRWSTag 117         //软卧上铺票价
#define kRWXTag 118         //软卧下铺票价
#define kGWSTag 119         //高级软卧上铺票价
#define kGWXTag 120         //高级软卧下铺票价

@implementation TrainSearchListResultViewController

@synthesize trainSearchResponseModel = _trainSearchResponseModel;
@synthesize startedCityName = _startedCityName;
@synthesize arrivedCityName = _arrivedCityName;

- (void)dealloc {
    [_tipsView release];
    
    [self.startedCityName release];
    [self.arrivedCityName release];
    [self.trainSearchResponseModel release];
    [super dealloc];
}

#pragma mark -
#pragma mark Custom

- (void)backOrHome:(UIButton *) button
{
    switch (button.tag) {
        case 101:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case 102:
            [self.navigationController popToRootViewControllerAnimated:YES];
            break;
    }
}

- (void)tipsViewAppear{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.30];
    _tipsView.alpha = 1.0;
    [UIView commitAnimations];
}

- (void)tipsViewDisAppear{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.30];
    _tipsView.alpha = 0.0;
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark View lifecycle

- (void) loadView{
    [super loadView];
    
    self.title = @"列车信息";
    
    //返回按钮
    NSString *backButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"backButton_normal" inDirectory:@"CommonView/NavigationItem"];
    NSString *backButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"backButton_highlighted" inDirectory:@"CommonView/NavigationItem"];
    UIButton * backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    backButton.tag = 101;
    [backButton setBackgroundImage:[UIImage imageNamed:backButtonNormalPath] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:backButtonHighlightedPath] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backOrHome:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    [backBarButtonItem release];
    [backButton release];
    
    //主页按钮
    NSString *homeButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"homeButton_normal" inDirectory:@"CommonView/NavigationItem"];
    NSString *homeButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"homeButton_highlighted" inDirectory:@"CommonView/NavigationItem"];
    UIButton * homeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    homeButton.tag = 102;
    [homeButton setBackgroundImage:[UIImage imageNamed:homeButtonNormalPath] forState:UIControlStateNormal];
    [homeButton setBackgroundImage:[UIImage imageNamed:homeButtonHighlightedPath] forState:UIControlStateHighlighted];
    [homeButton addTarget:self action:@selector(backOrHome:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *homeBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:homeButton];
    self.navigationItem.rightBarButtonItem = homeBarButtonItem;
    [homeBarButtonItem release];
    [homeButton release];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 25)];
    titleView.backgroundColor = [PiosaColorManager secondTitleColor];
    
    UILabel *startedDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 80, 20)];
    startedDateLabel.backgroundColor = [UIColor clearColor];
    startedDateLabel.textColor = [UIColor whiteColor];
    startedDateLabel.font = [UIFont systemFontOfSize:12];
    startedDateLabel.text = self.trainSearchResponseModel.sDate;
    [titleView addSubview:startedDateLabel];
    [startedDateLabel release];
    
    UILabel *cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 120, 25)];
    cityLabel.backgroundColor = [UIColor clearColor];
    cityLabel.textColor = [UIColor whiteColor];
    cityLabel.font = [UIFont boldSystemFontOfSize:14];
    cityLabel.textAlignment = UITextAlignmentCenter;
    cityLabel.text = [NSString stringWithFormat:@"%@ ⇀ %@",self.startedCityName,self.arrivedCityName];
    [titleView addSubview:cityLabel];
    [cityLabel release];
    
    UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(235, 5, 80, 20)];
    countLabel.backgroundColor = [UIColor clearColor];
    countLabel.textColor = [UIColor whiteColor];
    countLabel.font = [UIFont boldSystemFontOfSize:12];
    countLabel.textAlignment = UITextAlignmentRight;
    countLabel.text = [NSString stringWithFormat:@"%@个结果",self.trainSearchResponseModel.iCount];
    [titleView addSubview:countLabel];
    [countLabel release];
    
    [self.view addSubview:titleView];
    [titleView release];
    
    UIScrollView *trainListScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 25, 320, 391)];
    trainListScrollView.contentSize = CGSizeMake(660, 391);
    
    UITableView *trainListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 660, 391) style:UITableViewStylePlain];
    trainListTableView.dataSource = self;
    trainListTableView.delegate = self;
    [trainListScrollView addSubview:trainListTableView];
    [trainListTableView release];
    
    [self.view addSubview:trainListScrollView];
    [trainListScrollView release];
    
    UIView *tipsView = [[UIView alloc] initWithFrame:CGRectMake(80, 300, 160, 80)];
    tipsView.backgroundColor = [PiosaColorManager progressColor];
    tipsView.layer.cornerRadius = 10;
    
    UILabel *tipsArrLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 40)];
    tipsArrLabel.backgroundColor = [UIColor clearColor];
    tipsArrLabel.font = [UIFont systemFontOfSize:60];
    tipsArrLabel.textAlignment = UITextAlignmentCenter;
    tipsArrLabel.textColor = [UIColor whiteColor];
    tipsArrLabel.text = @"↔";
    [tipsView addSubview:tipsArrLabel];
    [tipsArrLabel release];
    
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 160, 20)];
    tipsLabel.backgroundColor = [UIColor clearColor];
    tipsLabel.font = [UIFont boldSystemFontOfSize:13];
    tipsLabel.textAlignment = UITextAlignmentCenter;
    tipsLabel.textColor = [UIColor whiteColor];
    tipsLabel.text = @"左右划动来查看更多信息";
    [tipsView addSubview:tipsLabel];
    [tipsLabel release];
    
    tipsView.alpha = 0.0;
    [self.view addSubview:tipsView];
    _tipsView = tipsView;
    
    [self performSelector:@selector(tipsViewAppear) withObject:nil afterDelay:0.5];
    [self performSelector:@selector(tipsViewDisAppear) withObject:nil afterDelay:3.0];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.trainSearchResponseModel.data count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d", indexPath.row];
    
    UILabel * trainCode;
    UILabel * trainType;
    UILabel * startCity;
    UILabel * startTime;
    UILabel * endCity;
    UILabel * endTime;
    UILabel * distance;
    UILabel * costTime;
    UILabel * yz;
    UILabel * rz;
    UILabel * rz1;
    UILabel * rz2;
    UILabel * yws;
    UILabel * ywz;
    UILabel * ywx;
    UILabel * rws;
    UILabel * rwx;
    UILabel * gws;
    UILabel * gwx;
    
    TrainData *trainData = (TrainData *)[self.trainSearchResponseModel.data objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
   
        UILabel * trainCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 40, 20)];
        trainCodeLabel.tag = kTrainCodeTag;
        trainCodeLabel.backgroundColor = [UIColor clearColor];
        trainCodeLabel.textColor = [UIColor redColor];
        trainCodeLabel.font = [UIFont systemFontOfSize:15];
        trainCodeLabel.textAlignment = UITextAlignmentCenter;
        trainCode = trainCodeLabel;
        [cell.contentView addSubview:trainCodeLabel];
        [trainCodeLabel release];
        
        UILabel * trainTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 30, 40, 20)];
        trainTypeLabel.tag = kTrainTypeTag;
        trainTypeLabel.backgroundColor = [UIColor clearColor];
        trainTypeLabel.textColor = [PiosaColorManager fontColor];
        trainTypeLabel.font = [UIFont systemFontOfSize:15];
        trainTypeLabel.textAlignment = UITextAlignmentCenter;
        trainType = trainTypeLabel;
        [cell.contentView addSubview:trainTypeLabel];
        [trainTypeLabel release];
        
        UILabel * startCityLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 5, 70, 20)];
        startCityLabel.tag = kStartCityTag;
        startCityLabel.backgroundColor = [UIColor clearColor];
        startCityLabel.font = [UIFont systemFontOfSize:15];
        startCityLabel.textAlignment = UITextAlignmentCenter;
        startCity = startCityLabel;
        [cell.contentView addSubview:startCityLabel];
        [startCityLabel release];
        
        UILabel * endCityLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 30, 70, 20)];
        endCityLabel.tag = kEndCityTag;
        endCityLabel.backgroundColor = [UIColor clearColor];
        endCityLabel.textColor = [UIColor grayColor];
        endCityLabel.font = [UIFont systemFontOfSize:15];
        endCityLabel.textAlignment = UITextAlignmentCenter;
        endCity = endCityLabel;
        [cell.contentView addSubview:endCityLabel];
        [endCityLabel release];
        
        UILabel * startTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 5, 40, 20)];
        startTimeLabel.tag = kStartTimeTag;
        startTimeLabel.backgroundColor = [UIColor clearColor];
        startTimeLabel.font = [UIFont systemFontOfSize:15];
        startTimeLabel.textAlignment = UITextAlignmentCenter;
        startTime = startTimeLabel;
        [cell.contentView addSubview:startTimeLabel];
        [startTimeLabel release];
        
        UILabel * endTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 30, 40, 20)];
        endTimeLabel.tag = kEndTimeTag;
        endTimeLabel.backgroundColor = [UIColor clearColor];
        endTimeLabel.textColor = [UIColor grayColor];
        endTimeLabel.font = [UIFont systemFontOfSize:15];
        endTimeLabel.textAlignment = UITextAlignmentCenter;
        endTime = endTimeLabel;
        [cell.contentView addSubview:endTimeLabel];
        [endTimeLabel release];
        
        UILabel * costTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(163, 5, 40, 20)];
        costTimeLabel.tag = kCostTimeTag;
        costTimeLabel.backgroundColor = [UIColor clearColor];
        costTimeLabel.font = [UIFont systemFontOfSize:15];
        costTimeLabel.textAlignment = UITextAlignmentCenter;
        costTime = costTimeLabel;
        [cell.contentView addSubview:costTimeLabel];
        [costTimeLabel release];
        
        UILabel * distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(163, 30, 40, 20)];
        distanceLabel.tag = kDistanceTag;
        distanceLabel.backgroundColor = [UIColor clearColor];
        distanceLabel.textColor = [UIColor grayColor];
        distanceLabel.font = [UIFont systemFontOfSize:15];
        distanceLabel.textAlignment = UITextAlignmentCenter;
        distance = distanceLabel;
        [cell.contentView addSubview:distanceLabel];
        [distanceLabel release];
        
        UILabel * yzLabel = [[UILabel alloc] initWithFrame:CGRectMake(210, 5, 40, 20)];
        yzLabel.tag = kYZTag;
        yzLabel.backgroundColor = [UIColor clearColor];
        yzLabel.font = [UIFont systemFontOfSize:15];
        yzLabel.textAlignment = UITextAlignmentCenter;
        yz = yzLabel;
        [cell.contentView addSubview:yzLabel];
        [yzLabel release];
        
        UILabel * rzLabel = [[UILabel alloc] initWithFrame:CGRectMake(210, 30, 40, 20)];
        rzLabel.tag = kRZTag;
        rzLabel.backgroundColor = [UIColor clearColor];
        rzLabel.textColor = [UIColor grayColor];
        rzLabel.font = [UIFont systemFontOfSize:15];
        rzLabel.textAlignment = UITextAlignmentCenter;
        rz = rzLabel;
        [cell.contentView addSubview:rzLabel];
        [rzLabel release];
        
        UILabel * rz1Label = [[UILabel alloc] initWithFrame:CGRectMake(255, 5, 70, 20)];
        rz1Label.tag = kRZ1Tag;
        rz1Label.backgroundColor = [UIColor clearColor];
        rz1Label.font = [UIFont systemFontOfSize:15];
        rz1Label.textAlignment = UITextAlignmentCenter;
        rz1 = rz1Label;
        [cell.contentView addSubview:rz1Label];
        [rz1Label release];
        
        UILabel * rz2Label = [[UILabel alloc] initWithFrame:CGRectMake(255, 30, 70, 20)];
        rz2Label.tag = kRZ2Tag;
        rz2Label.backgroundColor = [UIColor clearColor];
        rz2Label.textColor = [UIColor grayColor];
        rz2Label.font = [UIFont systemFontOfSize:15];
        rz2Label.textAlignment = UITextAlignmentCenter;
        rz2 = rz2Label;
        [cell.contentView addSubview:rz2Label];
        [rz2Label release];
        
        UILabel * ywsLabel = [[UILabel alloc] initWithFrame:CGRectMake(330, 5, 45, 20)];
        ywsLabel.tag = kYWSTag;
        ywsLabel.backgroundColor = [UIColor clearColor];
        ywsLabel.font = [UIFont systemFontOfSize:15];
        ywsLabel.textAlignment = UITextAlignmentCenter;
        yws = ywsLabel;
        [cell.contentView addSubview:ywsLabel];
        [ywsLabel release];
        
        UILabel * ywzLabel = [[UILabel alloc] initWithFrame:CGRectMake(377, 5, 45, 20)];
        ywzLabel.tag = kYWZTag;
        ywzLabel.backgroundColor = [UIColor clearColor];
        ywzLabel.font = [UIFont systemFontOfSize:15];
        ywzLabel.textAlignment = UITextAlignmentCenter;
        ywz = ywzLabel;
        [cell.contentView addSubview:ywzLabel];
        [ywzLabel release];
        
        UILabel * ywxLabel = [[UILabel alloc] initWithFrame:CGRectMake(424, 5, 45, 20)];
        ywxLabel.tag = kYWXTag;
        ywxLabel.backgroundColor = [UIColor clearColor];
        ywxLabel.font = [UIFont systemFontOfSize:15];
        ywxLabel.textAlignment = UITextAlignmentCenter;
        ywx = ywxLabel;
        [cell.contentView addSubview:ywxLabel];
        [ywxLabel release];
        
        UILabel * rwsLabel = [[UILabel alloc] initWithFrame:CGRectMake(475, 5, 70, 20)];
        rwsLabel.tag = kRWSTag;
        rwsLabel.backgroundColor = [UIColor clearColor];
        rwsLabel.font = [UIFont systemFontOfSize:15];
        rwsLabel.textAlignment = UITextAlignmentCenter;
        rws = rwsLabel;
        [cell.contentView addSubview:rwsLabel];
        [rwsLabel release];
        
        UILabel * rwxLabel = [[UILabel alloc] initWithFrame:CGRectMake(475, 30, 70, 20)];
        rwxLabel.tag = kRWXTag;
        rwxLabel.backgroundColor = [UIColor clearColor];
        rwxLabel.textColor = [UIColor grayColor];
        rwxLabel.font = [UIFont systemFontOfSize:15];
        rwxLabel.textAlignment = UITextAlignmentCenter;
        rwx = rwxLabel;
        [cell.contentView addSubview:rwxLabel];
        [rwxLabel release];
        
        UILabel * gwsLabel = [[UILabel alloc] initWithFrame:CGRectMake(550, 5, 100, 20)];
        gwsLabel.tag = kGWSTag;
        gwsLabel.backgroundColor = [UIColor clearColor];
        gwsLabel.font = [UIFont systemFontOfSize:15];
        gwsLabel.textAlignment = UITextAlignmentCenter;
        gws = gwsLabel;
        [cell.contentView addSubview:gwsLabel];
        [gwsLabel release];
        
        UILabel * gwxLabel = [[UILabel alloc] initWithFrame:CGRectMake(550, 30, 100, 20)];
        gwxLabel.tag = kGWXTag;
        gwxLabel.backgroundColor = [UIColor clearColor];
        gwxLabel.textColor = [UIColor grayColor];
        gwxLabel.font = [UIFont systemFontOfSize:15];
        gwxLabel.textAlignment = UITextAlignmentCenter;
        gwx = gwxLabel;
        [cell.contentView addSubview:gwxLabel];
        [gwxLabel release];

    } else {
        trainCode = (UILabel *)[cell.contentView viewWithTag:kTrainCodeTag];
        trainType = (UILabel *)[cell.contentView viewWithTag:kTrainTypeTag];
        startCity = (UILabel *)[cell.contentView viewWithTag:kStartCityTag];
        startTime = (UILabel *)[cell.contentView viewWithTag:kStartTimeTag];
        endCity = (UILabel *)[cell.contentView viewWithTag:kEndCityTag];
        endTime = (UILabel *)[cell.contentView viewWithTag:kEndTimeTag];
        distance = (UILabel *)[cell.contentView viewWithTag:kDistanceTag];
        costTime = (UILabel *)[cell.contentView viewWithTag:kCostTimeTag];
        yz = (UILabel *)[cell.contentView viewWithTag:kYZTag];
        rz = (UILabel *)[cell.contentView viewWithTag:kRZTag];
        rz1 = (UILabel *)[cell.contentView viewWithTag:kRZ1Tag];
        rz2 = (UILabel *)[cell.contentView viewWithTag:kRZ2Tag];
        yws = (UILabel *)[cell.contentView viewWithTag:kYWSTag];
        ywz = (UILabel *)[cell.contentView viewWithTag:kYWZTag];
        ywx = (UILabel *)[cell.contentView viewWithTag:kYWXTag];
        rws = (UILabel *)[cell.contentView viewWithTag:kRWSTag];
        rwx = (UILabel *)[cell.contentView viewWithTag:kRWXTag];
        gws = (UILabel *)[cell.contentView viewWithTag:kGWSTag];
        gwx = (UILabel *)[cell.contentView viewWithTag:kGWXTag];
    }
    
    trainCode.text = trainData.TrainCode;
    trainType.text = trainData.TrainType;
    startCity.text = trainData.StartCity;
    startTime.text = trainData.StartTime;
    endCity.text = trainData.EndCity;
    endTime.text = trainData.EndTime;
    distance.text = trainData.Distance;
    costTime.text = trainData.CostTime;
    yz.text = trainData.YZ;
    rz.text = trainData.RZ;
    rz1.text = trainData.RZ1;
    rz2.text = trainData.RZ2;
    yws.text = trainData.YWS;
    ywz.text = trainData.YWZ;
    ywx.text = trainData.YWX;
    rws.text = trainData.RWS;
    rwx.text = trainData.RWX;
    gws.text = trainData.GWS;
    gwx.text = trainData.GWX;
    
    
    if ((indexPath.row+1)%2 == 0) {
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = [PiosaColorManager tableViewPlainSepColor];
        cell.backgroundView = bgView;
        [bgView release];
    }  else  {
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = [UIColor clearColor];
        cell.backgroundView = bgView;
        [bgView release];
    }
    NSString *tableViewCellPlainHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_plain_highlighted" inDirectory:@"CommonView/TableViewCell"];
    cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellPlainHighlightedPath]] autorelease];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView* myView = [[[UIView alloc] init] autorelease];
	myView.backgroundColor = [PiosaColorManager thirdTitleColor];
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 660, 40)];
	titleLabel.textColor=[UIColor whiteColor];
	titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.numberOfLines = 2;
    titleLabel.text = @"车次    始发站    出发    历时    硬座    一等软座    硬卧    硬卧    硬卧    软卧上铺    高级软卧上铺\n类型    终点站    到达    里程    软座    二等软座    上铺    中铺    下铺    软卧下铺    高级软卧下铺";
	[myView addSubview:titleLabel];
	[titleLabel release];
	return myView;
}

#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
	return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
	if ([self.trainSearchResponseModel.data count]<=6) {
		UIView *footer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)] autorelease];
		footer.backgroundColor = [UIColor clearColor];
		return footer;
	} else {
		return nil;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    _selectedRow = [indexPath row];
    
    _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _hud.bgRGB = [PiosaColorManager progressColor];
    [self.navigationController.view addSubview:_hud];
    _hud.delegate = self;
    _hud.minSize = CGSizeMake(135.f, 135.f);
    _hud.labelText = @"查询中...";
    [_hud show:YES];
    
    // 火车票车次细节查询
    TrainData *td = [self.trainSearchResponseModel.data objectAtIndex:_selectedRow];
    NSString *url = [NSString stringWithFormat:@"http://www.ucai.com:8080/accuracy/spi/TrainInfoServlet.do?trainCode=%@&sDate=%@&num=4", td.TrainCode, self.trainSearchResponseModel.sDate];

    ASIFormDataRequest *req = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: url]] autorelease];
	req.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
	[req setDelegate:self];
	[req startAsynchronous]; // 执行异步post
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark -
#pragma mark ASIHTTP Response

- (void) requestFinished:(ASIFormDataRequest *)request
{
    NSLog(@"requestFinished\n");
    [_hud hide:YES];
    
    NSString *responseString = [request responseString];
    NSLog(@"responseString: %@\n", responseString);
    if ((responseString != nil) && [responseString length] > 0) {
        
        TrainDetailResponseModel *trainDetailResponseModel;
        
        NSRange range = [responseString rangeOfString:@"gb2312"];
        // XML 解析,采用Google的GDataXMLNode.h 库
        if (range.length > 0) { // 找到 gb23121, 替换成UTF8,否则解析不出来
            responseString = [responseString stringByReplacingCharactersInRange:range withString:@"UTF8"];
            trainDetailResponseModel = [ResponseParser loadTrainDetailResponse:[responseString dataUsingEncoding:NSUTF8StringEncoding]];
        }
        else { //不是gb2312则默认为UTF8,直接可以解析      
            trainDetailResponseModel = [ResponseParser loadTrainDetailResponse:[request responseData]];
        }
        
        if ([trainDetailResponseModel.searchCode intValue] == 1 && [trainDetailResponseModel.iCount intValue] > 0) {
            TrainData *trainData = [self.trainSearchResponseModel.data objectAtIndex:_selectedRow];
            
            TrainStationListResultViewController *trainStationListResultViewController = [[TrainStationListResultViewController alloc] init];
            trainStationListResultViewController.trainCode = trainData.TrainCode;
            trainStationListResultViewController.startedStationName = self.startedCityName;
            trainStationListResultViewController.arrivedStationName = self.arrivedCityName;
            trainStationListResultViewController.trainDetailResponseModel = trainDetailResponseModel;
            [self.navigationController pushViewController:trainStationListResultViewController animated:YES];
            [trainStationListResultViewController release];
        }
        else {
            // 没有查询结果
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            hud.bgRGB = [PiosaColorManager progressColor];
            [self.navigationController.view addSubview:hud];
            hud.delegate = self;
            hud.minSize = CGSizeMake(135.f, 135.f);
            NSString *exclamationImagePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"exclamation" inDirectory:@"CommonView/ProgressView"];
            UIImageView *exclamationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:exclamationImagePath]];
            exclamationImageView.frame = CGRectMake(0, 0, 37, 37);
            hud.customView = exclamationImageView;
            [exclamationImageView release];
            hud.opacity = 1.0;
            hud.mode = MBProgressHUDModeCustomView;
            hud.labelText = @"未查到列车车次详情!";
            [hud show:YES];
            [hud hide:YES afterDelay:2];
        }
    }
}

// 网络无响应
- (void)requestFailed:(ASIFormDataRequest *)request
{
	// 提示用户打开网络联接
    NSString *badFaceImagePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"badFace" inDirectory:@"CommonView/ProgressView"];
    UIImageView *badFaceImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:badFaceImagePath]];
    badFaceImageView.frame = CGRectMake(0, 0, 37, 37);
    _hud.customView = badFaceImageView;
    [badFaceImageView release];
	_hud.mode = MBProgressHUDModeCustomView;
	_hud.labelText = @"网络连接失败啦";
    [_hud hide:YES afterDelay:3];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [hud removeFromSuperview];
    [hud release];
	hud = nil;
}

@end
