module Object (
	SchemeM,
	Object(..),
	showObj,

	Env, fromList,
	EnvT, runEnvT,
	getValue,
	throwError, catchError
) where

import Env

import Data.Ratio

type SchemeM = EnvT Object IO

data Object
	= OInt Integer
	| ODouble Double
	| ORational Rational
	| OVar String
	| OCons Object Object
	| ONil
	| OSubr String (Object -> SchemeM Object)
	| OUndef

showObj :: Object -> String
showObj (OInt i) = show i
showObj (ODouble d) = show d
showObj (ORational r) = show (numerator r) ++ "/" ++ show (denominator r)
showObj (OVar v) = v
showObj c@(OCons _ _) = showCons False c
showObj ONil = "()"
showObj (OSubr n _) = "#<subr " ++ n ++ ">"
showObj OUndef = "#<undef>"

showCons :: Bool -> Object -> String
showCons l (OCons a d) = (if l then id else ("(" ++ ) . (++ ")")) $
	case d of
		OCons _ _ -> showObj a ++ " " ++ showCons True d
		ONil -> showObj a
		_ -> showObj a ++ " . " ++ showObj d
showCons l ONil = if l then "" else "()"
showCons _ _ = error "not cons"
