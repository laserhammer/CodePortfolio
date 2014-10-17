//
//  GameModel.m
//  BCR_Blackjack
//
//  Created by Ben on 9/21/14.
//  Copyright (c) 2014 Ben. All rights reserved.
//

#import "GameModel.h"
#import "HandOfCards.h"

@implementation GameModel
{
    // privat ivars
    NSMutableArray *_cards;
    HandOfCards *_playerHand;
    HandOfCards *_dealerHand;
    BOOL _didDealerWin;
    
    int _score;
    NSString *_status;
    int _currentRound;
}

-(GameModel *)init
{
    self = [super init];
    if(self)
    {
        _playerHand = [[HandOfCards alloc] init];
        _dealerHand = [[HandOfCards alloc] init];
    }
    return self;
}

-(void) initGame
{
    _cards = [PlayingCard createDeck];
    [self shuffle:_cards];
    _currentRound = 0;
    [self notifyRoundChange];
    _score = kSTART_SCORE;
    [self notifyScoreChange];
    [self setStatus:@""];
}

// Private

-(PlayingCard *)nextCard
{
    PlayingCard *card = _cards[0];
    [_cards removeObjectAtIndex:0];
    return card;
}

#pragma mark - Helper Methods
-(NSMutableArray *)shuffle:(NSMutableArray *)array
{
    int i, randomPosition;
    int numElements = (int)[array count];
    id tempElement;
    
    for (i = 0; i < numElements; ++i)
    {
        randomPosition = arc4random_uniform(numElements);
        tempElement = array[i];
        array[i] = array[randomPosition];
        array[randomPosition] = tempElement;
    }
    
    return array;
}

-(PlayingCard *) drawDealerCard
{
    [self notifyPlaySound:kSoundDraw];
    PlayingCard *card = [self nextCard];
    [_dealerHand addCard:card];
    return card;
}
-(PlayingCard *) drawPlayerCard
{
    [self notifyPlaySound:kSoundDraw];
    PlayingCard *card = [self nextCard];
    [_playerHand addCard:card];
    [self setStatus:[self playerHandValueString]];
    return card;
}

-(PlayingCard *) lastDealerCard
{
    return [_dealerHand lastCard];
}
-(PlayingCard *) lastPlayerCard
{
    return [_playerHand lastCard];
}
-(PlayingCard *) playerCardAtIndex: (int) index
{
    return [_playerHand cardAtIndex:index];
}
-(PlayingCard *) dealerCardAtIndex: (int) index
{
    return [_dealerHand cardAtIndex:index];
}

-(void) dealNewHand
{
    [self incrementRound];
    [self setStatus:@""];
    [_playerHand clearHand];
    [_dealerHand clearHand];
    self.gameStage = kGameStagePlayer;
}

-(void) updateGameStage
{
    if (_gameStage == kGameStagePlayer)
    {
        if ([_playerHand areCardsBust])
        {
            _didDealerWin = YES;
            [self setStatus:@"Bust!"];
            [self roundOver];
            return;
        }
        else if ([_playerHand count] == kMAX_PLAYER_CARDS)
        {
            _gameStage = kGameStageDealer;
        }
        
        return;
    }
    
    if (_gameStage == kGameStageDealer)
    {
        if ([_dealerHand areCardsBust])
        {
            _didDealerWin = NO;
            [self setStatus:@"Dealer Busts!"];
            [self roundOver];
        }
        else if ([_dealerHand count] == kMAX_PLAYER_CARDS)
        {
            [self calculateWinner];
            [self roundOver];
        }
        else
        {
            int dealerScore = [_dealerHand calculateBestScore];
            if (dealerScore >= 17)
            {
                int playerScore = [_playerHand calculateBestScore];
                
                if (playerScore > dealerScore)
                {
                    //dealer must play again as he's not equal or
                    //better than the player's score
                    //keep playing, dealer will play another card
                }
                else
                {
                    //dealer has equaled or beaten the play so the
                    //game is over
                    _didDealerWin = YES;
                    [self setStatus:@"You Lose!"];
                    [self roundOver];
                }
            }
        }
    }
}

-(void)roundOver
{
    self.gameStage = kGameStageGameOver;
    _score += _didDealerWin ? -kBET:kBET;
    _didDealerWin ? [self notifyPlaySound:kSoundLose]:[self notifyPlaySound:kSoundWin];
    [self notifyScoreChange];
    [self notifyRoundDidEnd];
}

-(NSString *)playerHandValueString
{
    int hand = [_playerHand calculateBestScore];
    return [NSString stringWithFormat:@"%d", hand];
}

-(void)setStatus:(NSString *) status
{
    _status = status;
    [self notifyStatusChange];
}

-(void)incrementRound
{
    ++_currentRound;
    [self notifyRoundChange];
}

#pragma mark - Private methods
-(void)calculateWinner
{
    int dealerScore = [_dealerHand calculateBestScore];
    int playerScore = [_dealerHand calculateBestScore];
    
    _didDealerWin = (playerScore > dealerScore) ? NO : YES;
    if(playerScore > dealerScore)
    {
        _didDealerWin = NO;
        [self setStatus:@"You Win!"];
    }
    else
    {
        _didDealerWin = YES;
        [self setStatus:@"You Lose!"];
    }
}

-(void)notifyScoreChange
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    NSNumber *score = @(_score);
    
    NSDictionary *dict = @{@"score": score};
    
    [notificationCenter postNotificationName:kNotificationScoreChange object:self userInfo:dict];
}

-(void)notifyStatusChange
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    NSDictionary *dict = @{@"status": _status};
    
    [notificationCenter postNotificationName:kNotificationStatusChange object:self userInfo:dict];
}

-(void)notifyRoundChange
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    NSNumber *round = @(_currentRound);
    
    NSDictionary *dict = @{@"round": round};
    
    [notificationCenter postNotificationName:kNotificationRoundChange object:self userInfo:dict];
}

-(void)notifyRoundDidEnd
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    NSNumber *round = [NSNumber numberWithInt:_currentRound];
    NSNumber *score = [NSNumber numberWithInt:_score];
    
    NSDictionary *dict = @{@"round": round, @"score": score};
    
    [notificationCenter postNotificationName:kNotificationRoundDidEnd object:self userInfo:dict];
}

-(void)notifyPlaySound:(kSoundType) soundType
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    switch (soundType)
    {
        case kSoundDraw:
            [notificationCenter postNotificationName:kNotificationPlaySoundDraw object:self];
            break;
        case kSoundWin:
            [notificationCenter postNotificationName:kNotificationPlaySoundWin object:self];
            break;
        case kSoundLose:
            [notificationCenter postNotificationName:kNotificationPlaySoundLose object:self];
            break;
    }
}

-(NSString *) description
{
    NSMutableString *s = [NSMutableString string];
    [s appendFormat: @"Dealer Cards = %@", _dealerHand];
    [s appendFormat: @"Player Cards = %@",  _dealerHand];
    [s appendFormat: @"Game Stage = %d",    self.gameStage];
    
    return s;
}
@end
