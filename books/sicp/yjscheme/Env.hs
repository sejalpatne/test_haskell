{-# LANGUAGE PackageImports #-}

module Env (
	Environment, fromList,
	EnvT, runEnvT,
	define,
	getValue,
	throwError, catchError,
) where

import "monads-tf" Control.Monad.State
import "monads-tf" Control.Monad.Error

type EnvT v m = StateT (Environment v) (ErrorT String m)

type Environment v = ([EID], [Env1 v])
data Env1 v = Env {
	envID :: EID,
	outEnvID :: Maybe EID,
	envBody :: Env v
 }
type EID = Int 
type Env v = [(String, v)]

fromList :: [(String, v)] -> Environment v
fromList e = ([0], [Env 0 Nothing e])

getEnv :: EID -> [Env1 v] -> Env1 v
getEnv eid envs = case filter ((== eid) . envID) envs of
	e : _ -> e
	_ -> error "bad"

getV :: String -> Environment v -> Maybe v
getV var (eid : _, envs) = let env = getEnv eid envs in
	case (lookup var $ envBody env, outEnvID env) of
		(val@(Just _), _) -> val
		(_, Just oeid) -> getV var ([oeid], envs)
		_ -> Nothing
getV _ _ = error "bad"

def :: String -> v -> Environment v -> Environment v
def var val (eids@(eid : _), envs) = let
	Env _ oeid body = getEnv eid envs in
	(eids, Env eid oeid ((var, val) : body) : envs)
def  _ _ _ = error "bad"

runEnvT :: Monad m => Environment v -> EnvT v m a -> m a
runEnvT ie act = do
	er <- runErrorT $ act `evalStateT` ie
	case er of
		Right r -> return r
		_ -> fail "error occur"

define :: (Monad m, Functor m) => String -> v -> EnvT v m ()
define var val = modify $ def var val

getValue :: (Monad m, Functor m) => String -> EnvT v m v 
getValue var = do
	mval <- gets $ getV var
	case mval of
		Just val -> return val
		_ -> throwError $ "*** ERROR: unbound variable: " ++ var
