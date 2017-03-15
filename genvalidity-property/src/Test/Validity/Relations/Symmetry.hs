{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Test.Validity.Relations.Symmetry
    ( symmetricOnElems
    , symmetryOnGens
    , symmetryOnValid
    , symmetry
    , symmetryOnArbitrary
    ) where

import Data.GenValidity

import Test.QuickCheck

import Test.Validity.Property.Utils

-- |
--
-- \[
--   Symmetric(\prec)
--   \quad\equiv\quad
--   \forall a, b: (a \prec b) \Leftrightarrow (b \prec a)
-- \]
symmetricOnElems
    :: (a -> a -> Bool) -- ^ A relation
    -> a
    -> a -- ^ Two elements
    -> Bool
symmetricOnElems func a b = func a b <==> func b a

symmetryOnGens
    :: Show a
    => (a -> a -> Bool) -> Gen (a, a) -> Property
symmetryOnGens func gen = forAll gen $ uncurry $ symmetricOnElems func

-- |
--
-- prop> symmetryOnValid ((==) @Double)
-- prop> symmetryOnValid ((/=) @Double)
symmetryOnValid
    :: (Show a, GenValid a)
    => (a -> a -> Bool) -> Property
symmetryOnValid func = symmetryOnGens func genValid

-- |
--
-- prop> symmetry ((==) @Int)
-- prop> symmetry ((/=) @Int)
symmetry
    :: (Show a, GenUnchecked a)
    => (a -> a -> Bool) -> Property
symmetry func = symmetryOnGens func genUnchecked

-- |
--
-- prop> symmetryOnArbitrary ((==) @Int)
-- prop> symmetryOnArbitrary ((/=) @Int)
symmetryOnArbitrary
    :: (Show a, Arbitrary a)
    => (a -> a -> Bool) -> Property
symmetryOnArbitrary func = symmetryOnGens func arbitrary
