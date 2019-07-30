{-# OPTIONS_GHC -Wall -fno-warn-tabs #-}

module Circuit.Diagram.Draw where

import Data.Map.Strict
import Diagrams.Prelude (Diagram, moveTo, (^&))
import Diagrams.Backend.SVG


import Circuit.Diagram.Map
import Circuit.Diagram.Pictures

drawDiagram :: DiagramMap -> Diagram B
drawDiagram DiagramMap { width = w, height = h, layout = l } = mconcat
	. (<$> [ (x, y) | x <- [0 .. w], y <- [- h .. h] ]) $ \p@(x, y) ->
		case l !? p of
			Just e -> moveTo (- fromIntegral x ^& fromIntegral y)
				$ drawElement e
			Nothing -> mempty

drawElement :: Element -> Diagram B
drawElement AndGateE = andGateD
drawElement OrGateE = orGateD
drawElement NotGateE = notGateD
drawElement HLine = hlineD
drawElement VLine = vlineD
drawElement Stump = mempty
drawElement _ = error "Circuit.Diagram.Draw.drawElement: not yet implemented"
