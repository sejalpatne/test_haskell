{-# LANGUAGE PackageImports #-}

module Main where

import InitEnv

import Data.Maybe
import Data.Char
import System.IO
import Control.Monad
import "monads-tf" Control.Monad.Trans
import Data.Time

import System.Environment
import System.Console.GetOpt
import Control.Applicative

main :: IO ()
main = do
	(_opts, args, _errs) <- getOpt Permute [] <$> getArgs
	ct <- getCurrentTime
	runSchemeM ct initEnv $ do
		mapM_ (runSrc . ("(load \"" ++) . (++ "\")")) $ "library.scm" : args
		forever $ do
			ln <- prompt 0 ""
			ret <- runSrc ln
			case ret of
				OError -> return ()
				_ -> liftIO . putStrLn =<< showObjM ret

prompt :: Int -> String -> SchemeM String
prompt d s = do
	n <- liftIO $ do
		putStr $ "yjscheme:" ++ show d ++ "> "
		hFlush stdout
		getLine
	let	s' = s ++ " " ++ n
		d' = dpt s'
	if maybe False (> 0) d' || all isSpace s'
		then prompt (fromJust d') s'
		else return s'

runSrc :: String -> SchemeM Object
runSrc src = flip catchError ((>> return OError) . liftIO . putStrLn) $
	case prs src of
		Just obj -> eval obj
		_ -> throwError "*** READ-ERROR:"
