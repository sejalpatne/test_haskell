{-# LANGUAGE TypeFamilies, GADTs #-}
{-# LANGUAGE DataKinds, KindSignatures, TypeOperators #-}
{-# LANGUAGE UndecidableInstances, FlexibleInstances #-}
{-# OPTIONS_GHC -Wall -fno-warn-tabs #-}

import Data.Word

import GHC.TypeNats

data Bit = O | I deriving Show

andB, orB :: Bit -> Bit -> Bit
andB I I = I
andB _ _ = O
orB O O = O
orB _ _ = I

notB :: Bit -> Bit
notB O = I
notB I = O

data Tuple (n :: Nat) a where
	E :: Tuple 0 a
	(:+) :: a -> Tuple (n - 1) a -> Tuple n a

class ToList k where
	toList :: k a -> [a]

instance {-# OVERLAPPING #-} ToList (Tuple 0) where
	toList _ = []

instance ToList (Tuple (n - 1)) => ToList (Tuple n) where
	toList E = []
	toList (x :+ xs) = x : toList xs

infixr :+

{-
data family Tuple (n :: Nat) a where
	Tuple 0 a = E
	Tuple n a = a :+ Tuple (n - 1) a
-}

type Id = Word8

data Gate (i :: Nat) (o :: Nat) = Gate (Tuple (i + o) Id) (Fun i o Bit Bit)

type family Fun (i :: Nat) (o :: Nat) a b where
	Fun 0 o a b = Tuple o b
	Fun i o a b = a -> Fun (i - 1) o a b

mkAndGate, mkOrGate :: Id -> Id -> Id -> Gate 2 1
mkAndGate i1 i2 o = Gate (i1 :+ i2 :+ o :+ E) $ ((:+ E) .) . andB
mkOrGate i1 i2 o = Gate (i1 :+ i2 :+ o :+ E) $ ((:+ E) .) . orB

mkNotGate :: Id -> Id -> Gate 1 1
mkNotGate i o = Gate (i :+ o :+ E) $ (:+ E) . notB
