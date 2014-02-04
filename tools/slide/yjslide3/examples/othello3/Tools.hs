module Tools (
	scc, prd, maybeToEnum,
	foldlMaybe, modifyList, flipE, const2, maximumBySnd, forMaybe,
) where

import Data.Maybe (mapMaybe)
import Data.List (maximumBy)
import Data.Function (on)

scc, prd :: (Ord a, Enum a, Bounded a) => a -> Maybe a
scc x	| x < maxBound = Just $ succ x
	| otherwise = Nothing
prd x	| x > minBound = Just $ pred x
	| otherwise = Nothing

maybeToEnum :: (Ord a, Enum a, Bounded a) => Int -> Maybe a
maybeToEnum n
	| n > fromEnum (maxBound `asTypeOf` ret) ||
		n < fromEnum (minBound `asTypeOf` ret) = Nothing
	| otherwise = Just ret
	where ret = toEnum n

foldlMaybe :: (a -> b -> Maybe a) -> a -> [b] -> Maybe a
foldlMaybe = foldlMaybeBool False

foldlMaybeBool :: Bool -> (a -> b -> Maybe a) -> a -> [b] -> Maybe a
foldlMaybeBool True _ x [] = Just x
foldlMaybeBool False _ _ [] = Nothing
foldlMaybeBool j op x (y : ys) = case x `op` y of
	Just x' -> foldlMaybeBool True op x' ys
	_ -> foldlMaybeBool j op x ys

modifyList :: [a] -> Int -> (a -> a) -> [a]
modifyList xs n f = take n xs ++ [f $ xs !! n] ++ drop (n + 1) xs

flipE :: (Enum a, Bounded a) => a -> a
flipE x = toEnum $ fromEnum (maxBound `asTypeOf` x) - fromEnum x

const2 :: a -> b -> c -> a
const2 x _ = const x

maximumBySnd :: Ord b => [(a, b)] -> (a, b)
maximumBySnd = maximumBy $ on compare snd

forMaybe :: [a] -> (a -> Maybe b) -> [b]
forMaybe = flip mapMaybe
