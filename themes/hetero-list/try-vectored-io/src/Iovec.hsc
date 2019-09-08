{-# LANGUAGE DataKinds, TypeOperators, GADTs, ScopedTypeVariables #-}
{-# OPTIONS_GHC -Wall -fno-warn-tabs #-}

module Iovec (Iovec, withIovec, PrepareIovec) where

import Foreign.Ptr
import Foreign.Storable
import Foreign.Marshal
import Foreign.C.Types

import HeteroList

#include <sys/uio.h>

data {-# CTYPE "sys/uio.h" "struct iovec" #-} Iovec

withIovec :: PrepareIovec a => HeteroPtrList a -> (Ptr Iovec -> CInt -> IO b) -> IO b
withIovec ps act = allocaBytes (ln * #{size struct iovec}) $
	\iov0 -> prepareIovec iov0 ps >> act iov0 (fromIntegral ln)
	where ln = lengthHeteroPtrList ps

class PrepareIovec a where
	prepareIovec :: Ptr Iovec -> HeteroPtrList a -> IO ()

iovecSize :: Int
iovecSize = #size struct iovec

instance PrepareIovec '[] where
	prepareIovec _ _ = return ()

instance (Storable a, PrepareIovec as) => PrepareIovec (a : as) where
	prepareIovec iovp (p :-- ps) = do
		poke (castPtr iovp) p
		poke (iovp `plusPtr` sizeOf p) $ sizeOfPtr p
		prepareIovec (iovp `plusPtr` iovecSize) ps

sizeOfPtr :: forall a . Storable a => Ptr a -> Int
sizeOfPtr _ = sizeOf (undefined :: a)
