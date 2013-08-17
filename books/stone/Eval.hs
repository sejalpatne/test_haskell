{-# Language PackageImports #-}

module Eval (
	eval,
	stoneParse,
	printObject,
	initialEnv
) where

import Parser
import Examples
import Env

import Data.Maybe
import Control.Applicative
import "monads-tf" Control.Monad.State

type Eval = State (Env Function)

eval :: Program -> Eval [Object Function]
eval = mapM evalStatement

evalStatement :: Statement -> Eval (Object Function)
evalStatement (If e tb eb) = do
	b <- evalPrimary e
	case b of
		OBool False -> maybe (return ONULL)
			(fmap last . mapM evalStatement) eb
		_ -> last <$> mapM evalStatement tb
evalStatement (While e blk) = do
	b <- evalPrimary e
	case b of
		OBool False -> return ONULL
		_ -> do	mapM evalStatement blk
			evalStatement (While e blk)
evalStatement (Expr e) = evalPrimary e

evalPrimary :: Primary -> Eval (Object Function)
evalPrimary (PNumber n) = return $ ONumber n
evalPrimary (PIdentifier i) = gets $ getValue i
evalPrimary (PString s) = return $ OString s
evalPrimary (POp _) = error "evalPrimary: can't eval"
evalPrimary (PInfix (PIdentifier i) "=" p) = do
	r <- evalPrimary p
	modify $ putValue i r
	return r
evalPrimary (PInfix pl o pr) = do
	l <- evalPrimary pl
	r <- evalPrimary pr
	return $ getOp o l r
evalPrimary (PFunction f) = return $ OFunction f
evalPrimary (PApply fp args) = do
	OFunction (ps, blk) <- evalPrimary fp
	vs <- mapM evalPrimary args
	modify newEnv
	modify $ flip (foldr $ uncurry putValue) $ zip ps vs
	rs <- eval blk
	modify popEnv
	return $ last rs

getOp :: String -> (Object a) -> (Object a) -> (Object a)
getOp "+" (ONumber l) (ONumber r) = ONumber $ l + r
getOp "-" (ONumber l) (ONumber r) = ONumber $ l - r
getOp "*" (ONumber l) (ONumber r) = ONumber $ l * r
getOp "%" (ONumber l) (ONumber r) = ONumber $ l `mod` r
getOp ">" (ONumber l) (ONumber r) = OBool $ l > r
getOp "<" (ONumber l) (ONumber r) = OBool $ l < r
getOp "==" (ONumber l) (ONumber r) = OBool $ l == r
getOp op _ _ = error $ "getOp: " ++ op ++ " yet defined"
