{-# language BangPatterns #-}
{-# language OverloadedStrings #-}
module Main where


import Data.ByteString.Builder (toLazyByteString, shortByteString, string8)


main :: IO ()
main = do
  putStrLn "Testing the ghcjs 'unhandled primop' error"

  -- Reproduces the issue
  putStrLn "step 1"
  let !step1 = shortByteString "hello"
  putStrLn "step 2"
  let !step2 = toLazyByteString step1

  return ()
