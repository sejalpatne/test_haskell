{-# OPTIONS_GHC -fno-warn-tabs #-}

module TryLoadMemory () where

import Data.Bits
import Data.Word

import Circuit
import Clock
import Memory
import TrySingleCycle

sampleLoadInstructions :: [Word64]
sampleLoadInstructions = fromIntegral . packLoad <$> [
	Load (Reg 10) 0 (Reg 15),
	Load (Reg 10) 56 (Reg 15),
	Load (Reg 3) 16 (Reg 7),
	Load (Reg 2) 24 (Reg 4),
	Load (Reg 18) 8 (Reg 21) ]

data Reg = Reg Word8 deriving Show
type Imm = Word8
data Load = Load Reg Imm Reg deriving Show

packLoad :: Load -> Word32
packLoad (Load (Reg rd) imm (Reg r1)) = packIType [imm, r1, 3, rd, 3]

packIType :: [Word8] -> Word32
packIType ws = imm .|. r1 .|. f3 .|. rd .|. op
	where
	[imm_, r1_, f3_, rd_, op] = fromIntegral <$> ws
	imm = imm_ `shiftL` 20; r1 = r1_ `shiftL` 15
	f3 = f3_ `shiftL` 12; rd = rd_ `shiftL` 7

unpackItype :: Word32 -> [Word8]
unpackItype w = fromIntegral <$> [
	imm_ `shiftR` 20, r1_ `shiftR` 15,
	f3_ `shiftR` 12, rd_ `shiftR` 7, op ]
	where
	[imm_, r1_, f3_, rd_, op] = map (w .&.) [
		0xfff00000,
		0x000f8000,
		0x00007000,
		0x00000f80,
		0x0000007f ]

((cl, pc, rim), cct) = makeCircuit tryInstMem

cct1 = foldr (uncurry $ storeRiscvInstMem rim) cct
	$ zip [0, 4 ..] sampleLoadInstructions

cct2 = resetProgramCounter pc cct1
cct3 = clockOn cl cct2
