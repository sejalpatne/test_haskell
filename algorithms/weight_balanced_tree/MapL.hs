module MapL (Map, empty, lookup, insert, delete) where

type Map k a = [(k, a)]

empty :: Map k a
empty = []

insert :: k -> a -> Map k a -> Map k a
insert = curry (:)

delete :: Eq k => k -> Map k a -> Map k a
delete = filter . (. fst) . (/=)

-- lookup :: Eq k => k -> Map k a -> Maybe a
-- lookup = ...
