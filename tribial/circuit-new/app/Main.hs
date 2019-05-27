{-# OPTIONS_GHC -Wall -fno-warn-tabs #-}

module Main where

import Control.Monad
import Data.List
import Data.Bits ((.&.), shiftR)
import Data.Bool
import Data.Word

import Circuit

main :: IO ()
main = putStrLn "Slozsoft"

mux2 :: CircuitBuilder (IWire, IWire, IWire, OWire)
mux2 = do
	(slin, slout) <- idGate
	(ni, no) <- notGate
	(nsl, a, o1) <- andGate
	(sl, b, o2) <- andGate
	(o1', o2', c) <- orGate
	zipWithM_ connectWire [slout, no, o1, slout, o2] [ni, nsl, o1', sl, o2']
	return (slin, a, b, c)

testTri :: CircuitBuilder (IWire, IWire, IWire, IWire, OWire)
testTri = do
	(oin, oout) <- idGate
	(s1, i1, o1) <- triGate
	(s2, i2, o2) <- triGate
	connectWire o1 oin
	connectWire o2 oin
	return (s1, i1, s2, i2, oout)

nor :: CircuitBuilder (IWire, IWire, OWire)
nor = do
	(i1, i2, o) <- orGate
	(o', no) <- notGate
	connectWire o o'
	return (i1, i2, no)

rs :: CircuitBuilder (IWire, IWire, OWire, OWire)
rs = do	(r, q_', q) <- nor
	(s, q', q_) <- nor
	connectWire q q'
	connectWire q_ q_'
	return (r, s, q, q_)

dlatch :: CircuitBuilder (IWire, IWire, OWire, OWire)
dlatch = do
	(cin, cout) <- idGate
	(din, dout) <- idGate
	(d', nd) <- notGate
	(c', nd', r) <- andGate
	(c'', d'', s) <- andGate
	(r', s', q, q_) <- rs
	zipWithM_ connectWire
		[dout, cout, nd, cout, dout, r, s]
		[d', c', nd', c'', d'', r', s']
	return (cin, din, q, q_)

type Memory8Wires = (IWire, IWire, IWire, IWire, IWire, OWire)

memory8 :: CircuitBuilder Memory8Wires
memory8 = do
	(cin, cout) <- idGate
	(a0in, a0out) <- idGate
	(a1in, a1out) <- idGate
	(a2in, a2out) <- idGate
	(din, dout) <- idGate
	((a0, a1, a2), dec) <- (\([a, b, c], d) -> ((a, b, c), d)) <$> dec38
	(ci1s, ci2s, cots) <- unzip3 <$> replicateM 8 andGate
	((a0', a1', a2'), is, o) <- (\([a, b, c], d, e) -> ((a, b, c), d, e)) <$> mux8
	(cs, ds, qs, _q_s) <- unzip4 <$> replicateM 8 dlatch
	zipWithM_ connectWire [a0out, a1out, a2out] [a0, a1, a2]
	zipWithM_ connectWire [a0out, a1out, a2out] [a0', a1', a2']
	mapM_ (connectWire cout) ci1s
	zipWithM_ connectWire dec ci2s
	zipWithM_ connectWire cots cs
	zipWithM_ connectWire qs is
	mapM_ (connectWire dout) ds
	return (a0in, a1in, a2in, cin, din, o)

setBitsMemory8 :: Memory8Wires -> Word64 -> Bit -> Bit -> Circuit -> Circuit
setBitsMemory8 (a0, a1, a2, c, d, _) a bc bd =
	foldr (.) id (zipWith setBit [a0, a1, a2] $ wordToBits 64 a)
		. setBit c bc . setBit d bd

getBitsMemory8 :: Memory8Wires -> Circuit -> Bit
getBitsMemory8 (_, _, _, _, _, o) = peekOWire o

type Mux8Wires = ([IWire], [IWire], OWire)
	
mux8 :: CircuitBuilder Mux8Wires
mux8 = do
	(ms, ss) <- dec38
	(ss', is, os) <- unzip3 <$> replicateM 8 triGate
	(oin, oout) <- idGate
	zipWithM_ connectWire ss ss'
	mapM_ (`connectWire` oin) os
	return (ms, is, oout)

wordToBits :: Word8 -> Word64 -> [Bit]
wordToBits 0 _ = []
wordToBits n w = bool O I (w .&. 1 /= 0) : wordToBits (n - 1) (w `shiftR` 1)

setBitsMux8 :: Mux8Wires -> Word64 -> [Bit] -> Circuit -> Circuit
setBitsMux8 (ms, is, _) m bs = foldr (.) id (zipWith setBit ms $ wordToBits 64 m)
	. foldr (.) id (zipWith setBit is bs)

getBitsMux8 :: Mux8Wires -> Circuit -> Bit
getBitsMux8 (_, _, o) = peekOWire o

dec38 :: CircuitBuilder ([IWire], [OWire])
dec38 = do
	(is, ois) <- unzip <$> replicateM 3 idGate
	(ias, oas) <- unzip <$> replicateM 8 andGate3
	zipWithM_ ((sequence_ .) . flip (zipWith3 id) ois) (binary (inverse, obverse) 3) ias
	return (is, oas)

andGate3 :: CircuitBuilder ([IWire], OWire)
andGate3 = do
	(i1, i2, a1) <- andGate
	(a1', i3, o) <- andGate
	connectWire a1 a1'
	return ([i1, i2, i3], o)

binary :: (a, a) -> Word8 -> [[a]]
binary _ n | n < 1 = [[]]
binary (o, i) n = binary (o, i) (n - 1) >>= (<$> [(o :), (i :)]) . flip ($)

inverse, obverse :: OWire -> IWire -> CircuitBuilder ()
inverse o i = do
	(ni, no) <- notGate
	connectWire o ni
	connectWire no i
obverse = connectWire
