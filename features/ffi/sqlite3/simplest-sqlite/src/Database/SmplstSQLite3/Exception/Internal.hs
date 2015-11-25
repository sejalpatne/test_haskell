{-# LANGUAGE TemplateHaskell, ExistentialQuantification, DeriveDataTypeable #-}

module Database.SmplstSQLite3.Exception.Internal (
	sqliteThrow, sqliteThrowBindError,

	SQLiteException(..),

	SQLITE_ERROR(..),
	SQLITE_INTERNAL(..),
	SQLITE_PERM(..),

	SQLITE_ABORT(..),
	SQLITE_ABORT_PLAIN(..),
	SQLITE_ABORT_ROLLBACK(..),

	SQLITE_BUSY(..),
	SQLITE_BUSY_PLAIN(..),
	SQLITE_BUSY_RECOVERY(..),
	SQLITE_BUSY_SNAPSHOT(..),

	SQLITE_LOCKED(..),
	SQLITE_LOCKED_PLAIN(..),
	SQLITE_LOCKED_SHAREDCACHE(..),

	SQLITE_NOMEM(..),

	SQLITE_READONLY(..),
	SQLITE_READONLY_PLAIN(..),
	SQLITE_READONLY_RECOVERY(..),
	SQLITE_READONLY_CANTLOCK(..),
	SQLITE_READONLY_ROLLBACK(..),
	SQLITE_READONLY_DBMOVED(..),

	SQLITE_INTERRUPT(..),

	SQLITE_IOERR(..),
	SQLITE_IOERR_PLAIN(..),
	SQLITE_IOERR_READ(..),
	SQLITE_IOERR_SHORT_READ(..),
	SQLITE_IOERR_WRITE(..),
	SQLITE_IOERR_FSYNC(..),
	SQLITE_IOERR_DIR_FSYNC(..),
	SQLITE_IOERR_TRUNCATE(..),
	SQLITE_IOERR_FSTAT(..),
	SQLITE_IOERR_UNLOCK(..),
	SQLITE_IOERR_RDLOCK(..),
	SQLITE_IOERR_DELETE(..),
	SQLITE_IOERR_BLOCKED(..),
	SQLITE_IOERR_NOMEM(..),
	SQLITE_IOERR_ACCESS(..),
	SQLITE_IOERR_CHECKRESERVEDLOCK(..),
	SQLITE_IOERR_LOCK(..),
	SQLITE_IOERR_CLOSE(..),
	SQLITE_IOERR_DIR_CLOSE(..),
	SQLITE_IOERR_SHMOPEN(..),
	SQLITE_IOERR_SHMSIZE(..),
	SQLITE_IOERR_SHMLOCK(..),
	SQLITE_IOERR_SHMMAP(..),
	SQLITE_IOERR_SEEK(..),
	SQLITE_IOERR_DELETE_NOENT(..),
	SQLITE_IOERR_MMAP(..),
	SQLITE_IOERR_GETTEMPPATH(..),
	SQLITE_IOERR_CONVPATH(..),

	SQLITE_CORRUPT(..),
	SQLITE_CORRUPT_PLAIN(..),
	SQLITE_CORRUPT_VTAB(..),

	SQLITE_NOTFOUND(..),
	SQLITE_FULL(..),

	SQLITE_CANTOPEN(..),
	SQLITE_CANTOPEN_PLAIN(..),
	SQLITE_CANTOPEN_NOTEMPDIR(..),
	SQLITE_CANTOPEN_ISDIR(..),
	SQLITE_CANTOPEN_FULLPATH(..),
	SQLITE_CANTOPEN_CONVPATH(..),

	SQLITE_PROTOCOL(..),
	SQLITE_EMPTY(..),
	SQLITE_SCHEMA(..),
	SQLITE_TOOBIG(..),

	SQLITE_CONSTRAINT(..),
	SQLITE_CONSTRAINT_PLAIN(..),
	SQLITE_CONSTRAINT_CHECK(..),
	SQLITE_CONSTRAINT_COMMITHOOK(..),
	SQLITE_CONSTRAINT_FOREIGNKEY(..),
	SQLITE_CONSTRAINT_FUNCTION(..),
	SQLITE_CONSTRAINT_NOTNULL(..),
	SQLITE_CONSTRAINT_PRIMARYKEY(..),
	SQLITE_CONSTRAINT_TRIGGER(..),
	SQLITE_CONSTRAINT_UNIQUE(..),
	SQLITE_CONSTRAINT_VTAB(..),
	SQLITE_CONSTRAINT_ROWID(..),

	SQLITE_MISMATCH(..),
	SQLITE_MISUSE(..),
	SQLITE_NOLFS(..),

	SQLITE_AUTH(..),
	SQLITE_AUTH_PLAIN(..),
	SQLITE_AUTH_USER(..),

	SQLITE_FORMAT(..),
	SQLITE_RANGE(..),
	SQLITE_NOTADB(..),

	SQLITE_NOTICE(..),
	SQLITE_NOTICE_PLAIN(..),
	SQLITE_NOTICE_RECOVER_WAL(..),
	SQLITE_NOTICE_RECOVER_ROLLBACK(..),

	SQLITE_WARNING(..),
	SQLITE_WARNING_PLAIN(..),
	SQLITE_WARNING_AUTOINDEX(..),

	SQLITE_BIND_ERROR(..),
	SQLITE_ERROR_OTHER(..),
	
	NullPointerException(..),
	nullPointerException
	) where

import Control.Exception
import Control.Exception.Hierarchy
import Data.Typeable
import Foreign.C.Types

import Database.SmplstSQLite3.Constants
import Database.SmplstSQLite3.Templates

mapM newException [
	"SQLITE_ERROR",
	"SQLITE_INTERNAL",
	"SQLITE_PERM",

	"SQLITE_ABORT_PLAIN",
	"SQLITE_ABORT_ROLLBACK",

	"SQLITE_BUSY_PLAIN",
	"SQLITE_BUSY_RECOVERY",
	"SQLITE_BUSY_SNAPSHOT",

	"SQLITE_LOCKED_PLAIN",
	"SQLITE_LOCKED_SHAREDCACHE",

	"SQLITE_NOMEM",

	"SQLITE_READONLY_PLAIN",
	"SQLITE_READONLY_RECOVERY",
	"SQLITE_READONLY_CANTLOCK",
	"SQLITE_READONLY_ROLLBACK",
	"SQLITE_READONLY_DBMOVED",

	"SQLITE_INTERRUPT",

	"SQLITE_IOERR_PLAIN",
	"SQLITE_IOERR_READ",
	"SQLITE_IOERR_SHORT_READ",
	"SQLITE_IOERR_WRITE",
	"SQLITE_IOERR_FSYNC",
	"SQLITE_IOERR_DIR_FSYNC",
	"SQLITE_IOERR_TRUNCATE",
	"SQLITE_IOERR_FSTAT",
	"SQLITE_IOERR_UNLOCK",
	"SQLITE_IOERR_RDLOCK",
	"SQLITE_IOERR_DELETE",
	"SQLITE_IOERR_BLOCKED",
	"SQLITE_IOERR_NOMEM",
	"SQLITE_IOERR_ACCESS",
	"SQLITE_IOERR_CHECKRESERVEDLOCK",
	"SQLITE_IOERR_LOCK",
	"SQLITE_IOERR_CLOSE",
	"SQLITE_IOERR_DIR_CLOSE",
	"SQLITE_IOERR_SHMOPEN",
	"SQLITE_IOERR_SHMSIZE",
	"SQLITE_IOERR_SHMLOCK",
	"SQLITE_IOERR_SHMMAP",
	"SQLITE_IOERR_SEEK",
	"SQLITE_IOERR_DELETE_NOENT",
	"SQLITE_IOERR_MMAP",
	"SQLITE_IOERR_GETTEMPPATH",
	"SQLITE_IOERR_CONVPATH",

	"SQLITE_CORRUPT_PLAIN",
	"SQLITE_CORRUPT_VTAB",

	"SQLITE_NOTFOUND",
	"SQLITE_FULL",

	"SQLITE_CANTOPEN_PLAIN",
	"SQLITE_CANTOPEN_NOTEMPDIR",
	"SQLITE_CANTOPEN_ISDIR",
	"SQLITE_CANTOPEN_FULLPATH",
	"SQLITE_CANTOPEN_CONVPATH",

	"SQLITE_PROTOCOL",
	"SQLITE_EMPTY",
	"SQLITE_SCHEMA",
	"SQLITE_TOOBIG",

	"SQLITE_CONSTRAINT_PLAIN",
	"SQLITE_CONSTRAINT_CHECK",
	"SQLITE_CONSTRAINT_COMMITHOOK",
	"SQLITE_CONSTRAINT_FOREIGNKEY",
	"SQLITE_CONSTRAINT_FUNCTION",
	"SQLITE_CONSTRAINT_NOTNULL",
	"SQLITE_CONSTRAINT_PRIMARYKEY",
	"SQLITE_CONSTRAINT_TRIGGER",
	"SQLITE_CONSTRAINT_UNIQUE",
	"SQLITE_CONSTRAINT_VTAB",
	"SQLITE_CONSTRAINT_ROWID",

	"SQLITE_MISMATCH",
	"SQLITE_MISUSE",
	"SQLITE_NOLFS",

	"SQLITE_AUTH_PLAIN",
	"SQLITE_AUTH_USER",

	"SQLITE_FORMAT",
	"SQLITE_RANGE",
	"SQLITE_NOTADB",

	"SQLITE_NOTICE_PLAIN",
	"SQLITE_NOTICE_RECOVER_WAL",
	"SQLITE_NOTICE_RECOVER_ROLLBACK",

	"SQLITE_WARNING_PLAIN",
	"SQLITE_WARNING_AUTOINDEX",

	"SQLITE_BIND_ERROR" ]


data SQLITE_ERROR_OTHER = SQLITE_ERROR_OTHER CInt String deriving (Typeable, Show)

exceptionHierarchy Nothing $
	ExNode "SQLiteException" [
		ExType ''SQLITE_ERROR,
		ExType ''SQLITE_INTERNAL,
		ExType ''SQLITE_PERM,
		ExNode "SQLITE_ABORT" [
			ExType ''SQLITE_ABORT_PLAIN,
			ExType ''SQLITE_ABORT_ROLLBACK
			],
		ExNode "SQLITE_BUSY" [
			ExType ''SQLITE_BUSY_PLAIN,
			ExType ''SQLITE_BUSY_RECOVERY,
			ExType ''SQLITE_BUSY_SNAPSHOT
			],
		ExNode "SQLITE_LOCKED" [
			ExType ''SQLITE_LOCKED_PLAIN,
			ExType ''SQLITE_LOCKED_SHAREDCACHE
			],
		ExType ''SQLITE_NOMEM,
		ExNode "SQLITE_READONLY" [
			ExType ''SQLITE_READONLY_PLAIN,
			ExType ''SQLITE_READONLY_RECOVERY,
			ExType ''SQLITE_READONLY_CANTLOCK,
			ExType ''SQLITE_READONLY_ROLLBACK,
			ExType ''SQLITE_READONLY_DBMOVED
			],
		ExType ''SQLITE_INTERRUPT,
		ExNode "SQLITE_IOERR" [
			ExType ''SQLITE_IOERR_PLAIN,
			ExType ''SQLITE_IOERR_READ,
			ExType ''SQLITE_IOERR_SHORT_READ,
			ExType ''SQLITE_IOERR_WRITE,
			ExType ''SQLITE_IOERR_FSYNC,
			ExType ''SQLITE_IOERR_DIR_FSYNC,
			ExType ''SQLITE_IOERR_TRUNCATE,
			ExType ''SQLITE_IOERR_FSTAT,
			ExType ''SQLITE_IOERR_UNLOCK,
			ExType ''SQLITE_IOERR_RDLOCK,
			ExType ''SQLITE_IOERR_DELETE,
			ExType ''SQLITE_IOERR_BLOCKED,
			ExType ''SQLITE_IOERR_NOMEM,
			ExType ''SQLITE_IOERR_ACCESS,
			ExType ''SQLITE_IOERR_CHECKRESERVEDLOCK,
			ExType ''SQLITE_IOERR_LOCK,
			ExType ''SQLITE_IOERR_CLOSE,
			ExType ''SQLITE_IOERR_DIR_CLOSE,
			ExType ''SQLITE_IOERR_SHMOPEN,
			ExType ''SQLITE_IOERR_SHMSIZE,
			ExType ''SQLITE_IOERR_SHMLOCK,
			ExType ''SQLITE_IOERR_SHMMAP,
			ExType ''SQLITE_IOERR_SEEK,
			ExType ''SQLITE_IOERR_DELETE_NOENT,
			ExType ''SQLITE_IOERR_MMAP,
			ExType ''SQLITE_IOERR_GETTEMPPATH,
			ExType ''SQLITE_IOERR_CONVPATH
			],
		ExNode "SQLITE_CORRUPT" [
			ExType ''SQLITE_CORRUPT_PLAIN,
			ExType ''SQLITE_CORRUPT_VTAB
			],
		ExType ''SQLITE_NOTFOUND,
		ExType ''SQLITE_FULL,
		ExNode "SQLITE_CANTOPEN" [
			ExType ''SQLITE_CANTOPEN_PLAIN,
			ExType ''SQLITE_CANTOPEN_NOTEMPDIR,
			ExType ''SQLITE_CANTOPEN_ISDIR,
			ExType ''SQLITE_CANTOPEN_FULLPATH,
			ExType ''SQLITE_CANTOPEN_CONVPATH
			],
		ExType ''SQLITE_PROTOCOL,
		ExType ''SQLITE_EMPTY,
		ExType ''SQLITE_SCHEMA,
		ExType ''SQLITE_TOOBIG,
		ExNode "SQLITE_CONSTRAINT" [
			ExType ''SQLITE_CONSTRAINT_PLAIN,
			ExType ''SQLITE_CONSTRAINT_CHECK,
			ExType ''SQLITE_CONSTRAINT_COMMITHOOK,
			ExType ''SQLITE_CONSTRAINT_FOREIGNKEY,
			ExType ''SQLITE_CONSTRAINT_FUNCTION,
			ExType ''SQLITE_CONSTRAINT_NOTNULL,
			ExType ''SQLITE_CONSTRAINT_PRIMARYKEY,
			ExType ''SQLITE_CONSTRAINT_TRIGGER,
			ExType ''SQLITE_CONSTRAINT_UNIQUE,
			ExType ''SQLITE_CONSTRAINT_VTAB,
			ExType ''SQLITE_CONSTRAINT_ROWID
			],
		ExType ''SQLITE_MISMATCH,
		ExType ''SQLITE_MISUSE,
		ExType ''SQLITE_NOLFS,
		ExNode "SQLITE_AUTH" [
			ExType ''SQLITE_AUTH_PLAIN,
			ExType ''SQLITE_AUTH_USER
			],
		ExType ''SQLITE_FORMAT,
		ExType ''SQLITE_RANGE,
		ExType ''SQLITE_NOTADB,
		ExNode "SQLITE_NOTICE" [
			ExType ''SQLITE_NOTICE_PLAIN,
			ExType ''SQLITE_NOTICE_RECOVER_WAL,
			ExType ''SQLITE_NOTICE_RECOVER_ROLLBACK
			],
		ExNode "SQLITE_WARNING" [
			ExType ''SQLITE_WARNING_PLAIN,
			ExType ''SQLITE_WARNING_AUTOINDEX
			],

		ExType ''SQLITE_BIND_ERROR,
		ExType ''SQLITE_ERROR_OTHER ]

mkSqliteThrow [
	'SQLITE_ERROR,
	'SQLITE_INTERNAL,
	'SQLITE_PERM,

	'SQLITE_ABORT_PLAIN,
	'SQLITE_ABORT_ROLLBACK,

	'SQLITE_BUSY_PLAIN,
	'SQLITE_BUSY_RECOVERY,
	'SQLITE_BUSY_SNAPSHOT,

	'SQLITE_LOCKED_PLAIN,
	'SQLITE_LOCKED_SHAREDCACHE,

	'SQLITE_NOMEM,

	'SQLITE_READONLY_PLAIN,
	'SQLITE_READONLY_RECOVERY,
	'SQLITE_READONLY_CANTLOCK,
	'SQLITE_READONLY_ROLLBACK,
	'SQLITE_READONLY_DBMOVED,

	'SQLITE_INTERRUPT,

	'SQLITE_IOERR_PLAIN,
	'SQLITE_IOERR_READ,
	'SQLITE_IOERR_SHORT_READ,
	'SQLITE_IOERR_WRITE,
	'SQLITE_IOERR_FSYNC,
	'SQLITE_IOERR_DIR_FSYNC,
	'SQLITE_IOERR_TRUNCATE,
	'SQLITE_IOERR_FSTAT,
	'SQLITE_IOERR_UNLOCK,
	'SQLITE_IOERR_RDLOCK,
	'SQLITE_IOERR_DELETE,
	'SQLITE_IOERR_BLOCKED,
	'SQLITE_IOERR_NOMEM,
	'SQLITE_IOERR_ACCESS,
	'SQLITE_IOERR_CHECKRESERVEDLOCK,
	'SQLITE_IOERR_LOCK,
	'SQLITE_IOERR_CLOSE,
	'SQLITE_IOERR_DIR_CLOSE,
	'SQLITE_IOERR_SHMOPEN,
	'SQLITE_IOERR_SHMSIZE,
	'SQLITE_IOERR_SHMLOCK,
	'SQLITE_IOERR_SHMMAP,
	'SQLITE_IOERR_SEEK,
	'SQLITE_IOERR_DELETE_NOENT,
	'SQLITE_IOERR_MMAP,
	'SQLITE_IOERR_GETTEMPPATH,
	'SQLITE_IOERR_CONVPATH,

	'SQLITE_CORRUPT_PLAIN,
	'SQLITE_CORRUPT_VTAB,

	'SQLITE_NOTFOUND,
	'SQLITE_FULL,

	'SQLITE_CANTOPEN_PLAIN,
	'SQLITE_CANTOPEN_NOTEMPDIR,
	'SQLITE_CANTOPEN_ISDIR,
	'SQLITE_CANTOPEN_FULLPATH,
	'SQLITE_CANTOPEN_CONVPATH,

	'SQLITE_PROTOCOL,
	'SQLITE_EMPTY,
	'SQLITE_SCHEMA,
	'SQLITE_TOOBIG,

	'SQLITE_CONSTRAINT_PLAIN,
	'SQLITE_CONSTRAINT_CHECK,
	'SQLITE_CONSTRAINT_COMMITHOOK,
	'SQLITE_CONSTRAINT_FOREIGNKEY,
	'SQLITE_CONSTRAINT_FUNCTION,
	'SQLITE_CONSTRAINT_NOTNULL,
	'SQLITE_CONSTRAINT_PRIMARYKEY,
	'SQLITE_CONSTRAINT_TRIGGER,
	'SQLITE_CONSTRAINT_UNIQUE,
	'SQLITE_CONSTRAINT_VTAB,
	'SQLITE_CONSTRAINT_ROWID,

	'SQLITE_MISMATCH,
	'SQLITE_MISUSE,
	'SQLITE_NOLFS,

	'SQLITE_AUTH_PLAIN,
	'SQLITE_AUTH_USER,

	'SQLITE_FORMAT,
	'SQLITE_RANGE,
	'SQLITE_NOTADB,

	'SQLITE_NOTICE_PLAIN,
	'SQLITE_NOTICE_RECOVER_WAL,
	'SQLITE_NOTICE_RECOVER_ROLLBACK,

	'SQLITE_WARNING_PLAIN,
	'SQLITE_WARNING_AUTOINDEX
	]

sqliteThrowBindError :: String -> IO a
sqliteThrowBindError em = throw $ SQLITE_BIND_ERROR em

newtype NullPointerException = NullPointerException String
	deriving (Typeable, Show)

exceptionHierarchy Nothing (ExType ''NullPointerException)

nullPointerException :: String -> IO a
nullPointerException em = throwIO $ NullPointerException em
