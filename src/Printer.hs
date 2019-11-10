{-# OPTIONS -Wno-unused-imports #-}
module Printer where

import Rainbox
import Rainbow ((&))
import qualified Rainbow
import Rainbow.Types
import Data.Sequence (Seq)
import qualified Data.Sequence as Seq
import Data.Text (Text, pack, unpack)

import Data.Binary
import Data.Binary.Orphans
import CommandRecord
import Daemon
import Control.Monad

import Data.Map.Strict (Map, fromList, (!))
import Data.List
import Data.List.Split
import Data.Foldable
import Data.String.Conversions

-- import Data.Time.Clock
-- import Data.Time.Format (defaultTimeLocale)
-- import Data.Time.Clock.POSIX
-- import System.Posix.Files
import System.Locale
import Data.Thyme.Clock
import Data.Thyme.Format

stationColumn :: [(String, Rainbow.Radiant, Alignment Vertical)] -> Seq Cell
stationColumn = fcol . xyz . Seq.fromList . fmap (\(v,c,a) -> myCell defaultText c a (pack v))

horizontalStationTable :: [[String]] -> Rainbox.Box Rainbox.Vertical
horizontalStationTable vvv
  = Rainbox.tableByRows
  . Seq.fromList
  $ (stationColumn <$> (fmap (\x -> zip3 x (colssss) aliii) vvv ))

aliii :: [Alignment Vertical]
aliii = [
    Rainbox.left
    , Rainbox.left
    , Rainbox.left
        ]

colssss :: [Rainbow.Radiant]
colssss = [
    Rainbow.blue
  , Rainbow.white
  , Rainbow.green
  ]

fcol :: Seq Cell -> Seq Cell
fcol =
    Seq.adjust (\x -> x { _background = defaultText}) 0

xyz :: Seq Cell -> Seq Cell
xyz = (Rainbox.intersperse (separator defaultText 1))

myCell :: Rainbow.Radiant -> Rainbow.Radiant -> Alignment Vertical -> Text -> Rainbox.Cell
myCell b f a vv = Rainbox.Cell v Rainbox.top a b
  where
    v = Seq.singleton . Seq.singleton $ (Rainbow.chunk vv & Rainbow.fore f)

defaultText :: Rainbow.Radiant
defaultText = Radiant (Color Nothing) (Color Nothing)

printRecords :: Bool -> IO ()
printRecords _ = do
  print "test"
  decodeFileOrFail crFile >>= \case
    Right p -> do
      pp <- getPendingRecords
      let tableV = fmap (renderCr) (p ++ pp)
      mapM_ Rainbow.putChunk . toList $ render $ horizontalStationTable tableV
    Left e -> error $ show e

renderCr :: CommandRecord -> [String]
renderCr cr = [
    myFormatTime $ CommandRecord.timedate cr
  , cs $ CommandRecord.command cr
  , cs $ CommandRecord.path cr
  ]

myFormatTime :: FormatTime t => t -> String
myFormatTime fs = formatTime defaultTimeLocale "%x %r" fs