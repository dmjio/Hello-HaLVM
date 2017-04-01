{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE CPP #-}
module Main where

import           Control.Concurrent (forkIO,threadDelay)
import           Control.Exception
import           Control.Monad (forever, forM_, forM)
import qualified Data.ByteString.Char8 as S8
import qualified Data.ByteString.Lazy.Char8 as L8
import           Data.IORef
import           Data.Monoid
import           Hans
import           Hans.Device
import           Hans.Dns
import           Hans.IP4.Dhcp.Client (DhcpLease(..),defaultDhcpConfig,dhcpClient)
import           Hans.IP4.Packet (pattern WildcardIP4)
import           Hans.Nat
import           Hans.Socket
import           System.Environment (getArgs)
import           System.Exit (exitFailure)

import           Device ( getDevice )

main :: IO ()
main = do
  ns <- newNetworkStack defaultConfig
  dev <- getDevice ns
  startDevice dev
  maybeLease <- dhcpClient ns defaultDhcpConfig dev
  case maybeLease of
    Nothing -> putStrLn "DHCP failed..."
    Just lease -> do
     counter <- newIORef 0
     socket <- sListen ns defaultSocketConfig (dhcpAddr lease) 80 10
     handleConnections counter socket
     forkIO $ processPackets ns
     forever $ threadDelay (secs 10)
       where
         secs = (*1000000)
         handleConnections counter sock = forkIO . forever $ do
           client <- sAccept (sock :: TcpListenSocket IP4)
           n <- L8.pack . show <$> do atomicModifyIORef' counter $ \x -> (x + 1, x)
           () <$ forkIO (handleClient n client)

handleClient :: L8.ByteString -> TcpSocket IP4 -> IO ()
handleClient n sock = do
  sWrite sock $ "HTTP/1.0 200 OK\r\nContent-Length: 5\r\n\r\nHaLVM says Hello! You are request #" <> n <> "\r\n"
  sClose sock
                  
