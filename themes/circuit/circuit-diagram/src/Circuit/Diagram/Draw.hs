{-# OPTIONS_GHC -Wall -fno-warn-tabs #-}

module Circuit.Diagram.Draw where

import Data.Map.Strict
import Diagrams.Prelude (Diagram, moveTo, (^&), (===))
import Diagrams.Backend.SVG


import Circuit.Diagram.Map
import Circuit.Diagram.Pictures

drawDiagram :: DiagramMap -> Diagram B
drawDiagram DiagramMap { width = w, height = h, layout = l } = mconcat
	. (<$> [ Pos x y | x <- [0 .. w - 1], y <- [0 .. h - 1] ]) $ \p@(Pos x y) ->
		case l !? p of
			Just e -> moveTo (- fromIntegral x ^& fromIntegral y)
				$ drawElement e
			Nothing -> mempty

drawElement :: Element -> Diagram B
drawElement AndGateE = andGateD
drawElement OrGateE = orGateD
drawElement NotGateE = notGateD
drawElement HLine = hlineD
drawElement EndHLine = hlineD
drawElement (HLineText t1 t2) = hlineTextD t1 t2
drawElement VLine = vlineD
drawElement Stump = mempty
drawElement TopLeft = topLeftD
drawElement BottomLeft = bottomLeftD
drawElement TopRight = topRightD
drawElement BottomRight = bottomRightD
drawElement EndBottomLeft = bottomLeftD
drawElement TShape = tshapeD
drawElement TInverted = tishapeD
drawElement TLeft = tlshapeD
drawElement TRight = trshapeD
drawElement Cross = crossD
drawElement Branch = tshapeD === topLeftD
drawElement e = error $ "Circuit.Diagram.Draw.drawElement: not yet implemented: " ++ show e
