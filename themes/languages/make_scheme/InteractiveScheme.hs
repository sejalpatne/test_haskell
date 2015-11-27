{-# LANGUAGE TupleSections #-}

module InteractiveScheme (scheme, Env, env0, Error(..)) where

import Control.Applicative
import Control.Arrow
import Data.Ratio

import Parser (Env, Symbol, Value(..), Error(..), toDouble, parse)
import qualified Parser as P

env0 :: Env
env0 = P.fromList [
	("exit", DoExit),
	("+", Subroutine "+" . reduceL1 $ opn (+) (+)),
	("-", Subroutine "-" neg),
	("*", Subroutine "*" . reduceL1 $ opn (*) (*)),
	("/", Subroutine "/" . reduceL1 $ opn (/) (/)),
	("=", Subroutine "=" $ equal),
	(">", Subroutine ">" $ isLargerThan),
	("<", Subroutine "<" $ isSmallerThan),
	("define", Syntax "define" define),
	("lambda", Syntax "lambda" lambda),
	("cond", Syntax "cond" cond)
	]

define :: Value -> Env -> Either Error ((String, Value), Env)
define (Cons sm@(Symbol s) (Cons v Nil)) e = do
	((o, v'), e') <- eval v e
	Right ((o, sm), P.insert s v' e')
define (Cons (Cons sm@(Symbol n) as) c) e = do
	ss <- symbols as
	Right (("", sm), P.insert n (Closure n e ss c) e)
define _ _ = Left $ Error "define: error"

lambda :: Value -> Env -> Either Error ((String, Value), Env)
lambda (Cons a0 as) e = (\ss -> (("", Closure "#f" e ss as), e)) <$> symbols a0
lambda _ _ = Left $ Error "lambda: error"

symbols :: Value -> Either Error [Symbol]
symbols (Cons (Symbol s) ss) = (s :) <$> symbols ss
symbols Nil = Right []
symbols _ = Left $ Error "symbols: yet"

cond :: Value -> Env -> Either Error ((String, Value), Env)
cond Nil e = Right (("", Undef), e)
cond (Cons (Cons (Symbol "else") p) _) e = foreachC eval p e
cond (Cons (Cons t p) cs) e = do
	((to, tr), e') <- eval t e
	case tr of
		Bool False -> output to $ cond cs e'
		_ -> output to $ foreachC eval p e'
cond _ _ = Left $ Error "cond: yet"

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

neg :: Value -> Env -> Either Error ((String, Value), Env)
neg (Cons (Integer n) Nil) e = Right (("", Integer $ - n), e)
neg (Cons (Double n) Nil) e = Right (("", Double $ - n), e)
neg v e = reduceL1 (opn (-) (-)) v e

equal, isLargerThan, isSmallerThan ::
	Value -> Env -> Either Error ((String, Value), Env)
equal (Cons (Integer n1) (Cons (Integer n2) Nil)) e =
	Right (("", Bool $ n1 == n2), e)
equal _ _ = Left . Error $ "equal: yet"
isLargerThan (Cons (Integer n1) (Cons (Integer n2) Nil)) e =
	Right (("", Bool $ n1 > n2), e)
isLargerThan _ _ = Left . Error $ "isLargerThan: yet"
isSmallerThan (Cons (Integer n1) (Cons (Integer n2) Nil)) e =
	Right (("", Bool $ n1 < n2), e)
isSmallerThan _ _ = Left . Error $ "isSmallerThan: yet"

scheme :: String -> Env -> Either Error (String, Env)
scheme s e = first (uncurry (++) . second toStr) <$>
	((`eval` e) . fst =<< parse s)

toStr :: Value -> String
toStr Undef = "#<undef>"
toStr (Bool False) = "#f"
toStr (Bool True) = "#t"
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
toStr (Closure n _ _ _) = "#<closure " ++ n ++ ">"
toStr _ = error "toStr: yet"

eval :: Value -> Env -> Either Error ((String, Value), Env)
eval (Symbol s) e = case P.lookup s e of
	Just v -> Right (("", v), e)
	_ -> Left . Error $ "*** ERROR: unbound variable: " ++ s
eval (Cons v1 v2) e = do
	((o1, p), e') <- eval v1 e
	first (first (o1 ++)) <$> apply p v2 e'
eval v e = Right (("", v), e)

mapC :: (Value -> Env -> Either Error ((String, Value), Env)) -> Value -> Env ->
	Either Error ((String, Value), Env)
mapC f (Cons v vs) e = do
	((o, v'), e') <- f v e
	first ((o ++) *** Cons v') <$> mapC f vs e'
mapC _ Nil e = Right (("", Nil), e)
mapC _ v _ = Left . Error $ "*** ERROR: Compile Error: proper list required for " ++
	"function application or macro use: " ++ toStr v

foreachC :: (Value -> Env -> Either Error ((String, Value), Env)) -> Value -> Env ->
	Either Error ((String, Value), Env)
foreachC f (Cons v Nil) e = f v e
foreachC f (Cons v vs) e = do
	((o, _), e') <- f v e
	first ((o ++) `first`) <$> foreachC f vs e'
foreachC _ Nil e = Right (("", Nil), e)
foreachC _ v _ = Left . Error $ "*** ERROR: Compile Error: proper list required for " ++
	"function application or macro use: " ++ toStr v

apply :: Value -> Value -> Env -> Either Error ((String, Value), Env)
apply DoExit Nil _ = Left Exit
apply (Syntax _ s) v e = s v e
apply (Subroutine _ sr) v e = do
	((o2, as), e'') <- mapC eval v e
	first (first (o2 ++)) <$> sr as e''
apply (Closure _ e ss c) v e0 = do
	((o2, as), e'') <- mapC eval v e0
	first (first (o2 ++)) . second (const e'')
		<$> (foreachC eval c =<< defineAll ss as e)
apply f _ _ = Left . Error $ "apply: yet: " ++ show f

defineAll :: [Symbol] -> Value -> Env -> Either Error Env
defineAll [] Nil e = Right e
defineAll (s : ss) (Cons v vs) e = P.insert s v <$> defineAll ss vs e
defineAll _ _ _ = Left $ Error "defineAll: yet"
