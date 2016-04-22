import Control.Applicative (Alternative(..))
import Control.Monad (MonadPlus, guard, foldM)

data Event = E Enemy | I Item deriving Show
data Enemy = Ghost | Troll | Vampire deriving Show
data Item = Shell | Coin | Jewel | Star deriving Show
type Yoshio = (Integer, Integer)

damage :: Enemy -> Integer
damage Ghost = 10
damage Troll = 50
damage Vampire = 100

score :: Item -> Integer
score Shell = 50
score Coin = 100
score Jewel = 500
score Star = 1000

event :: MonadPlus m => Yoshio -> Event -> m Yoshio
event (hp, s) (E e) = do
	let hp' = hp - damage e
	guard $ hp' > 0
	return (hp', s)
event (hp, s) (I i) = return (hp, s + score i)

game :: MonadPlus m => Yoshio -> [Event] -> m Yoshio
game = foldM event

alternatives :: Alternative f => [f a] -> f a
alternatives (x : xs) = x <|> alternatives xs
alternatives _ = empty

stage1, stage2 :: [Event]
stage1 = [E Ghost, I Shell, I Star, I Coin, E Troll, I Coin, E Vampire]
stage2 = [E Vampire, E Vampire, I Star, I Star, I Star, I Coin, I Star]
