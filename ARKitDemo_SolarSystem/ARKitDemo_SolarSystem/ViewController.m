//
//  ViewController.m
//  ARKitDemo_SolarSystem
//
//  Created by Oboe_b on 2017/9/9.
//  Copyright © 2017年 MBXB-bifujian. All rights reserved.
//

#import "ViewController.h"
#import "SCenViewVC.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *arWorld;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)arWorldClick:(id)sender {
    SCenViewVC *vc = [[SCenViewVC alloc]init];
    [self presentViewController:vc animated:true completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
