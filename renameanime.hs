#!/usr/local/bin/runghc

{-# OPTIONS_GHC -XPatternSignatures #-}

import System(getArgs)
import System.Directory(renameFile)
import System.FilePath

import Numeric(readHex)
                                   
import Data.Char(toLower)
import Data.Maybe(mapMaybe)
import Data.List(intersperse)

import Text.ParserCombinators.Parsec
import Text.ParserCombinators.Parsec.Prim
import Text.ParserCombinators.Parsec.Combinator
import Text.ParserCombinators.Parsec.Char

square_bracketed = between (char '[') (char ']')
round_bracketed = between (char '[') (char ']')
seperators = spaces <|> skipMany1 (char '_')

word = many1 alphaNum
hexWord = many1 hexDigit
sentence = word `sepBy1` seperators >>= (return . concat . (intersperse " ")) <?> "sentence"

group = square_bracketed sentence <?> "group"
series = sentence <?> "series name"
episode_number_string = many1 digit <?> "episode number"
additional_info = round_bracketed sentence <?> "additional info"
checksum_string = square_bracketed hexWord <?> "checksum"

type Group = String
type Checksum = Integer

data Episode = Episode { 
    ep_group :: Maybe Group,
    ep_series :: String,
    ep_number :: Integer,
    ep_checksum :: Maybe Checksum }

episode = do
    maybe_group :: Maybe Group <- optionMaybe group
    optional seperators
    series <- series
    optional seperators
    char '-'
    optional seperators
    episode_number_string <- episode_number_string
    optional seperators
    optional (additional_info `sepBy1` (optional seperators))
    optional seperators
    maybe_checksum_string <- optionMaybe checksum_string
    return $ Episode {
        ep_group = maybe_group,
        ep_series = series,
        ep_number = read episode_number_string,
        ep_checksum = fmap (fst . head . readHex) maybe_checksum_string
    }

parseEpisode :: FilePath -> Either ParseError Episode
parseEpisode filename = parse episode filename filename

episodeToFileName :: Episode -> String
episodeToFileName (Episode { ep_series = series, ep_number = number }) = series ++ " - " ++ (show number)
                    

readShouldProceed :: IO Bool
readShouldProceed = do
    putStr "Continue [yn]: "
    result <- getLine
    case (map toLower result) of
        "y" -> return True
        "n" -> return False
        _ -> readShouldProceed

unzipEithers :: [Either a b] -> ([a], [b])
unzipEithers = foldr unzipEitherF ([], [])
  where unzipEitherF (Left left) (lefts, rights) = (left:lefts, rights)
        unzipEitherF (Right right) (lefts, rights) = (lefts, right:rights)                

main :: IO ()
main = do
    to_rename <- getArgs 
    let (errors, renamings) = unzipEithers [either Left (Right . obtainFilenames) either_parsed_episode 
                                              | path <- to_rename
                                              , let (directory, filename) = splitFileName path
                                                    (filename_root, extension) = splitExtensions filename
                                                    either_parsed_episode = parseEpisode filename_root
                                                    obtainFilenames parsed_episode = (path, directory `combine` ((episodeToFileName parsed_episode) `addExtension` extension))]
    
    if (length errors) > 0
      then do
        putStrLn "Could not understand the following:"
        mapM_ print errors 
        putStrLn ""
      else return ()   
    
    if (length renamings) > 0
      then do
        putStrLn "The proposed changes are as follows:"
        mapM_ putStrLn (map (\(old, new) -> old ++ " -> " ++ new) renamings)
        should_proceed <- readShouldProceed
    
        if should_proceed 
          then mapM_ (uncurry renameFile) renamings 
          else return ()                                                    
      else putStrLn "There is nothing to do!"