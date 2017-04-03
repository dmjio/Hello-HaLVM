{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE RecursiveDo #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE CPP #-}
module Main where

import           Control.Concurrent (forkIO,threadDelay)
import           Control.Exception
import           Control.Monad (forever, forM_, forM, replicateM_)
import qualified Data.ByteString.Char8 as S8
import qualified Data.ByteString.Lazy.Char8 as L8
import qualified Data.Foldable as F
import           Data.IORef
import           Data.Monoid
import           Device ( getDevice )
import           GHC.Environment ( getFullArgs )
import           GHC.RTS.Flags
import           GHC.Stats
import           Hans
import           Hans.Device
import           Hans.Dns
import           Hans.IP4.Dhcp.Client (DhcpLease(..),defaultDhcpConfig,dhcpClient)
import           Hans.IP4.Packet (pattern WildcardIP4)
import           Hans.Nat
import           Hans.Socket
import           System.Environment (getArgs)
import           System.Exit (exitFailure)

showExceptions :: String -> IO a -> IO a
showExceptions l m = m `catch` \ e ->
  do print (l, e :: SomeException)
     throwIO e

main :: IO ()
main = do
  ns <- newNetworkStack defaultConfig
  dev <- getDevice ns
  _ <- forkIO $ showExceptions "processPackets" (processPackets ns)
  startDevice dev
  dhcpClient ns defaultDhcpConfig dev >>= \case
    Nothing -> putStrLn "DHCP failed..."
    Just lease -> do
     counter <- newIORef 0
     putStrLn $ "Assigned IP: " ++ show (unpackIP4 (dhcpAddr lease))
     socket <- sListen ns defaultSocketConfig (dhcpAddr lease) 80 10
     handleConnections counter socket
     forever $ threadDelay (secs 10)
       where
         secs = (*1000000)
         handleConnections counter socket = forkIO . forever $ do
           client <- sAccept (socket :: TcpListenSocket IP4)
           n <- L8.pack . show <$> do atomicModifyIORef' counter $ \x -> (x + 1, x)
           () <$ forkIO (handleClient n client)

handleClient :: L8.ByteString -> TcpSocket IP4 -> IO ()
handleClient n sock = do
  let body = "HaLVM says Hello! You are request " <> n
      html = "<!doctype html><html><head></head><body>" <> body <> "</body></html>"
      size = L8.pack $ show (L8.length html)
  sWrite sock $ L8.concat [
     "HTTP/1.0 200 OK\r\nContent-Length: "
    , size
    , "\r\n\r\n"
    , html
    , "\r\n"
    ]
  sClose sock
                  
