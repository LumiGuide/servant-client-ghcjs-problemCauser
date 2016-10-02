{-# language DataKinds #-}
{-# language TypeOperators #-}
{-# language OverloadedStrings #-}
module Main where

import Servant
import Servant.API
import Servant.Server
import Network.Wai.Handler.Warp
import qualified Data.Text as T
import Control.Arrow (right)


type TestRoutes =
       "hello" :> Get '[JSON] Int
  :<|> "getBodyTest" :> ReqBody '[PlainText] String :> Get '[PlainText] String
  :<|> "formUrlEncodedTest" :> ReqBody '[FormUrlEncoded] SomeData :> Post '[FormUrlEncoded] SomeData
  :<|> "0.8.1" :> Raw
  :<|> "0.9" :> Raw
  :<|> "primop" :> Raw


data SomeData = Stuff { foo :: Int, bar :: String}

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



server :: Server TestRoutes
server =
       return 1337
  :<|> return -- Just bounce back what we got
  :<|> return
  :<|> serveDirectory "../client-0.8.1/dist/build/client/client.jsexe"
  :<|> serveDirectory "../client-0.9/dist/build/client/client.jsexe"
  :<|> serveDirectory "../ghcjs-unhandled-primop/dist/build/client/client.jsexe"

testRoutesAPI :: Proxy TestRoutes
testRoutesAPI = Proxy

app :: Application
app = serve testRoutesAPI server

main :: IO ()
main = run 8081 app
