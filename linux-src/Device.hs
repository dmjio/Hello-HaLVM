{-# LANGUAGE OverloadedStrings #-}
module Device where

import Hans
import System.Environment
import Data.ByteString.Char8

getDevice :: NetworkStack -> IO Device
getDevice ns = do
  [deviceName] <- getArgs 
  addDevice ns (pack deviceName) defaultDeviceConfig
