{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE MultiParamTypeClasses, FlexibleInstances #-}
{-# LANGUAGE DeriveGeneric #-}
{-# OPTIONS_GHC -Wall -fno-warn-tabs #-}

module Members where

import Control.Monad.IO.Class

import Lib

do	[hst, usr, pwd, db] <- liftIO $ lines <$> readFile "db_connect.info"
	defineTable hst usr pwd db "members"

showMembers :: Members -> String
showMembers Members { Members.id = i, memberTypeId = t, name = n } =
	show i ++ " " ++ show t ++ " " ++ n
