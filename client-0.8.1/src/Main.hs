{-# language DataKinds #-}
{-# language TypeOperators #-}
{-# language OverloadedStrings #-}
module Main where

import Data.Proxy
import Network.HTTP.Client hiding (Proxy)
import Servant.API
import Servant.Client
import Network.Wai.Handler.Warp
import qualified Data.Text as T
import Control.Arrow (right)
import Control.Monad.Trans.Except (ExceptT, runExceptT)


type TestRoutes =
       "hello" :> Get '[JSON] Int
  :<|> "getBodyTest" :> ReqBody '[PlainText] String :> Get '[PlainText] String
  :<|> "formUrlEncodedTest" :> ReqBody '[FormUrlEncoded] SomeData :> Post '[FormUrlEncoded] SomeData


data SomeData = Stuff { foo :: Int, bar :: String} deriving (Show)

instance FromFormUrlEncoded SomeData where
    fromFormUrlEncoded fields =
        Stuff
          <$> (right read $ m2e $ lookup "foo" fields)
          <*> (m2e $ lookup "bar" fields)

instance ToFormUrlEncoded SomeData where
    toFormUrlEncoded sd = [ ("foo", T.pack $ show $ foo sd)
                          , ("bar", T.pack $ bar $ sd)
                          ]

m2e :: Maybe T.Text -> Either String String
m2e Nothing = Left "Not found"
m2e (Just a) = Right $ T.unpack a

hello :: Manager -> BaseUrl -> ClientM Int
getBodyTest :: String -> Manager -> BaseUrl -> ClientM String
formUrlEncodedTest :: SomeData -> Manager -> BaseUrl -> ClientM SomeData

hello :<|> getBodyTest :<|> formUrlEncodedTest = client api

api :: Proxy TestRoutes
api = Proxy

main :: IO ()
main = do
  putStrLn "Test client running on servant-client-0.8.1"

  let url = BaseUrl Http "localhost" 8081 ""
  let manager = undefined -- Servant-client ghcjs doesn't use this

  putStrLn "Requesting hello"
  helloRes <- runExceptT (hello manager url)
  putStrLn ("Hello: " ++ show helloRes)

  putStrLn ""

  putStrLn "Requesting bodyTest"
  bodyTestRes <- runExceptT (getBodyTest "This is the body I've sent" manager url )
  putStrLn ("getBodyTest: " ++ show bodyTestRes)

  putStrLn ""

  putStrLn "Requesting formUrlEncodedTest"

  let testData = Stuff 42 "formUrlEncodedTest"
  formUrlEncodedRes <- runExceptT (formUrlEncodedTest testData manager url )
  putStrLn ("formUrlEncodedTest: " ++ show formUrlEncodedRes)
