{-# LANGUAGE ScopedTypeVariables, TypeApplications #-}
{-# LANGUAGE GADTs, DataKinds, TypeOperators #-}
{-# OPTIONS_GHC -Wall -fno-warn-tabs #-}

module Iovec (Iovec, withIovec, PrepareIovec) where

import Foreign.Ptr (Ptr, castPtr, plusPtr)
import Foreign.Storable (Storable, sizeOf, poke)
import Foreign.Marshal (allocaBytes)
import Foreign.C.Types (CInt)

import HeteroList (HeteroPtrList(..), lengthHeteroPtrList)

#include <sys/uio.h>

data {-# CTYPE "sys/uio.h" "struct iovec" #-} Iovec

iovecSize :: Int
iovecSize = #size struct iovec

withIovec ::
	PrepareIovec a => HeteroPtrList a -> (Ptr Iovec -> CInt -> IO b) -> IO b
withIovec ps act = allocaBytes (ln * iovecSize) $ \iov0 ->
	prepareIovec iov0 ps >> act iov0 (fromIntegral ln)
	where ln = lengthHeteroPtrList ps

class PrepareIovec a where
	prepareIovec :: Ptr Iovec -> HeteroPtrList a -> IO ()

instance PrepareIovec '[] where
	prepareIovec _ _ = return ()

instance (Storable a, PrepareIovec as) => PrepareIovec (a : as) where
	prepareIovec iovp (p :-- ps) = do
		poke (castPtr iovp) p
		poke (iovp `plusPtr` sizeOf p) $ sizeOfPtr p
		prepareIovec (iovp `plusPtr` iovecSize) ps

sizeOfPtr :: forall a . Storable a => Ptr a -> Int
sizeOfPtr _ = sizeOf @a undefined
