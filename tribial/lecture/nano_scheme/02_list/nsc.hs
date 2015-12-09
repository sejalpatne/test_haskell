{-# LANGUAGE TupleSections #-}

import Primitive
import Eval
import Parse
import Environment
import Maybe

main :: IO ()
main = interact $ maybe "err" (unlines . map showValue . fst)
	. (`scheme` env0) . rmvPrfx . head . lines

scheme :: String -> Env -> Maybe ([Value], Env)
scheme src e = (`evaluate` e) `mbind` (parse `mbind` tokens src)

rmvPrfx :: String -> String
rmvPrfx ('n' : 's' : 'c' : s) = s
rmvPrfx (_ : s) = rmvPrfx s
rmvPrfx _ = ""
