{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE ScopedTypeVariables #-}

-- | Tests for GenValidity instances
--
-- You will need @TypeApplications@ to use these.
module Test.Validity.GenValidity
    ( genValiditySpec
    , genValidSpec
    , genInvalidSpec
    , genValidGeneratesValid
    , genGeneratesValid
    , genInvalidGeneratesInvalid
    , genGeneratesInvalid
    ) where

import Data.Data

import Data.GenValidity

import Test.Hspec
import Test.QuickCheck

import Test.Validity.GenValidity.Property
import Test.Validity.Utils

-- | A spec for properties of 'GenValid' and 'GenInvalid' instances.
--
-- In general it is a good idea to add this spec to your test suite if you
-- write a custom implementation of @genValid@ or @genInvalid@.
--
-- __It is not a good idea to use this function if invalid values are broken in such a way that 'Show' or even 'isValid' is broken.__
-- In that case you probably want 'genValidSpec'.
--
-- Example usage:
--
-- > genValiditySpec @Int
genValiditySpec ::
       forall a. (Typeable a, Show a, GenValid a, GenInvalid a)
    => Spec
genValiditySpec = do
    genValidSpec @a
    genInvalidSpec @a

-- | A @Spec@ that specifies that @genValid@ only generates valid data.
--
-- In general it is a good idea to add this spec to your test suite if you
-- write a custom implementation of @genValid@.
--
-- Example usage:
--
-- > genValidSpec @Int
genValidSpec ::
       forall a. (Typeable a, Show a, GenValid a)
    => Spec
genValidSpec =
    parallel $ do
        let name = nameOf @a
        describe ("GenValid " ++ name) $
            describe ("genValid   :: Gen " ++ name) $
            it ("only generates valid \'" ++ name ++ "\'s") $
            forAllShrink genValid shrinkValid $ shouldBeValid @a

-- | A @Spec@ that specifies that @genInvalid@ only generates invalid data.
--
-- Note that it is not a good idea to use this function if invalid values are broken in such a way that 'Show' or even 'isValid' is broken.
--
-- Example usage:
--
-- > genInvalidSpec @Rational
genInvalidSpec ::
       forall a. (Typeable a, Show a, GenInvalid a)
    => Spec
genInvalidSpec =
    parallel $ do
        let name = nameOf @a
        describe ("GenInvalid " ++ name) $
            describe ("genInvalid :: Gen " ++ name) $
            it ("only generates invalid \'" ++ name ++ "\'s") $
            forAllShrink genInvalid shrinkInvalid $ shouldBeInvalid @a

-- | @genValid@ only generates valid data
--
-- prop> genValidGeneratesValid @()
-- prop> genValidGeneratesValid @Bool
-- prop> genValidGeneratesValid @Ordering
-- prop> genValidGeneratesValid @Char
-- prop> genValidGeneratesValid @Int
-- prop> genValidGeneratesValid @Float
-- prop> genValidGeneratesValid @Double
-- prop> genValidGeneratesValid @Integer
-- prop> genValidGeneratesValid @(Maybe Int)
-- prop> genValidGeneratesValid @[Int]
genValidGeneratesValid ::
       forall a. (Show a, GenValid a)
    => Property
genValidGeneratesValid = genGeneratesValid @a genValid shrinkValid

-- | @genValid@ only generates invalid data
--
-- prop> genInvalidGeneratesInvalid @Rational
-- prop> genInvalidGeneratesInvalid @Rational
-- prop> genInvalidGeneratesInvalid @(Maybe Rational)
-- prop> genInvalidGeneratesInvalid @[Rational]
genInvalidGeneratesInvalid ::
       forall a. (Show a, GenInvalid a)
    => Property
genInvalidGeneratesInvalid = genGeneratesInvalid @a genInvalid shrinkInvalid
