{-# LANGUAGE TemplateHaskell, DeriveGeneric, MultiParamTypeClasses #-}
{-# OPTIONS_GHC -Wall -fno-warn-tabs #-}

module Lib (withConnection, connect, defineTable, getPassword) where

import GHC.Generics

import Control.Exception
import Data.ByteString (ByteString)
import System.IO
import Language.Haskell.TH

import Database.HDBC
import Database.HDBC.Query.TH
import Database.HDBC.Schema.Driver (driverConfig, typeMap)
import Database.HDBC.Schema.MySQL (driverMySQL)
import Database.HDBC.MySQL (
	Connection, MySQLConnectInfo(..),
	connectMySQL, defaultMySQLConnectInfo )
import Database.Relational.Config

withConnection :: (Connection -> IO a) -> IO a
withConnection act = do
	[hst, usr, _db] <- lines <$> readFile "db_connect.info"
	pwd <- getPassword "Enter password: "
	conn <- connect hst usr pwd
	act conn <* do
		commit conn
		disconnect conn

connect :: String -> String -> String -> IO Connection
connect hst usr pswd = connectMySQL defaultMySQLConnectInfo {
	mysqlHost = hst, mysqlUser = usr, mysqlPassword = pswd,
	mysqlDatabase = "INFORMATION_SCHEMA" }

convTypes :: [(String, TypeQ)]
convTypes = [("SET", [t| ByteString |]), ("ENUM", [t| ByteString |])]

defineTable :: String -> String -> String -> String -> String -> Q [Dec]
defineTable hst usr pswd db tbl =
	defineTableFromDB
		(connect hst usr pswd)
		(driverMySQL {
			driverConfig = defaultConfig {
				normalizedTableName = False },
			typeMap = convTypes })
		db tbl [''Show, ''Generic]

getPassword :: String -> IO String
getPassword msg = do
	putStr msg
	hFlush stdout
	withEcho False getLine <* putStrLn ""

withEcho :: Bool -> IO a -> IO a
withEcho echo action = do
	old <- hGetEcho stdin
	bracket_ (hSetEcho stdin echo) (hSetEcho stdin old) action
