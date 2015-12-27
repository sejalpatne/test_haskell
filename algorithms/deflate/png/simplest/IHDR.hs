{-# LANGUAGE OverloadedStrings, TupleSections, PackageImports #-}

module IHDR (
	IHDR(..), ColorType(..), fromChunk, toChunk,
	HasColor(..), HasAlpha(..)
	) where

import Control.Arrow
import "monads-tf" Control.Monad.State
import Data.List
import Data.Bits
import Data.Bool
import Data.Word
import qualified Data.ByteString as BS

import Chunks

fromChunk :: Chunk -> Maybe IHDR
fromChunk (Chunk "IHDR" c) = (`evalStateT` c) $ do
	w <- item 4 $ Just . BS.foldl' be 0
	h <- item 4 $ Just . BS.foldl' be 0
	d <- item 1 $ \bs -> case BS.uncons bs of
		Just (dd, "") -> Just dd
		_ -> Nothing
	c <- item 1 $ \bs -> case BS.uncons bs of
		Just (cc, "") -> toColorType cc
		_ -> Nothing
	cm <- item 1 $ \bs -> case BS.uncons bs of
		Just (dd, "") -> Just dd
		_ -> Nothing
	f <- item 1 $ \bs -> case BS.uncons bs of
		Just (dd, "") -> Just dd
		_ -> Nothing
	i <- item 1 $ \bs -> case BS.uncons bs of
		Just (dd, "") -> Just dd
		_ -> Nothing
	return IHDR {
		width = w,
		height = h,
		bitDepth = d,
		colorType = c,
		compressionMethod = cm,
		filterMethod = f,
		interlaceMethod = i
		}
	where
	be :: (Bits n, Num n) => n -> Word8 -> n
	be = curry $ uncurry (.|.) . ((`shiftL` 8) *** fromIntegral)
fromChunk _ = Nothing

toChunk :: IHDR -> Chunk
toChunk i = Chunk {
	typ = "IHDR",
	dat = be 4 (width i)
		`BS.append` be 4 (height i)
		`BS.append` be 1 (bitDepth i)
		`BS.append` be 1 (fromColorType $ colorType i)
		`BS.append` be 1 (compressionMethod i)
		`BS.append` be 1 (filterMethod i)
		`BS.append` be 1 (interlaceMethod i)
	}
	where
	be :: (Bits a, Integral a) => Int -> a -> BS.ByteString
	be n = ((BS.pack . reverse) .) . flip curry n . unfoldr $ \(i, n) ->
		bool Nothing (Just . second (i - 1 ,) $ popByte n) (i > 0)

popByte :: (Integral a, Bits a) => a -> (Word8, a)
popByte = fromIntegral &&& (`shiftR` 8)

data IHDR = IHDR {
	width :: Int,
	height :: Int,
	bitDepth :: Word8,
	colorType :: ColorType,
	compressionMethod :: Word8,
	filterMethod :: Word8,
	interlaceMethod :: Word8
	} deriving Show

data ColorType = PaletteColor | NoPalette HasColor HasAlpha deriving Show

data HasColor = Grayscale | HasColor deriving (Show, Enum)

data HasAlpha = NoAlpha | HasAlpha deriving (Show, Enum)

toColorType :: Word8 -> Maybe ColorType
toColorType w = case w `popBits` 3 of
	([True, True, False], 0) -> Just PaletteColor
	([False, hc, ha], 0) -> Just $ NoPalette (enumToEnum hc) (enumToEnum ha)
	_ -> Nothing

popBits :: Bits n => n -> Int -> ([Bool], n)
popBits n c = (map (n `testBit`) [0 .. c - 1], n `shiftR` c)

enumToEnum :: (Enum a, Enum b) => a -> b
enumToEnum = toEnum . fromEnum

fromColorType :: ColorType -> Word8
fromColorType PaletteColor = 3
fromColorType (NoPalette hc ha) = fromIntegral $ fromEnum hc * 2 + fromEnum ha * 4
