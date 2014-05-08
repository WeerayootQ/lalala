//
//  CalendarViewController.m
//  ParseStarterProject
//
//  Created by Q on 4/18/14.
//
//

#import "CalendarViewController.h"
#import "CALAgendaViewController.h"
#import "NSDate+Agenda.h"
#import "NSDate+ETI.h"
#import "CALAgenda.h"
#import "JMOEvent.h"

@interface CalendarViewController () <UICollectionViewDelegate, CALAgendaCollectionViewDelegate>
@property (nonatomic, strong) CALAgendaViewController *agendaVc;
@property (nonatomic, strong) JMOEvent *event;

@end

@implementation CalendarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.agendaVc = [CALAgendaViewController new];
//    self.agendaVc.calendarScrollDirection = UICollectionViewScrollDirectionHorizontal;
//    self.agendaVc.agendaDelegate = self;
//    NSDateComponents *components = [NSDateComponents new];
//    components.month = 1;
//    components.day = 1;
//    components.year = 2014;
//    NSDate *fromDate = [[NSDate gregorianCalendar] dateFromComponents:components];
//    components.month = 3;
//    components.day = 1;
//    NSDate *toDate = [[NSDate gregorianCalendar] dateFromComponents:components];
//    [self.agendaVc setFromDate:fromDate];
//    [self.agendaVc setToDate:toDate];
//    
//    self.agendaVc.events = [self fakeEvents];
//    self.agendaVc.dayStyle = CALDayCollectionViewCellDayUIStyleIOS7;
//    [self.navigationController pushViewController:self.agendaVc animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s",__FUNCTION__);
}

- (IBAction)showMyCalendariOS7Vertical:(id)sender
{
    [self showMyCalendarWithScrollDirection:UICollectionViewScrollDirectionVertical];
}

- (IBAction)showMyCalendariOS7Horizontal:(id)sender
{
    [self showMyCalendarWithScrollDirection:UICollectionViewScrollDirectionHorizontal];
}

- (void)showMyCalendarWithScrollDirection:(UICollectionViewScrollDirection)direction
{
    self.agendaVc = [CALAgendaViewController new];
    self.agendaVc.calendarScrollDirection = direction;
    self.agendaVc.agendaDelegate = self;
    NSDateComponents *components = [NSDateComponents new];
    components.month = 1;
    components.day = 1;
    components.year = 2014;
    NSDate *fromDate = [[NSDate gregorianCalendar] dateFromComponents:components];
    components.month = 3;
    components.day = 1;
    NSDate *toDate = [[NSDate gregorianCalendar] dateFromComponents:components];
    [self.agendaVc setFromDate:fromDate];
    [self.agendaVc setToDate:toDate];
    
    self.agendaVc.events = [self fakeEvents];
    self.agendaVc.dayStyle = CALDayCollectionViewCellDayUIStyleIOS7;
    [self.navigationController pushViewController:self.agendaVc animated:NO];
}


- (IBAction)showMyCalendarStyleCustom:(id)sender
{
    self.agendaVc = [CALAgendaViewController new];
    self.agendaVc.agendaDelegate = self;
    NSDateComponents *components = [NSDateComponents new];
    components.month = 1;
    components.year = 2014;
    components.day = 1;
    NSDate *fromDate = [[NSDate gregorianCalendar] dateFromComponents:components];
    components.month = 3;
    components.day = 1;
    NSDate *toDate = [[NSDate gregorianCalendar] dateFromComponents:components];
    [self.agendaVc setFromDate:fromDate];
    [self.agendaVc setToDate:toDate];
    
    self.agendaVc.events = [self fakeEvents];
    self.agendaVc.dayStyle = CALDayCollectionViewCellDayUIStyleCustom1;
    [self.navigationController pushViewController:self.agendaVc animated:YES];
}

#pragma mark - helpers
- (NSArray *)fakeEvents
{
    NSDate *now = [[NSDate gregorianCalendar] dateFromComponents:[[NSDate gregorianCalendar]  components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:[NSDate date]]];
    NSDateComponents *components = [NSDateComponents new];
    components.month = -3;
    
    JMOEvent *event1 = [JMOEvent new];
    components.day = 3;
    components.month = 0;
    components.hour = 11;
    event1.startDate = [[NSDate gregorianCalendar] dateByAddingComponents:components toDate:now options:0];
    components.month = 0;
    components.day = 3;
    components.hour = 12;
    event1.endDate = [[NSDate gregorianCalendar] dateByAddingComponents:components toDate:now options:0];
    
    JMOEvent *event2 = [JMOEvent new];
    components.day = 2;
    components.month = 1;
    components.hour = 11;
    event2.startDate = [[NSDate gregorianCalendar] dateByAddingComponents:components toDate:now options:0];
    components.month = 1;
    components.day = 2;
    components.hour = 12;
    event2.endDate = [[NSDate gregorianCalendar] dateByAddingComponents:components toDate:now options:0];
    
    JMOEvent *event3 = [JMOEvent new];
    components.day = 1;
    components.month = -3;
    components.hour = 11;
    event3.startDate = [[NSDate gregorianCalendar] dateByAddingComponents:components toDate:now options:0];
    components.day = 1;
    components.month = -3;
    components.hour = 12;
    event3.endDate = [[NSDate gregorianCalendar] dateByAddingComponents:components toDate:now options:0];
    
    JMOEvent *event4 = [JMOEvent new];
    components.day = 2;
    components.month = -3;
    components.hour = 11;
    event4.startDate = [[NSDate gregorianCalendar] dateByAddingComponents:components toDate:now options:0];
    components.day = 2;
    components.month = -3;
    components.hour = 19;
    event4.endDate = [[NSDate gregorianCalendar] dateByAddingComponents:components toDate:now options:0];
    return @[event1, event2,event3, event4];
}


#pragma mark - CALAgendaCollectionViewDelegate

- (void)agendaCollectionView:(CALAgendaCollectionView *)agendaCollectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath selectedDate:(NSDate *)selectedDate
{
    NSLog(@"%s %@", __FUNCTION__, selectedDate);
}

- (BOOL)agendaCollectionView:(CALAgendaCollectionView *)agendaCollectionView canSelectDate:(NSDate *)selectedDate
{
    return YES;
}

- (void)agendaCollectionView:(CALAgendaCollectionView *)agendaCollectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath startDate:(NSDate *)startDate endDate:(NSDate *)endDate
{
    NSLog(@"%s %@ -> %@", __FUNCTION__,startDate, endDate);
    if (nil != startDate && nil != endDate) {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Continuer" style:UIBarButtonItemStyleBordered target:self action:nil];
        [[self.agendaVc navigationItem] setRightBarButtonItem:button animated:YES];
    }
    else {
        [[self.agendaVc navigationItem] setRightBarButtonItem:nil animated:YES];
    }
}


@end
