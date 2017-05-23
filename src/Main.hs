{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE RecursiveDo #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE CPP #-}
module Main where

import           Control.Concurrent (forkIO,threadDelay)
import           Control.Exception
import           Control.Monad (forever, void)
import qualified Data.ByteString.Lazy.Char8 as L8
import           Data.IORef
import           Data.Monoid
import           Device ( getDevice )
import           Hans
import           Hans.IP4.Dhcp.Client (DhcpLease(..),defaultDhcpConfig,dhcpClient)
import           Hans.IP4.Packet (pattern WildcardIP4, readIP4)
import           Hans.Socket

import           GHC.Stats
import           GHC.RTS.Flags
import           GHC.Environment

showExceptions :: String -> IO a -> IO a
showExceptions l m = m `catch` \ e ->
  do print (l, e :: SomeException)
     throwIO e

secs = (*100000)

main :: IO ()
main = do
  ns <- newNetworkStack defaultConfig
  dev <- getDevice ns
  _ <- forkIO $ showExceptions "processPackets" (processPackets ns)
  startDevice dev
  dhcpClient ns defaultDhcpConfig dev >>= \case
    Nothing -> putStrLn "DHCP failed..."
    Just lease -> do
     putStrLn $ "Assigned IP: " ++ show (unpackIP4 (dhcpAddr lease))
     socket <- newUdpSocket ns defaultSocketConfig Nothing WildcardIP4 (Just 8080)
     let sendData = sendto socket (packIP4 10 0 1 2) 8080
         formatData f = L8.pack . show <$> f
     print =<< do putStrLn "" >> getFullArgs
     print =<< do putStrLn "" >> getGCFlags
     print =<< do putStrLn "" >> getConcFlags
     print =<< do putStrLn "" >> getMiscFlags
     print =<< do putStrLn "" >> getDebugFlags
     print =<< do putStrLn "" >> getCCFlags
     print =<< do putStrLn "" >> getProfFlags
     print =<< do putStrLn "" >> getTraceFlags
     print =<< do putStrLn "" >> getTickyFlags
     forever $ do
       sendData =<< formatData getGCStats
