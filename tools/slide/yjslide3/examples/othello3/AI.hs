{-# Language TupleSections #-}

module AI (aiN) where

import Control.Applicative ((<$>))
import Control.Arrow (first, second)
import Data.List (partition, maximumBy)
import Data.Function (on)

import Game
import Tools

ai0 :: Game -> Maybe ((X, Y), Int)
ai0 g	| null $ putable g = Nothing
	| otherwise = Just $ maximumBy (on compare snd) $
		map (\pos -> (pos, calc g $ stone $ turn g)) $ putable g

aiN :: Int -> Game -> Maybe ((X, Y), Int)
aiN 0 g = ai0 g
aiN n g = do
	rets <- do
		allPair <- mapM (\pos -> (pos ,) <$> nextGame g pos) $ putable g
		p <- flip mapM allPair $ \(pos, ng) -> case turn ng of
			GameOver -> return (pos, (undefined, calc g (rev $ stone $ turn g)))
			_ -> (pos ,) <$> aiN (n - 1) ng
		return $ map (\(pos, (_, pnt)) -> (pos, negate pnt)) p
	return $ maximumBy (on compare snd) rets

----------------------------------------------------------------------
-- calc :: Game -> Stone -> Int

calc :: Game -> Stone -> Int
calc g s
	| t < 32 = sumPoint map1 me - sumPoint map1 you
	| t < 63 = sumPoint map2 me - sumPoint map2 you
	| otherwise = sumPoint map3 me - sumPoint map3 you
	where
	sumPoint m = sum . map (getPoint m . fst)
	t = length $ stones g
	(me, you) = partition ((== s) . snd) $ stones g

type Map = [((X, Y), Int)]

flipXY, flipX, flipY :: (X, Y) -> (X, Y)
flipXY (x, y) = (toEnum $ fromEnum y, toEnum $ fromEnum x)
flipX = first flipE
flipY = second flipE

getPoint :: Map -> (X, Y) -> Int
getPoint m pos@(x, y)
	| x > D = getPoint m $ flipX pos
	| y > Y4 = getPoint m $ flipY pos
	| fromEnum x < fromEnum y = getPoint m $ flipXY pos
getPoint m pos = case lookup pos m of
	Just p -> p
	_ -> error "bad map"

map3 :: Map
map3 = [
	((A, Y1), 1),
	((B, Y1), 1),
	((B, Y2), 1),
	((C, Y1), 1),
	((C, Y2), 1),
	((C, Y3), 1),
	((D, Y1), 1),
	((D, Y2), 1),
	((D, Y3), 1),
	((D, Y4), 1)
 ]

map2 :: Map
map2 = [
	((A, Y1), 120),
	((B, Y1), -20),
	((B, Y2), -40),
	((C, Y1), 20),
	((C, Y2), -5),
	((C, Y3), 15),
	((D, Y1), 5),
	((D, Y2), -5),
	((D, Y3), 3),
	((D, Y4), 3)
 ]

map1 :: Map
map1 = [
	((A, Y1), 30),
	((B, Y1), -12),
	((B, Y2), -15),
	((C, Y1), 0),
	((C, Y2), -3),
	((C, Y3), 0),
	((D, Y1), -1),
	((D, Y2), -3),
	((D, Y3), -1),
	((D, Y4), -1)
 ]
