//
//  MainGameLayer.m
//  Cocos2DSimpleGame
//
//  Created by van nguyen on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainGameLayer.h"
#import "HelloWorldLayer.h"

@implementation MainGameLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainGameLayer *layer = [MainGameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id) init
{
    if (self = [super initWithColor:ccc4(255, 255, 255, 255)]) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CCSprite *player = [CCSprite spriteWithFile:@"player.png" rect:CGRectMake(0, 0, 27, 40)];
        
//        player.position = ccp(player.contentSize.width/2, winSize.height/2);
        player.position = ccp(winSize.width/2, player.contentSize.height/2);
        [self addChild:player];
    }
    [self schedule:@selector(gameLogic:) interval:1.0];
    self.isTouchEnabled = YES;
    return self;
}

-(void) addTarget
{
    CCSprite *target = [CCSprite spriteWithFile:@"Target.png" rect:CGRectMake(0, 0, 27, 40)];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
//    int minY = target.contentSize.height/2;
//    int maxY = winSize.height - target.contentSize.height/2;
//    int rangeY = maxY - minY;
//    int actualY = (arc4random() % rangeY) +minY;
    
    int minX = target.contentSize.width/2;
    int maxX = winSize.width - target.contentSize.width/2;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) +minX;
    
    target.position = ccp(actualX, winSize.height + (target.contentSize.height/2));
    [self addChild:target];
    
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    id actionMove = [CCMoveTo actionWithDuration:actualDuration position:ccp(actualX, -target.contentSize.height/2)];
    id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)];
    [target runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
    
}

-(void)spriteMoveFinished:(id)sender
{
    CCSprite *sprite = (CCSprite *) sender;
    [self removeChild:sprite cleanup:YES];
}

-(void)gameLogic:(ccTime)dt {
    [self addTarget];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    // Set up initial location of projectile
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCSprite *projectile = [CCSprite spriteWithFile:@"Projectile.png" 
                                               rect:CGRectMake(0, 0, 20, 20)];
    projectile.position = ccp(winSize.width/2, 40);
    
    // Determine offset of location to projectile
    int offX = location.x - projectile.position.x;
    int offY = location.y - projectile.position.y;
    
    // Bail out if we are shooting down or backwards
    if (offY <= 0) return;
    
    // Ok to add now - we've double checked position
    [self addChild:projectile];
    
    // Determine where we wish to shoot the projectile to
//    int realX = winSize.width + (projectile.contentSize.width/2);
//    float ratio = (float) offY / (float) offX;
//    int realY = (realX * ratio) + projectile.position.y;
//    CGPoint realDest = ccp(realX, realY);
    float ratio = (float) offX / (float) offY;
    int realY = winSize.height + (projectile.contentSize.height/2);
    int realX = (realY * ratio) + projectile.position.x;
    CGPoint realDest = ccp(realX, realY);
    
    // Determine the length of how far we're shooting
    int offRealX = realX - projectile.position.x;
    int offRealY = realY - projectile.position.y;
    float length = sqrtf((offRealX*offRealX)+(offRealY*offRealY));
    float velocity = 480/1; // 480pixels/1sec
    float realMoveDuration = length/velocity;
    
    // Move projectile to actual endpoint
    [projectile runAction:[CCSequence actions:
                           [CCMoveTo actionWithDuration:realMoveDuration position:realDest],
                           [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
                           nil]];
    
}

@end
