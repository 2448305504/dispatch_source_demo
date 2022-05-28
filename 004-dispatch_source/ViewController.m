#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *iBt;
@property (weak, nonatomic) IBOutlet UIProgressView *iProgress;
@property (nonatomic, strong) dispatch_source_t source;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, assign) NSUInteger totalComplete;
@property (nonatomic ,assign) int iNum;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.totalComplete = 0;
    self.queue = dispatch_queue_create("lg", DISPATCH_QUEUE_SERIAL);
    self.source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_event_handler(self.source, ^{
        NSUInteger value = dispatch_source_get_data(self.source); // 每次去获取iNum的值
        self.totalComplete += value;
        NSLog(@"进度: %.2f",self.totalComplete/100.0);
        self.iProgress.progress = self.totalComplete/100.0;
    });
    
//    [self iTimer];
}

- (IBAction)btClick:(id)sender {
    if ([self.iBt.titleLabel.text isEqualToString:@"开始"]) {
        dispatch_resume(self.source);
        NSLog(@"开始了");
        self.iNum = 1;
        [sender setTitle:@"暂停" forState:UIControlStateNormal];
        
        for (int i= 0; i<1000; i++) {
            dispatch_async(self.queue, ^{
                sleep(1);
                dispatch_source_merge_data(self.source, self.iNum); // 传递iNum触发hander
            });
        }
    } else {
        dispatch_suspend(self.source);
        NSLog(@"暂停了");
        self.iNum = 0;
        [sender setTitle:@"开始" forState:UIControlStateNormal];
    }
}

// 倒计时
- (void)iTimer {
    __block int timeout = 60;
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout <= 0) {
            dispatch_source_cancel(_timer);
        } else {
            timeout--;
            NSLog(@"倒计时:%d", timeout);
        }
    });
    dispatch_resume(_timer);
}

@end
