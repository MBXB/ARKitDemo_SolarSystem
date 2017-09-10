//
//  SCenViewVC.m
//  ARKitDemo_SolarSystem
//
//  Created by Oboe_b on 2017/9/9.
//  Copyright © 2017年 MBXB-bifujian. All rights reserved.
//

#import "SCenViewVC.h"
//导入头文件
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>
@interface SCenViewVC ()<ARSCNViewDelegate>
@property (nonatomic,strong)ARSCNView *arSCNView;
@property (nonatomic,strong)ARSession *arSession;
@property (nonatomic,strong)ARConfiguration *arSessionConfiguration;

//地球 太阳 月亮
@property(nonatomic, strong)SCNNode * sunNode;
@property(nonatomic, strong)SCNNode * moonNode;
@property(nonatomic, strong)SCNNode * earthNode;
//地球月球公转的节点
@property(nonatomic, strong)SCNNode * earthGroupNode;
@property(nonatomic, strong)SCNNode * sunHaloNode;
@end

@implementation SCenViewVC
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //创建追踪
    ARWorldTrackingConfiguration *configuration = [[ARWorldTrackingConfiguration alloc]init];
    //自适应灯光(有强光到弱光会变的平滑一些)
    _arSessionConfiguration = configuration;
    _arSessionConfiguration.lightEstimationEnabled = true;
    
    [self.arSession runWithConfiguration:configuration];
}
- (void)initNode{
    //创建节点
    _sunNode = [SCNNode new];
    _earthNode = [SCNNode new];
    _moonNode = [SCNNode new];
    _earthGroupNode = [SCNNode new];
    //确定节点几几何
    _sunNode.geometry = [SCNSphere sphereWithRadius:3];
    _earthNode.geometry = [SCNSphere sphereWithRadius:1.0];
    _moonNode.geometry = [SCNSphere sphereWithRadius:0.5];
    //渲染图片
    //multiply-->整张图片拉伸之后会变淡
    //diffuse-->扩散到整个全局
    //两个属性全部都渲染的,轮廓更深,更真实一点
    _sunNode.geometry.firstMaterial.multiply.contents = @"sun";
    _sunNode.geometry.firstMaterial.diffuse.contents = @"sun";
    //intensity强度
    _sunNode.geometry.firstMaterial.multiply.intensity = 0.5;
    //地球
    _earthNode.geometry.firstMaterial.diffuse.contents = @"earth-diffuse";
    //夜光
    _earthNode.geometry.firstMaterial.emission.contents = @"earth-emissive-mini";
    //镜面
    _earthNode.geometry.firstMaterial.specular.contents = @"earth-specular-mini";
    _moonNode.geometry.firstMaterial.diffuse.contents = @"moon";
    //设置光源
    _sunNode.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
    //wrapS-->从左到右//wrapT-->从上到下
    _sunNode.geometry.firstMaterial.multiply.wrapS =
    _sunNode.geometry.firstMaterial.diffuse.wrapS =
    _sunNode.geometry.firstMaterial.multiply.wrapT =
    _sunNode.geometry.firstMaterial.diffuse.wrapT = SCNWrapModeRepeat;
    //太阳照到地球上的光泽,反光度,地球反光度
    _earthNode.geometry.firstMaterial.shininess = 0.1; // 光泽
    _earthNode.geometry.firstMaterial.specular.intensity = 0.5; // 反射多少光出去
    _moonNode.geometry.firstMaterial.specular.contents = [UIColor redColor];//反射出去的光是什么光

    //设置节点位置
    _sunNode.position = SCNVector3Make(0, 5, -20);//太阳
    _earthNode.position = SCNVector3Make(3, 0, 0);//地球
    _moonNode.position = SCNVector3Make(6, 0, 0);//月亮
    [_earthGroupNode addChildNode:_earthNode];
    _earthGroupNode.position = SCNVector3Make(10, 0, 0);
    //设置根节点
    [self.arSCNView.scene.rootNode addChildNode:_sunNode];
//    [self.arSCNView.scene.rootNode addChildNode:_earthGroupNode];
    [self addAnimationToSun];
    [self roationNode];
    [self addLight];
}

//公转
- (void)roationNode{
    [_earthNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];
    SCNNode *moonRotationNode = [SCNNode node];
    [moonRotationNode addChildNode:_moonNode];
    //添加动画--自传-->第一步
    CABasicAnimation *moonAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    moonAnimation.duration = 1.5;
    moonAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    moonAnimation.repeatCount = FLT_MAX;
    [_moonNode addAnimation:moonAnimation forKey:@"moon rotation"];
    //公转
    CABasicAnimation *moonRotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    moonRotationAnimation.duration = 5.0;
    moonRotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    moonRotationAnimation.repeatCount = FLT_MAX;
    [moonRotationNode addAnimation:moonRotationAnimation forKey:@"moon rotation around earth"];
    [_earthGroupNode addChildNode:moonRotationNode];

    
    //添加节点地球绕太阳的节点-黄道
    SCNNode *earthRotationNode = [SCNNode node];
    [_sunNode addChildNode:earthRotationNode];
    [earthRotationNode addChildNode:_earthGroupNode];//地月节点添加到
    [_earthGroupNode addChildNode:moonRotationNode];
    moonAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    moonAnimation.duration = 10.0;
    moonAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    moonAnimation.repeatCount = FLT_MAX;
    [earthRotationNode addAnimation:moonAnimation forKey:@"earth rotation around sun"];
    
}
//太阳自传
- (void)addAnimationToSun{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"contentsTransform"];
    animation.duration = 10.0;
    //从000的位置扩展//此时图片在不断的拉伸
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(0, 0, 0), CATransform3DMakeScale(3, 3, 3))];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(1, 0, 0), CATransform3DMakeScale(5, 5, 5))];
    animation.repeatCount = FLT_MAX;
    [_sunNode.geometry.firstMaterial.diffuse addAnimation:animation forKey:@"sun-texture"];
}

- (void)addLight{
    SCNNode * lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.color = [UIColor redColor];
    //SCNLightTypeOmni
    lightNode.light.type = SCNLightTypeOmni;
    [_sunNode addChildNode:lightNode];
    //随距离而改变
    lightNode.light.attenuationEndDistance = 20.0;
    lightNode.light.attenuationStartDistance = 1.0;
    
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1];
    {
        
        lightNode.light.color = [UIColor whiteColor]; // switch on
        _sunHaloNode.opacity = 0.5; // make the halo stronger
    }
    [SCNTransaction commit];
    
    _sunHaloNode = [SCNNode node];
    _sunHaloNode.geometry = [SCNPlane planeWithWidth:25 height:25];
    _sunHaloNode.rotation = SCNVector4Make(1, 0, 0, 0 * M_PI / 180.0);
    _sunHaloNode.geometry.firstMaterial.diffuse.contents = @"sun-halo";
    _sunHaloNode.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant; // 不发光
    _sunHaloNode.geometry.firstMaterial.writesToDepthBuffer = NO; //厚度取消
    _sunHaloNode.opacity = 0.9;
    [_sunNode addChildNode:_sunHaloNode];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //初始化AR环境
    [self.view addSubview:self.arSCNView];
    self.arSCNView.delegate = self;
}
//懒加载
- (ARSession *)arSession{
    if(_arSession == nil)
    {
        _arSession = [[ARSession alloc] init];
    }
    return _arSession;
}
- (ARSCNView *)arSCNView
{
    if (_arSCNView == nil) {
        _arSCNView = [[ARSCNView alloc] initWithFrame:self.view.bounds];
        _arSCNView.session = self.arSession;
        _arSCNView.automaticallyUpdatesLighting = YES;
        [self initNode];
    }

    return _arSCNView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
