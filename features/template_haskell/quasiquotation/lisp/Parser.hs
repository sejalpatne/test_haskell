{-# LANGUAGE TemplateHaskell #-}

module Parser (lexer, parseExp, parseDec, parsePat, parseType) where

import Control.Applicative
import Control.Arrow
import Language.Haskell.TH

import Lexer

parseExp :: [Token] -> (ExpQ, [Token])
parseExp (Con v : ts) = (conE $ mkName v, ts)
parseExp (Var v : ts) = (varE $ mkName v, ts)
parseExp (Nat n : ts) = (litE $ integerL n, ts)
parseExp (Str s : ts) = (litE $ stringL s, ts)
parseExp (OP : Comma : ts) = let
	(tpl, ts') = parseTupleCon ts in
	(conE . mkName $ "(," ++ tpl, ts')
parseExp (OP : CP : ts) = (conE '(), ts)
parseExp (OP : Lambda : OP : ts) = let
	(ps, ts') = parsePatList ts
	Just (es, ts'') = parseList ts' in
	(lamE ps $ last es, ts'')
parseExp (OP : ts) = let
	(es, ts') = parseListOrTuple ts in
	(either (foldl1 appE) tupE es, ts')
parseExp (OB : ts) = let
	(es, ts') = parseHsList ts in
	(listE es, ts')
parseExp ts = error $ "parseExp: parse error: " ++ show ts

parseListOrTuple ::
	[Token] -> (Either [ExpQ] [ExpQ], [Token])
parseListOrTuple ts = maybe
	(first Right $ parseTupleExp ts)
	(first Left) $ parseList ts

parseList :: [Token] -> Maybe ([ExpQ], [Token])
parseList (Comma : _) = Nothing
parseList (CP : ts) = Just ([], ts)
parseList ts = let (e, ts') = parseExp ts in
	case parseList ts' of
		Just (es, ts'') -> Just (e : es, ts'')
		_ -> Nothing

parseHsList :: [Token] -> ([ExpQ], [Token])
parseHsList (CB : ts) = ([], ts)
parseHsList ts = case parseExp ts of
	(e, CB : ts') -> ([e], ts')
	(e, Comma : ts') -> let
		(es, ts'') = parseHsList ts' in
		(e : es, ts'')
	_ -> error $ "parseHsList: parse error: " ++ show ts

parseTupleCon :: [Token] -> (String, [Token])
parseTupleCon (CP : ts) = (")", ts)
parseTupleCon (Comma : ts) = let
	(tpl, ts') = parseTupleCon ts in
	(',' : tpl, ts')
parseTupleCon ts =
	error $ "parseTupleCon: parse error: " ++ show ts

parseTupleExp :: [Token] -> ([ExpQ], [Token])
parseTupleExp ts = case parseExp ts of
	(e, CP : ts') -> ([e], ts')
	(e, Comma : ts') -> let
		(es, ts'') = parseTupleExp ts' in
		(e : es, ts'')
	_ -> error $
		"parseTupleExp: parse error: " ++ show ts

parseDec :: [Token] -> DecsQ
parseDec (OP : Define : Var v : ts) = let
	(e, CP : ts') = parseExp ts in
	(:)	<$> valD (varP $ mkName v) (normalB e) []
		<*> parseDec ts'
parseDec (OP : Define : OP : Var v : ts) = let
	(ps, ts') = parsePatList ts
	Just (es, ts'') = parseList ts' in
	(:)	<$> valD
			(varP $ mkName v)
			(normalB . lamE ps $ last es)
			[]
		<*> parseDec ts''
parseDec [] = return []
parseDec ts = error $ show ts

parsePat :: [Token] -> (PatQ, [Token])
parsePat (Var v : ts) = (varP $ mkName v, ts)
parsePat (OP : OP : Comma : ts) = let
	(tpl, ts') = parseTupleCon ts
	(ps, ts'') = parsePatList ts' in
	(conP (mkName $ "(," ++ tpl) ps, ts'')
parsePat (OP : Con v : ts) = let
	(ps, ts') = parsePatList ts in
	(conP (mkName v) ps, ts')
parsePat (OB : ts) = let
	(ps, ts') = parsePatHsList ts in
	(listP ps, ts')
parsePat ts =
	error $ "parsePattern: parse error: " ++ show ts

parsePatList :: [Token] -> ([PatQ], [Token])
parsePatList (CP : ts) = ([], ts)
parsePatList ts = let
	(p, ts') = parsePat ts
	(ps, ts'') = parsePatList ts' in
	(p : ps, ts'')

parsePatHsList :: [Token] -> ([PatQ], [Token])
parsePatHsList (CB : ts) = ([], ts)
parsePatHsList ts = case parsePat ts of
	(p, CB : ts') -> ([p], ts')
	(p, Comma : ts') -> let
		(ps, ts'') = parsePatHsList ts' in
		(p : ps, ts'')
	_ -> error $ "parsePatHsList: parse error: " ++
		show ts

parseType :: [Token] -> (TypeQ, [Token])
parseType (Con v : ts) = (conT $ mkName v, ts)
parseType (OP : ts) = let
	(tps, ts') = parseTypeList ts in
	(foldl1 appT tps, ts')
parseType (OB : CB : ts) = (listT, ts)
parseType (OB : ts) = let
	(tp, CB : ts') = parseType ts in
	(listT `appT` tp, ts')
parseType ts = error $ "parseType: parse error: " ++ show ts

parseTypeList :: [Token] -> ([TypeQ], [Token])
parseTypeList (CP : ts) = ([], ts)
parseTypeList ts = let
	(tp, ts') = parseType ts
	(tps, ts'') = parseTypeList ts' in
	(tp : tps, ts'')
