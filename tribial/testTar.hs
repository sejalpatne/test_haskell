{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -Wall -fno-warn-tabs #-}

module Main (main) where

import Data.List (isPrefixOf)
import Data.Tree (Tree(..))
import Data.Bool (bool)
import System.IO (IOMode(..), stderr, openFile)
import System.IO.Temp (withTempDirectory)
import System.Directory (
	doesDirectoryExist, doesFileExist, getDirectoryContents,
	getCurrentDirectory, setCurrentDirectory )
import Test.HUnit (
	Test(..), Assertion, runTestText, putTextToHandle, assertEqual)

import qualified Data.ByteString as BS

import Tar

-- MAIN FUNCTIONS

main :: IO ()
main = () <$ runTestText (putTextToHandle stderr False) tests

tests :: Test
tests = TestList [
	TestCase $ assertion "files/tar/sample.tar",
	TestCase $ assertion "tmp/tar_dirs/simple.tar",
	TestCase $ assertion "tmp/tar_dirs/nested.tar",
	TestCase $ assertion "tmp/tar_dirs/simpleNested.tar" ]

assertion :: FilePath -> Assertion
assertion tf = do
	org <- BS.readFile tf
	h <- openFile tf ReadMode
	withinTempDirectory "testTar" $ do
		hUntar h
		directoryTree "." >>= putStr . showTree 0
		tar "new.tar" . nfilter dotPath =<< getDirectoryContents "."
		new <- BS.readFile "new.tar"
		assertEqual (show $ diff org new) org new

-- UTILS

withinTempDirectory :: String -> IO a -> IO a
withinTempDirectory dnt act = do
	cd <- getCurrentDirectory
	withTempDirectory "." dnt $ \td -> do
		setCurrentDirectory td
		act <* setCurrentDirectory cd

directoryTree :: FilePath -> IO (Tree FilePath)
directoryTree fp0 = do
	df <- checkDF fp0
	case df of
		Directory -> do
			cd <- getCurrentDirectory
			setCurrentDirectory fp0
			Node fp0
				<$> (mapM directoryTree . nfilter dotPath
					=<< getDirectoryContents ".")
				<* setCurrentDirectory cd
		File -> do
			cnt <- readFile fp0
			return $ Node (fp0 ++ ": " ++ take 20 cnt) []

diff :: BS.ByteString -> BS.ByteString -> [(BS.ByteString, BS.ByteString)]
diff bs = map BS.unzip . sepMaybes
	. BS.zipWith (\w v -> bool (Just (w, v)) Nothing $ w == v) bs

-- TOOLS

nfilter :: (a -> Bool) -> [a] -> [a]
nfilter = filter . (not .)

dotPath :: FilePath -> Bool
dotPath = isPrefixOf "."

showTree :: Show a => Int -> Tree a -> String
showTree idt (Node x ts) = replicate idt ' ' ++
	show x ++ "\n" ++ concatMap (showTree $ idt + 4) ts

data DF = Directory | File deriving Show

checkDF :: FilePath -> IO DF
checkDF fp = do
	f <- doesFileExist fp
	d <- doesDirectoryExist fp
	case (f, d) of
		(True, False) -> return File
		(False, True) -> return Directory
		_ -> error $ fp ++ ": no such file or directory"

sepMaybes :: [Maybe a] -> [[a]]
sepMaybes (Just x : Nothing : ms) = [x] : sepMaybes ms
sepMaybes (Just x : ms) = case sepMaybes ms of
	xs : xss -> (x : xs) : xss
	[] -> [[x]]
sepMaybes (Nothing : ms) = sepMaybes ms
sepMaybes [] = []
