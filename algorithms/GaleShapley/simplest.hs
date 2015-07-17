{-# LANGUAGE TupleSections #-}

import Control.Applicative
import Control.Arrow
import Data.Maybe
import Data.List

data Man = A | B | C | D deriving (Show, Eq, Ord)
data Woman = X | Y | Z | W deriving (Show, Eq, Ord)

manT :: Table Man Woman
manT = [
	(A, [Y, X, Z, W]), (B, [X, W, Y, Z]),
	(C, [Y, X, Z, W]), (D, [W, Z, Y, X]) ]

womanT :: Table Woman Man
womanT = [
	(X, [C, D, B, A]), (Y, [D, B, A, C]),
	(Z, [A, C, B, D]), (W, [C, B, A, D]) ]

main :: IO ()
main = print . sort $ pairs manT womanT

type Table m w = [(m, [w])]
type TableR w m = [((w, m), Int)]
type Pair w m = (w, (m, Int))
type State m w = (Table m w, [Pair w m])

pairs :: (Eq m, Eq w) => Table m w -> Table w m -> [(m, w)]
pairs mt wt = map ((\(w, m) -> (m, w)) . second fst)
	. snd $ run (uncurry . step $ rtable wt) (mt, [])
	where run n s = maybe s (run n) $ n s

step :: (Eq m, Eq w) => TableR w m -> Table m w -> [Pair w m] -> Maybe (State m w)
step wr mt ps = (<$> single mt ps) $ \((m, w : ws), r) -> let
	p = fromJust $ lookup (w, m) wr in
	((m, ws) : r ,) $ case first (map snd) $ partition ((== w) . fst) ps of
		([(_, p')], ps') | p > p' -> (w, (m, p)) : ps' | True -> ps
		_ -> (w, (m, p)) : ps

rtable :: Table w m -> TableR w m
rtable = concatMap rt
	where rt (w, ms) = zipWith (\m p -> ((w, m), p)) ms [4, 3, 2, 1]

single :: Eq m => Table m w -> [Pair w m] -> Maybe ((m, [w]), Table m w)
single [] _ = Nothing
single (mp@(m, _) : mps) ps
	| m `notElem` map (fst . snd) ps = Just (mp, mps)
	| True = second (mp :) <$> single mps ps
