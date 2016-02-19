//
//  SLSearchCityPickView.m
//  ZPAreaPickerView
//
//  Created by 赵鹏 on 16/2/18.
//  Copyright © 2016年 赵鹏. All rights reserved.
//

#import "ZPAreaSearchPickView.h"
#import "CALayer+SLPopAddition.h"
#import "ZPSearchReuseHeaderView.h"
#import "VBFPopFlatButton.h"
#import "ZPSearchAreaItem.h"
#import "ZPSearchAreaCell.h"
#import "IMQuickSearch.h"
#import "ZPSearchCityItem.h"
#import "UIView+Extension.h"
#import "SVProgressHUD.h"

static CGFloat kTitleHeight = 30.0f;
static CGFloat kCityCellHeight = 40.0f;

@interface ZPAreaSearchPickView () <UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UISearchDisplayDelegate,ZPSearchReuseHeaderViewDelegate>

@property (weak,   nonatomic) UIVisualEffectView *effectView;
@property (strong, nonatomic) NSMutableArray     *countryArray;
@property (weak,   nonatomic) UITableView        *countrySelectView;
@property (weak,   nonatomic) UIButton           *countyBtn;
@property (weak,   nonatomic) UIButton           *cityBtn;
@property (weak,   nonatomic) UIButton           *titlebtn;

@property (copy,   nonatomic) NSString           *countrySearchString;
@property (copy,   nonatomic) NSString           *citySearchString;
@property (strong, nonatomic) IMQuickSearch      *countrySearch;
@property (strong, nonatomic) IMQuickSearch      *citySearch;
@property (strong, nonatomic) NSArray            *countryFilteredResults;
@property (strong, nonatomic) NSArray            *cityFilteredResults;
@property (weak,   nonatomic) UISearchBar        *searchBar;
@property (copy,   nonatomic) NSString           *searchPlaceholder;
@property (weak,   nonatomic) UIButton           *searchButton;
@property (assign, nonatomic) NSInteger          previousIndex;
@property (assign, nonatomic) NSInteger          selectIndex;
@property (assign, nonatomic) BOOL                searchCity;

@property (strong, nonatomic) NSDictionary *tempCountryCityDict;

@end

@implementation ZPAreaSearchPickView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        UIButton *countryBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.width * 0.5, self.height)];
        [countryBtn setTitle:@"国家 : 点击选择" forState:UIControlStateNormal];
        [countryBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [countryBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
        [countryBtn addTarget:self action:@selector(countryOrCityButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        countryBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _countyBtn = countryBtn;
        [self addSubview:countryBtn];
        
        UIButton *cityBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.width * 0.5,0, self.width * 0.5, self.height)];
        [cityBtn setTitle:@"城市 : 点击选择" forState:UIControlStateNormal];
        cityBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [cityBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cityBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
        [cityBtn addTarget:self action:@selector(countryOrCityButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cityBtn];
        _cityBtn = cityBtn;
        
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    }
    return self;
}

+ (instancetype)cityPickViewWithFrame:(CGRect)frame title:(NSString *)title{
    ZPAreaSearchPickView *pickView = [[ZPAreaSearchPickView alloc]initWithFrame:frame];
    if (title) {
        pickView.countyBtn.frame = CGRectMake(0, kTitleHeight, pickView.width * 0.5,pickView.height - kTitleHeight);
        pickView.cityBtn  .frame = CGRectMake(pickView.width * 0.5, kTitleHeight, pickView.width * 0.5, pickView.height - kTitleHeight);
        
        UILabel *addtionTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, kTitleHeight)];
        addtionTitle.font = [UIFont systemFontOfSize:14];
        addtionTitle.text = title;
        addtionTitle.textAlignment = NSTextAlignmentCenter;
        addtionTitle.backgroundColor = [UIColor colorWithRed:242/255.0 green:246/255.0 blue:248/255.0 alpha:1];
        [pickView addSubview:addtionTitle];
    }
    return pickView;
}

#pragma mark - load network data city && country

- (void)dowloadCountryDataWithCountryWithButton:(UIButton *)btn{
    [SVProgressHUD showWithStatus:@"正在加载..."];
    // 模拟网络加载延迟
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //解析全国省市区信息
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"cityData" ofType:@"plist"];
        NSArray *provincesArr = [NSArray arrayWithContentsOfFile:plistPath];
        _tempCountryCityDict = provincesArr.firstObject;

        [_tempCountryCityDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSArray * _Nonnull obj, BOOL * _Nonnull stop) {
            ZPSearchAreaItem *area = [[ZPSearchAreaItem alloc]init];
            area.country = key;
            [self.countryArray addObject:area];
        }];
        [self configSearchBarAndShowCityPickViewWithButton:btn];
        [SVProgressHUD dismiss];
    });
//    [[SLHttpManager sharedInstance] getCountryWithSuccessBlock:^(NSArray *countries) {
//        self.countryArray = [SLSearchAreaItem countryItemsWithDictionaries:countries];
//        [self configSearchBarAndShowCityPickViewWithButton:btn];
//    } failureBlock:^(NSError *error) {
//
//    }];
}

- (void)dowloadCityDataWithCountry:(ZPSearchAreaItem *)countryItem{
    [SVProgressHUD showWithStatus:@"正在加载..."];
    // 模拟网络加载延迟
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSArray *cityArray = [_tempCountryCityDict objectForKey:countryItem.country];
        NSMutableArray *cityArr = [NSMutableArray array];
        for (NSString *city in cityArray) {
            ZPSearchCityItem *item = [[ZPSearchCityItem alloc]init];
            item.cityName = city;
            [cityArr addObject:item];
        }
        
        countryItem.cityArray = cityArr;
        [self updateSectionsWitCountry:countryItem];
        [SVProgressHUD dismiss];
    });
//    [[SLHttpManager sharedInstance] getCitiesWithCountryId:countryItem.countryId successBlock:^(NSArray *cities) {
//        countryItem.cityArray = [SLSearchCityItem cityItemsWithDictionaries:cities];
//        [self updateSectionsWitCountry:countryItem];
//    } failureBlock:^(NSError *error) {
//        self.cityFilteredResults = @[];
//        countryItem.fold = NO;
//        [self.countrySelectView reloadSections:[NSIndexSet indexSetWithIndex:[_countryFilteredResults indexOfObject:countryItem]] withRowAnimation:UITableViewRowAnimationAutomatic];
//    }];
}

#pragma mark - set up the country search

- (void)setUpQuickSearch {
    // Create Filters
    IMQuickSearchFilter *peopleFilter = [IMQuickSearchFilter filterWithSearchArray:self.countryArray keys:@[@"country"]];
    // Init IMQuickSearch with those Filters
    self.countrySearch = [[IMQuickSearch alloc] initWithFilters:@[peopleFilter]];
}

#pragma mark - filter country search

- (void)filterResults {
    // Asynchronously && BENCHMARK TEST
//    __weak typeof(self)weakSelf = self;
    _selectIndex = -1;
    [self.countrySearch asynchronouslyFilterObjectsWithValue:self.countrySearchString completion:^(NSArray *filteredResults) {
        [self updateTableViewWithNewResults:filteredResults];
    }];
}

#pragma mark - set up  && filter city search

- (void)filterResultsCity {
    // Asynchronously && BENCHMARK TEST
    ZPSearchAreaItem *country = self.countryFilteredResults[_selectIndex];
    IMQuickSearchFilter *cityFilter = [IMQuickSearchFilter filterWithSearchArray:country.cityArray keys:@[@"cityName"]];
    self.citySearch = [[IMQuickSearch alloc] initWithFilters:@[cityFilter]];
    
    [_citySearch asynchronouslyFilterObjectsWithValue:self.citySearchString completion:^(NSArray *filteredResults) {
        [self updateCitisWithNewResults:filteredResults];
    }];
    _previousIndex = -1;
}

- (void)updateCitisWithNewResults:(NSArray *)results {
    self.cityFilteredResults = [results sortedArrayUsingSelector:@selector(compareModel:)];;
    if(results.count == 0){
//        [MBProgressHUD showError:@"没有搜索结果"];
        return;
    }
    [self.countrySelectView reloadSections:[NSIndexSet indexSetWithIndex:self.selectIndex] withRowAnimation:UITableViewRowAnimationFade];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_countrySelectView setContentOffset:CGPointMake(0,_selectIndex * kCityCellHeight) animated:YES];
    });
}

- (void)updateTableViewWithNewResults:(NSArray *)results {
    self.countryFilteredResults = [results sortedArrayUsingSelector:@selector(compareModel:)];
    [_countrySelectView reloadData];
}

#pragma mark - >>>>>>>>>>>>>>>>>>> table sheet relation <<<<<<<<<<<<<<<<<<<

#pragma mark - table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.countryFilteredResults.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    ZPSearchAreaItem *item = self.countryFilteredResults[section];
    if (_selectIndex == section) {
        if (item.fold) {
            return self.cityFilteredResults.count;
        }else{
            return 0;
        }
    }else{
        item.fold = NO;
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZPSearchAreaCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SLSearchAreaCell"];
    if (cell == nil) {
        cell = [[ZPSearchAreaCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SLSearchAreaCell"];
    }
    cell.cityItem = self.cityFilteredResults[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return kCityCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kCityCellHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    static NSString * identifier = @"search_reuse_header_view";
    ZPSearchReuseHeaderView *headView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
    if (!headView) {
        headView = [[ZPSearchReuseHeaderView alloc]initWithReuseIdentifier:identifier];
        headView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 40, 44);
        headView.delegate = self;
    }
    ZPSearchAreaItem *countryItem = _countryFilteredResults[section];
    headView.title = countryItem.country;
    headView.index = section + 9999;
    headView.isUp = countryItem.fold;
    return headView;
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ZPSearchAreaItem *item = _countryFilteredResults[indexPath.section];
    ZPSearchCityItem *cityItem = _cityFilteredResults[indexPath.row];
    [_countyBtn setTitle:item.country forState:UIControlStateNormal];
    [_cityBtn   setTitle:cityItem.cityName forState:UIControlStateNormal];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_selectBlock != nil) {
        _selectBlock(item.country,cityItem.cityName);
    }
    [self removeCityChooseViewFromSuperView];
}

#pragma mark - SLSearchReuseHeaderView delegate

- (void)reuseView:(ZPSearchReuseHeaderView *)view didClickedTitleButton:(UIButton *)btn{
    ZPSearchAreaItem *item = _countryFilteredResults[btn.tag - 9999];
    _previousIndex = _selectIndex;
    item.fold = !item.fold;
    _searchCity = item.fold; // 点击某个国家,如果展开就开始搜索城市,如果折叠就搜索国家
    _selectIndex = btn.tag - 9999;
    if (item.fold) {
        _searchBar.text = [NSString stringWithFormat:@"%@ / ",item.country];
    }else{
        _searchBar.text = _countrySearchString;
    }
    [_titlebtn setTitle:item.country forState:UIControlStateNormal];
    _titlebtn.tag = btn.tag;
    if(item.cityArray.count == 0){
        [self dowloadCityDataWithCountry:item];
    }else{
        [self updateSectionsWitCountry:item];
    }
}

- (void)updateSectionsWitCountry:(ZPSearchAreaItem *)item{
    if (_searchCity) {
        self.cityFilteredResults = item.cityArray;
    }
    if (item.cityArray.count == 0) {
        [_countyBtn setTitle:item.country forState:UIControlStateNormal];
        [_cityBtn   setTitle:item.country forState:UIControlStateNormal];
        if (_selectBlock != nil) {
            _selectBlock(item.country,item.country);
        }
        [self removeCityChooseViewFromSuperView];
    }
    NSMutableIndexSet *idxSet = [[NSMutableIndexSet alloc] init];
    if(_selectIndex != -1) [idxSet addIndex:_selectIndex];
    if(_previousIndex != -1) [idxSet addIndex:_previousIndex];
    //    [_countrySelectView reloadData];
    [_countrySelectView reloadSections:idxSet withRowAnimation:UITableViewRowAnimationFade];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(_countrySelectView.contentSize.height - [UIScreen mainScreen].bounds.size.width > _selectIndex * kCityCellHeight){
            [_countrySelectView setContentOffset:CGPointMake(0, _selectIndex * kCityCellHeight) animated:YES];
        }else{
            //            [_countrySelectView setContentOffset:CGPointMake(0, _countrySelectView.contentSize.height - ScreenWidth) animated:YES];
        }
    });
}

#pragma mark - private method

- (void)countryOrCityButtonDidClicked:(UIButton *)btn{
    [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardDidHideNotification object:nil];
    
    if (self.countryArray.count == 0) {
        [self dowloadCountryDataWithCountryWithButton:btn];
    }else{
        [self configSearchBarAndShowCityPickViewWithButton:btn];
    }
}

- (void)configSearchBarAndShowCityPickViewWithButton:(UIButton *)btn{
    _selectIndex = -1;
    _previousIndex = -1;
    _searchCity = NO;
    [self setUpQuickSearch];
    self.countryFilteredResults = [self.countrySearch filteredObjectsWithValue:nil];
    [self filterResults];
    [self showCityChooseView:self.countrySelectView];
    if (![btn.titleLabel.text isEqualToString:@"国家 : 点击选择"] && btn == _countyBtn) {
        
    }else if(![btn.titleLabel.text isEqualToString:@"城市 : 点击选择"] && btn == _cityBtn){
        
    }
}

- (void)titleButtonDidClicked:(UIButton *)btn{
    [_countrySelectView setContentOffset:CGPointMake(0,(btn.tag - 9999) * kCityCellHeight) animated:YES];
}

- (void)closeButtonDidClocked:(VBFPopFlatButton *)btn{
    [self removeCityChooseViewFromSuperView];
}

- (void)backGroundButtonDidClicked:(UIButton *)btn{
    [self removeCityChooseViewFromSuperView];
}

- (void)removeCityChooseViewFromSuperView
{
    [self.searchBar resignFirstResponder];
    __weak typeof(self)weakSelf = self;
    [_countrySelectView.layer sl_basicWithName:kSLLayerOpacity to:@(0.01) duration:0.5 key:@"calendarView_opacity_animation" complete:^(id obj, BOOL finish) {
        if(finish){
            [weakSelf.countrySelectView removeFromSuperview];
            [weakSelf.effectView     removeFromSuperview];
            weakSelf.countrySearchString = nil;
            weakSelf.citySearchString   = nil;
        }
    }];
    [_countrySelectView.layer sl_springWithName:kSLLayerScaleXY
                                           from:[NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)]
                                             to:[NSValue valueWithCGSize:CGSizeMake(0.6f, 0.6f)]
                                         bounce:0 speed:5 key:@"calendarView_scaleXY_animation" complete:nil];
    
    
    [_effectView.layer sl_basicWithName:kSLLayerOpacity to:@(0.01) duration:0.25 key:@"backView_opacity_animation" complete:nil];
}

- (void)showCityChooseView:(UITableView *)chooseView
{
    [_countrySelectView.layer sl_basicWithName:kSLLayerOpacity to:@(1.0) duration:0.25 key:@"calendarView_opacity_animation" complete:nil];
    
    [_countrySelectView.layer sl_springWithName:kSLLayerScaleXY
                                      from:[NSValue valueWithCGSize:CGSizeMake(0.3f, 0.3f)]
                                        to:[NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)]
                                    bounce:5 speed:10 key:@"calendarView_scaleXY_animation" complete:nil];
    
    [_effectView.layer sl_basicWithName:kSLLayerOpacity to:@(1) duration:0.25 key:@"backView_opacity_animation" complete:nil];
}

#pragma mark - >>>>>>>>>>>>>>>>>>> 搜索条 <<<<<<<<<<<<<<<<<<<

- (void)establishSearchBar
{
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    _searchBar = searchBar;
    _searchBar.frame = CGRectMake(5, 20,self.width, 44);
    _searchBar.alpha = 0.01;
    [_searchBar setContentMode:UIViewContentModeBottomLeft];
    _searchBar.delegate = self;
    _searchBar.searchBarStyle=UISearchBarStyleMinimal;
    _searchPlaceholder = [_searchPlaceholder isEqualToString:@"列表展开时搜索城市"] ? @"所有列表合并时搜索国家" : @"列表展开时搜索城市";
    _searchBar.placeholder = _searchPlaceholder;
    [_effectView addSubview:_searchBar];
    _searchBar.tintColor = [UIColor orangeColor];
    [_searchBar becomeFirstResponder];
    [self setSearchBarTextfiled:_searchBar];
    if (_selectIndex != -1) {
        ZPSearchAreaItem *item = _countryFilteredResults[_selectIndex];
        if (item.fold) {
            _searchBar.text = [NSString stringWithFormat:@"%@ / ",item.country];
        }else{
            _searchBar.text = _countrySearchString;
        }
    }
    __weak typeof(self)weakSelf = self;
    [_titlebtn.layer     sl_basicWithName:kSLLayerOpacity to:@(0.01) duration:0.5 key:@"title_button"  complete:nil];
    [_searchButton.layer sl_basicWithName:kSLLayerOpacity to:@(0.01) duration:0.5 key:@"searchbutton_" complete:nil];
    [_searchBar.layer    sl_basicWithName:kSLLayerOpacity to:@(0.9)  duration:0.5 key:@"search_bar"    complete:^(id obj, BOOL finish) {
        weakSelf.searchBar.showsCancelButton =YES;
    }];
}

- (void)setSearchBarTextfiled:(UISearchBar *)searchBar{
    for (UIView *view in searchBar.subviews){
        for (id subview in view.subviews){
            if ( [subview isKindOfClass:[UITextField class]] ){
                [(UITextField *)subview setTextColor:[UIColor orangeColor]];
                [(UITextField *)subview setFont:[UIFont systemFontOfSize:14]];
                return;
            }
        }
    }
}

- (void)configSearchBar
{
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(self.width - 31, 30, 21, 21);
    searchBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [searchBtn setBackgroundImage:[UIImage imageNamed:@"icon_search_white"] forState:UIControlStateNormal];
//    [searchBtn setBackgroundImage:[UIImage imageNamed:@"icon_search_white"] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(establishSearchBar) forControlEvents:UIControlEventTouchUpInside];
    _searchButton = searchBtn;
    [_effectView addSubview:searchBtn];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [_searchBar resignFirstResponder];
}

#pragma -mark searchBarDelegate

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    _searchCity = NO;
    
    [_titlebtn setTitle:@"请选择国家" forState:UIControlStateNormal];
    _titlebtn.tag = 9999;
    [self searchBar:_searchBar textDidChange:@""];
    __weak typeof(self)weakSelf = self;
    [_titlebtn.layer     sl_basicWithName:kSLLayerOpacity to:@(1)    duration:0.5 key:@"title_button"  complete:nil];
    [_searchButton.layer sl_basicWithName:kSLLayerOpacity to:@(1)    duration:0.5 key:@"searchbutton_" complete:nil];
    [_searchBar.layer    sl_basicWithName:kSLLayerOpacity to:@(0.01) duration:0.5 key:@"search_bar"    complete:^(id obj, BOOL finish) {
        [weakSelf.searchBar removeFromSuperview];
    }];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (_searchCity) {
//        NSString *text = searchText.copy;
        ZPSearchAreaItem *item = _countryFilteredResults[_selectIndex];
        if(_countrySearchString == nil) _countrySearchString = @"";
        self.citySearchString = [searchText stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@ / ", item.country] withString:@""];
        [self performSelector:@selector(filterResultsCity) withObject:nil afterDelay:0.07];
    }else{
        self.countrySearchString = [searchText stringByReplacingOccurrencesOfString:@" / " withString:@""];
        [self performSelector:@selector(filterResults) withObject:nil afterDelay:0.07];
    }
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (_searchCity && [text isEqualToString:@""]) {
        ZPSearchAreaItem *item = _countryFilteredResults[_selectIndex];
        return searchBar.text.length != [NSString stringWithFormat:@"%@ / ",item.country].length;
    }
    return YES;
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [_searchBar setShowsCancelButton:YES animated:YES];
}

#pragma mark - lazy loding

- (UITableView *)countrySelectView{
    if (_countrySelectView == nil) {
        UITableView *countrySelectView = [[UITableView alloc] initWithFrame:CGRectMake(20 , 65, [UIScreen mainScreen].bounds.size.width - 40, [UIScreen mainScreen].bounds.size.height - 150) style:UITableViewStyleGrouped];
        countrySelectView.delegate = self;
        countrySelectView.dataSource = self;
        countrySelectView.sectionFooterHeight = 0;
        countrySelectView.separatorStyle = UITableViewCellSeparatorStyleNone;
        countrySelectView.backgroundColor = [UIColor clearColor];
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
        effectview.frame = [UIScreen mainScreen].bounds;
        [[UIApplication sharedApplication].keyWindow addSubview:effectview];
        effectview.alpha = 0.01;
        _countrySelectView = countrySelectView;
        _effectView = effectview;
        [[UIApplication sharedApplication].keyWindow addSubview:countrySelectView];

        UIButton *titlebtn = [[UIButton alloc]initWithFrame:CGRectMake((self.width - 200) * 0.5 + 5, 30, 200, 21)];
        [titlebtn setTitle:@"请选择国家" forState:UIControlStateNormal];
        _titlebtn = titlebtn;
        titlebtn.tag = 9999;
        [titlebtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [titlebtn setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
        [titlebtn addTarget:self action:@selector(titleButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        titlebtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_effectView addSubview:titlebtn];
        
        VBFPopFlatButton *closeBtn = [[VBFPopFlatButton alloc]initWithFrame:CGRectMake(0 , 0, 30, 30)
                                                                 buttonType:buttonCloseType
                                                                buttonStyle:buttonPlainStyle
                                                      animateToInitialState:YES];
        closeBtn.center = CGPointMake(self.width * 0.5 + 5, CGRectGetMaxY(countrySelectView.frame) + 40);
        closeBtn.lineThickness = 1;
        closeBtn.tintColor = [UIColor orangeColor];
        [_effectView addSubview:closeBtn];
        [self configSearchBar];
        [closeBtn addTarget:self action:@selector(closeButtonDidClocked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _countrySelectView;
}

- (NSMutableArray *)countryArray{
    if (_countryArray == nil) {
        _countryArray = [NSMutableArray array];
    }
    return _countryArray;
}

- (NSArray *)cityFilteredResults{
    if (_cityFilteredResults == nil) {
        _cityFilteredResults = [NSArray array];
    }
    return _cityFilteredResults;
}

- (void)dealloc{
    NSLog(@"%s",__func__);
}

@end
