{-# LANGUAGE OverloadedStrings, FlexibleContexts, TypeFamilies, QuasiQuotes, TemplateHaskell, DeriveGeneric #-}
module Main where
{-| Semester 2 assignment for CI285, University of Brighton
    Jim Burton <j.burton@brighton.ac.uk>
-}
import           System.Log.Logger ( updateGlobalLogger
                                   , rootLoggerName
                                   , setLevel
                                   , debugM
                                   , Priority(..)
                                   )
import           Control.Monad          (msum)
import           Happstack.Server  
import           Database.SQLite.Simple

import           WeatherService.Service

{-| Entry point. Connects to the database and passes the connection to the
routing function. -}
main :: IO()
main = do
  updateGlobalLogger rootLoggerName (setLevel INFO) -- change level to DEBUG for testing
  conn <- open "data/np-weather.db"
  simpleHTTP nullConf $  do
    setHeaderM "Content-Type" "application/json"
    msum [
      dirs "weather/date" $ do method [GET, POST]
                               path $ \d -> dayHandler d conn
      , dirs "weather/date" $ do method PUT
                                 path $ \d -> path $ \t -> dayPutHandler d t conn
      , dirs "weather/range" $ do method GET
                                  path $ \d -> path $ \t -> rangeHandler d t conn
      , dirs "weather/max" $ do method GET
                                path $ \d -> path $ \t -> maxHandler d t conn
      , dirs "weather/above" $ do method GET
                                  path $ \d -> aboveHandler d conn
      ]
