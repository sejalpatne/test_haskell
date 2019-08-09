{-# LANGUAGE TupleSections, TypeFamilies, TypeApplications #-}
{-# OPTIONS_GHC -Wall -fno-warn-tabs #-}

module Circuit.Diagram.DiagramMap where

import Prelude as P

import Data.Map.Strict

data DiagramMap = DiagramMap { width :: Int, height :: Int, layout :: Map Pos Element } deriving Show

getWidthDiagramMap, getHeightDiagramMap :: DiagramMap -> Int
getWidthDiagramMap = width
getHeightDiagramMap = height

setWidthDiagramMap, setHeightDiagramMap :: DiagramMap -> Int -> DiagramMap
setWidthDiagramMap d w = d { width = w }
setHeightDiagramMap d h = d { height = h }

data Pos = Pos { posX :: Int, posY :: Int } deriving (Show, Eq, Ord)

mkDiagramMap :: Int -> Int -> DiagramMap
mkDiagramMap w h = DiagramMap { width = w, height = h, layout = empty }

data Element
	= Stump
	| AndGateE | OrGateE | NotGateE
	| BranchE
	| HLine | VLine
	| TopLeft | TopRight | BottomLeft | BottomRight
	| EndHLine | EndHLineR | EndTopLeft
	| EndBottomLeft
	| TShape | TInverted | TLeft | TRight | CrossDot | Cross
	| HLineText String String
	deriving Show

stump :: Element -> Pos -> Map Pos Element -> Map Pos Element
stump e p m = P.foldr (flip insert Stump) m
	[ Pos x y |
		x <- [x0 .. x0 + w - 1],
		y <- [y0 - h' .. y0 + h''],
		(x, y) /= (x0, y0) ]
	where
	(w, h) = elementSpace e
	h' = (h - 1) `div` 2
	h'' = h `div` 2
	(x0, y0) = (posX p, posY p)

elementSpace :: Element -> (Int, Int)
elementSpace AndGateE = (3, 3)
elementSpace OrGateE = (3, 3)
elementSpace NotGateE = (2, 3)
elementSpace BranchE = (1, 2)
elementSpace _ = (1, 1)

elementToPositions :: Element -> Pos -> [Pos]
elementToPositions e (Pos x0 y0) = [ Pos x y |
	x <- [x0 .. x0 + w - 1],
	y <- [y0 - h' .. y0 + h'] ]
	where
	(w, h) = elementSpace e
	h' = (h - 1) `div` 2

posToLine :: Dir -> [Pos] -> Either String [Element]
posToLine _ [] = Right []
posToLine d [_] = (: []) <$> dirToLine' d L
posToLine d (x : xs@(y : _)) = do
	d' <- dir x y; (:) <$> dirToLine d d' <*> posToLine d' xs

insertLine :: [Pos] -> Map Pos Element -> Either String (Map Pos Element)
insertLine ps m =
	P.foldr (uncurry overlapInsertLine) m . zip ps <$> posToLine L ps

overlapInsertLine :: Pos -> Element -> Map Pos Element -> Map Pos Element
overlapInsertLine pos ln m = case m !? pos of
	Just ln' -> insert pos (overlapLine ln' ln) m
	Nothing -> insert pos ln m

overlapLine :: Element -> Element -> Element
overlapLine HLine EndBottomLeft = TShape
overlapLine EndHLine EndBottomLeft = TShape
overlapLine VLine HLine = Cross
overlapLine VLine EndHLine = TLeft
overlapLine VLine EndHLineR = TRight
overlapLine HLine TopLeft = TInverted
overlapLine BottomRight EndHLineR = TShape
overlapLine BottomRight TopLeft = CrossDot
overlapLine HLine BottomRight = TShape
overlapLine HLine EndTopLeft = TInverted
overlapLine BottomRight EndTopLeft = TLeft
overlapLine EndBottomLeft EndHLine = TShape
overlapLine BottomLeft EndHLine = TShape
overlapLine TopRight EndHLine = TInverted
overlapLine BottomRight EndBottomLeft = TShape
overlapLine HLine VLine = Cross
overlapLine EndHLine VLine = CrossDot
overlapLine ln ln' = error
	$ "Circut.Diagram.Map.overlapLine: not yet implemented: overlapLine " ++
		show ln ++ " " ++ show ln'

data Dir = T | B | L | R deriving Show

dir :: Pos -> Pos -> Either String Dir
dir p1@(Pos x y) p2@(Pos x' y')
	| x == x', y - 1 == y' = Right T
	| x == x', y + 1 == y' = Right B
	| x - 1 == x', y == y' = Right R
	| x + 1 == x', y == y' = Right L
	| otherwise = Left $ "dir " ++ show p1 ++ " " ++ show p2

dirToLine, dirToLine' :: Dir -> Dir -> Either String Element
dirToLine T T = Right VLine
dirToLine T L = Right BottomLeft
dirToLine T R = Right BottomRight
dirToLine B B = Right VLine
dirToLine B L = Right TopLeft
dirToLine B R = Right TopRight
dirToLine L T = Right TopRight
dirToLine L B = Right BottomRight
dirToLine L L = Right HLine
dirToLine R T = Right TopLeft
dirToLine R B = Right BottomLeft
dirToLine R R = Right HLine
dirToLine d d' = Left $ "dirToLine " ++ show d ++ " " ++ show d'

dirToLine' T L = Right EndBottomLeft
dirToLine' B L = Right EndTopLeft
dirToLine' L L = Right EndHLine
dirToLine' R L = Right EndHLineR
dirToLine' d d' = Left $ "dirToLine' " ++ show d ++ " " ++ show d'
