{-# LANGUAGE TupleSections #-}

module InteractiveScheme (scheme, Env, env0, Error(..)) where

import Control.Applicative
import Control.Arrow
import Data.Ratio

import Parser (Value(..), Error(..), Env, toDouble, parse)
import qualified Parser as P

env0 :: Env
env0 = P.fromList [
	("exit", DoExit),
	("+", Subroutine "+" . reduceL1 $ opn (+) (+)),
	("-", Subroutine "-" . reduceL1 $ opn (-) (-)),
	("*", Subroutine "*" . reduceL1 $ opn (*) (*)),
	("/", Subroutine "/" . reduceL1 $ opn (/) (/)),
	("define", Syntax "define" define)
	]

define :: Value -> Env -> Either Error ((String, Value), Env)
define (Cons sm@(Symbol s) (Cons v Nil)) e = do
	((o, v'), e') <- eval v e
	Right ((o, sm), P.insert s v' e')
define _ _ = Left $ Error "define error"

output :: String -> Either Error ((String, Value), Env) ->
	Either Error ((String, Value), Env)
output o r = (((o ++) `first`) `first`) <$> r

reduceL1 :: (Value -> Value -> Env -> Either Error ((String, Value), Env)) ->
	Value -> Env -> Either Error ((String, Value), Env)
reduceL1 op (Cons v0 vs) e = reduceL op v0 vs e
reduceL1 _ _ _ = Left $ Error "reduceL1: yet"

reduceL :: (Value -> Value -> Env -> Either Error ((String, Value), Env)) ->
	Value -> Value -> Env -> Either Error ((String, Value), Env)
reduceL op v0 (Cons v vs) e = case op v0 v e of
	Right ((o, v'), e') -> output o $ reduceL op v' vs e'
	er -> er
reduceL _ v0 Nil e = Right (("", v0), e)
reduceL _ _ _ _ = Left $ Error "reduceL: yet"

opn :: (Rational -> Rational -> Rational) -> (Double -> Double -> Double) ->
	Value -> Value -> Env -> Either Error ((String, Value), Env)
opn opi _ (Integer n1) (Integer n2) e =
	Right . (, e) . ("" ,) . Integer $ n1 `opi` n2
opn _ opd v1 v2 e = case (toDouble v1, toDouble v2) of
	(Just d1, Just d2) -> Right . (, e) . ("" ,) . Double $ d1 `opd` d2
	_ -> Left . Error $ "operation ... is not defined between " ++
		toStr v1 ++ " " ++ toStr v2

scheme :: String -> Env -> Either Error (String, Env)
scheme s e = first (uncurry (++) . second toStr) <$>
	((`eval` e) . fst =<< parse s)

toStr :: Value -> String
toStr Undef = "#<undef>"
toStr (Symbol s) = s
toStr (Integer i) = case (numerator i, denominator i) of
	(n, 1) -> show n
	(n, d) -> show n ++ "/" ++ show d
toStr (Double d) = show d
toStr (Cons v Nil) = '(' : toStr v ++ ")"
toStr (Cons v _) = '(' : toStr v ++ " ..)"
toStr Nil = "()"
toStr DoExit = "#<closure exit>"
toStr (Subroutine n _) = "#<subr " ++ n ++ ">"
toStr (Syntax n _) = "#<syntax " ++ n ++ ">"
toStr _ = error "toStr: yet"

eval :: Value -> Env -> Either Error ((String, Value), Env)
eval (Symbol s) e = case P.lookup s e of
	Just v -> Right (("", v), e)
	_ -> Left . Error $ "*** ERROR: unbound variable: " ++ s
eval (Cons v1 v2) e = do
	((o1, p), e') <- eval v1 e
	case p of
		Syntax n s ->
			first (first (o1 ++)) <$> apply (Subroutine n s) v2 e'
		_ -> do	((o2, as), e'') <- mapC eval v2 e'
			first (first ((o1 ++ o2) ++)) <$> apply p as e''
eval v e = Right (("", v), e)

mapC :: (Value -> Env -> Either Error ((String, Value), Env)) -> Value -> Env ->
	Either Error ((String, Value), Env)
mapC f (Cons v vs) e = do
	((o, v'), e') <- f v e
	first ((o ++) *** Cons v') <$> mapC f vs e'
mapC _ Nil e = Right (("", Nil), e)
mapC _ v _ = Left . Error $ "*** ERROR: Compile Error: proper list required for " ++
	"function application or macro use: " ++ toStr v

apply :: Value -> Value -> Env -> Either Error ((String, Value), Env)
apply DoExit Nil _ = Left Exit
apply (Subroutine _ sr) v e = sr v e
apply _ _ _ = Left (Error "apply: yet")
