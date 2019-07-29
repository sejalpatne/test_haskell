{-# OPTIONS_GHC -Wall -fno-warn-tabs #-}

import Diagrams.Prelude
import Diagrams.Backend.SVG

import Circuit.Diagram.Draw

main :: IO ()
main = do
	renderSVG "sample.svg" (mkWidth 400) notGateD
	renderSVG "sample2.svg" (mkWidth 600) andGateD
