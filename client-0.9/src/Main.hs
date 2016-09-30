{-# language DataKinds #-}
{-# language TypeOperators #-}
{-# language OverloadedStrings #-}
{-# language DeriveGeneric #-}
module Main where

import Data.Proxy
import Network.HTTP.Client hiding (Proxy)
import Servant.API
import Servant.Client
import Network.Wai.Handler.Warp
import qualified Data.Text as T
import Control.Arrow (right)
import Control.Monad.Trans.Except (ExceptT, runExceptT)
import Web.Internal.FormUrlEncoded
import GHC.Generics


type TestRoutes =
       "hello" :> Get '[JSON] Int
  :<|> "getBodyTest" :> ReqBody '[PlainText] String :> Get '[PlainText] String
  :<|> "formUrlEncodedTest" :> ReqBody '[FormUrlEncoded] SomeData :> Post '[FormUrlEncoded] SomeData


data SomeData = Stuff { foo :: Int, bar :: String} deriving (Show, Generic)

instance FromForm SomeData where
instance ToForm SomeData where

hello :: ClientM Int
getBodyTest :: String -> ClientM String
formUrlEncodedTest :: SomeData -> ClientM SomeData

hello :<|> getBodyTest :<|> formUrlEncodedTest = client api

api :: Proxy TestRoutes
api = Proxy

main :: IO ()
main = do
  putStrLn "Test client running on servant-client-0.9"


  let url = BaseUrl Http "localhost" 8081 ""
  let manager = undefined -- Servant-client ghcjs doesn't use this
  let env = ClientEnv manager url

  putStrLn "Requesting hello"
  helloRes <- runClientM hello env
  putStrLn ("Hello: " ++ show helloRes)

  putStrLn ""

  putStrLn "Requesting bodyTest"
  bodyTestRes <- runClientM (getBodyTest "This is the body I've sent") env
  putStrLn ("getBodyTest: " ++ show bodyTestRes)

  putStrLn ""

  putStrLn "Requesting formUrlEncodedTest"

  let testData = Stuff 42 "formUrlEncodedTest"
  formUrlEncodedRes <- runClientM (formUrlEncodedTest testData) env
  putStrLn ("formUrlEncodedTest: " ++ show formUrlEncodedRes)

