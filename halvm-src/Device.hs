module Device where

import           Hans
import           Hypervisor.Console
import           Hypervisor.XenStore

getDevice :: NetworkStack -> IO Device
getDevice ns = do
  () <$ initXenConsole
  xs <- initXenStore
  [nic] <- listDevices xs
  addDevice xs ns nic defaultDeviceConfig
