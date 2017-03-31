{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE LambdaCase #-}
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
import           Hypervisor.Console
import           Hypervisor.XenStore
import           System.Environment (getArgs)
import           System.Exit (exitFailure)

main :: IO ()
main = do
  () <$ initXenConsole
  putStrLn "Initializing HaLVM"
  xs <- initXenStore
  ns <- newNetworkStack defaultConfig
  [nic] <- listDevices xs
  print nic
  dev <- addDevice xs ns nic defaultDeviceConfig
  startDevice dev
  maybeLeaseAddr <- dhcpClient ns defaultDhcpConfig dev
  case maybeLeaseAddr of
    Nothing -> putStrLn "DHCP failed..."
    Just lease -> do
     counter <- newIORef 0
     socket <- sListen ns defaultSocketConfig (dhcpAddr lease) 9001 10
     handleConnections counter socket
     forkIO $ processPackets ns
     forever $ threadDelay (secs 10)
       where
         handleConnections counter sock = forkIO . forever $ do
           client <- sAccept (sock :: TcpListenSocket IP4)
           n <- L8.pack . show <$> do atomicModifyIORef' counter $ \x -> (x + 1, x)
           () <$ forkIO (handleClient n client)

handleClient :: L8.ByteString -> TcpSocket IP4 -> IO ()
handleClient n sock = do
  sWrite sock $ "HTTP/1.0 200 OK\r\nContent-Length: 5\r\n\r\nHaLVM says Hello! You are request #" <> n <> "\r\n"
  sClose sock
                  
