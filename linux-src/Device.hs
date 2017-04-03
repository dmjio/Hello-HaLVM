{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE LambdaCase #-}
module Device where

import Hans
import System.Environment (getArgs)
import Data.ByteString.Char8 hiding (putStrLn)
import Data.Maybe (listToMaybe)

getDevice :: NetworkStack -> IO Device
getDevice ns =
  listToMaybe <$> getArgs >>= \case
    Nothing -> error "Please enter tap device name (example: ./hello-halvm-tap tap0)"
    Just deviceName -> addDevice ns (pack deviceName) defaultDeviceConfig
