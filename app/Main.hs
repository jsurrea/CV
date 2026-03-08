{-# LANGUAGE OverloadedStrings #-}
module Main where

import           Control.Monad         (forM_)
import           Data.Aeson            (Value (..), object, (.=))
import qualified Data.Aeson.Key        as Key
import qualified Data.Aeson.KeyMap     as KM
import qualified Data.Vector           as V
import           Data.Function         (on)
import           Data.List             (find, groupBy, sortBy)
import           Data.Ord              (comparing)
import           Data.Maybe            (fromMaybe)
import qualified Data.Text             as T
import qualified Data.Text.IO          as TIO
import           Data.Yaml             (decodeFileThrow)
import           System.Exit           (die)
import           Text.Mustache         (automaticCompile, substitute)

-- | Entry point: read profile YAML and render all section templates.
main :: IO ()
main = do
  profile <- decodeFileThrow "data/profile.yaml" :: IO Value
  putStrLn "Loaded data/profile.yaml"

  let sections =
        [ ("header",        headerCtx profile)
        , ("summary",       summaryCtx profile)
        , ("education",     educationCtx profile)
        , ("experience",    experienceCtx profile)
        , ("publications",  publicationsCtx profile)
        , ("volunteering",  volunteerCtx profile)
        , ("awards",        awardsCtx profile)
        , ("certifications", certificatesCtx profile)
        ]

  forM_ sections $ \(name, ctx) ->
    renderSection name ctx

  putStrLn "All sections generated."

-- | Compile and render a single Mustache section template.
renderSection :: String -> Value -> IO ()
renderSection name ctx = do
  let tmplName = name ++ ".tex.mustache"
      outPath  = "sections/" ++ name ++ ".tex"
  result <- automaticCompile ["sections"] tmplName
  case result of
    Left err   -> die ("Template error in " ++ tmplName ++ ": " ++ show err)
    Right tmpl -> do
      TIO.writeFile outPath (substitute tmpl ctx)
      putStrLn ("  Generated: " ++ outPath)

-- ─── Context builders ─────────────────────────────────────────────────────────

headerCtx :: Value -> Value
headerCtx p = object
  [ "name"           .= getStr ["basics", "name"] p
  , "email"          .= getStr ["basics", "email"] p
  , "phone"          .= getStr ["basics", "phone"] p
  , "website_url"    .= getStr ["basics", "url"] p
  , "website_label"  .= T.pack "jsurrea.github.io"
  , "linkedin_url"   .= getProfileField "LinkedIn" "url" p
  , "linkedin_label" .= getProfileField "LinkedIn" "username" p
  , "github_url"     .= getProfileField "GitHub"   "url" p
  , "github_label"   .= getProfileField "GitHub"   "username" p
  , "orcid_url"      .= getProfileField "ORCID"    "url" p
  ]

summaryCtx :: Value -> Value
summaryCtx p = object
  [ "summary" .= latexEscape (getStr ["basics", "summary"] p) ]

educationCtx :: Value -> Value
educationCtx p = object
  [ "educationGroups" .= Array (V.fromList (buildEdGroups (getArr "education" p))) ]

-- | Group education entries by institution and build the display structure.
-- Sort by institution first so non-adjacent same-institution entries are grouped.
buildEdGroups :: [Value] -> [Value]
buildEdGroups entries =
  let sorted = sortBy (comparing getInstitution) entries
      groups = groupBy ((==) `on` getInstitution) sorted
  in  map buildEdGroup groups
  where
    getInstitution e = getStr ["institution"] e

buildEdGroup :: [Value] -> Value
buildEdGroup []           = Null
buildEdGroup (first:rest) = object
  [ "institution"  .= getStr ["institution"] first
  , "url"          .= getStr ["url"]         first
  , "location"     .= getStr ["location"]    first
  , "firstLabel"   .= buildDegreeLabel first
  , "firstDate"    .= buildEdDateRange first
  , "otherDegrees" .= Array (V.fromList (map buildSubDegree rest))
  ]

buildSubDegree :: Value -> Value
buildSubDegree e = object
  [ "label" .= buildDegreeLabel  e
  , "date"  .= buildEdDateRange  e
  ]

-- | Format a degree label, escaping LaTeX special characters.
buildDegreeLabel :: Value -> T.Text
buildDegreeLabel e =
  let studyType = getStr ["studyType"] e
      area      = latexEscape (getStr ["area"] e)
      honor     = getStr ["honor"] e
      honorSfx
        | T.null honor = ""
        | otherwise    = ", " <> honor
  in  studyType <> " " <> area <> honorSfx

-- | Build a "start -- end" date range, using "Present" for null end dates.
buildEdDateRange :: Value -> T.Text
buildEdDateRange e =
  let start = getStr ["startDate"] e
      end   = getStr ["endDate"]   e
  in  if T.null end
        then start <> " -- Present"
        else start <> " -- " <> end

-- | Escape LaTeX special characters in plain text fields.
-- Handles &, %, and $ which are common in resume data.
latexEscape :: T.Text -> T.Text
latexEscape = T.replace "&" "\\&"
            . T.replace "%" "\\%"
            . T.replace "$" "\\$"

-- | Recursively escape LaTeX special chars in all String values of a Value,
-- leaving URL fields (url, paperUrl, codeUrl, demoUrl) untouched.
sanitizeTexts :: Value -> Value
sanitizeTexts (Object obj) = Object (KM.mapWithKey go obj)
  where
    urlKeys = map Key.fromText ["url", "paperUrl", "codeUrl", "demoUrl"]
    go k v | k `elem` urlKeys = v
    go _ v = sanitizeTexts v
sanitizeTexts (Array arr)  = Array (V.map sanitizeTexts arr)
sanitizeTexts (String t)   = String (latexEscape t)
sanitizeTexts v            = v

experienceCtx :: Value -> Value
experienceCtx p = object
  [ "work" .= Array (V.fromList (map sanitizeTexts (getArr "work" p))) ]

publicationsCtx :: Value -> Value
publicationsCtx p = object
  [ "publications" .= Array (V.fromList (map (sanitizeTexts . sanitizePub) (getArr "publications" p))) ]

-- | Replace empty URL strings with Null so Mustache sections are falsy.
sanitizePub :: Value -> Value
sanitizePub (Object obj) = Object (KM.mapWithKey fixUrl obj)
  where
    urlKeys = map Key.fromText ["codeUrl", "demoUrl", "paperUrl"]
    fixUrl k (String t)
      | k `elem` urlKeys, T.null t = Null
    fixUrl _ v = v
sanitizePub v = v

volunteerCtx :: Value -> Value
volunteerCtx p = object
  [ "volunteer" .= Array (V.fromList (map sanitizeTexts (getArr "volunteer" p))) ]

awardsCtx :: Value -> Value
awardsCtx p = object
  [ "awards" .= Array (V.fromList (map sanitizeTexts (getArr "awards" p))) ]

certificatesCtx :: Value -> Value
certificatesCtx p = object
  [ "certificates" .= Array (V.fromList (map sanitizeTexts (getArr "certificates" p))) ]

-- ─── YAML accessors ───────────────────────────────────────────────────────────

-- | Navigate a key path in a JSON Value.
nav :: [T.Text] -> Value -> Value
nav []     v            = v
nav (k:ks) (Object obj) =
  nav ks $ fromMaybe Null (KM.lookup (Key.fromText k) obj)
nav _      _            = Null

-- | Extract a Text value at a key path, defaulting to empty string.
getStr :: [T.Text] -> Value -> T.Text
getStr path v = case nav path v of
  String s -> s
  _        -> T.empty

-- | Extract a list of Values at a top-level array key.
getArr :: T.Text -> Value -> [Value]
getArr key (Object obj) =
  case KM.lookup (Key.fromText key) obj of
    Just (Array arr) -> V.toList arr
    _                -> []
getArr _ _ = []

-- | Find a profile entry by network name and return the value of a field.
getProfileField :: T.Text -> T.Text -> Value -> T.Text
getProfileField network field p =
  let profiles = getArr "profiles" (nav ["basics"] p)
      match pr = getStr ["network"] pr == network
  in  case find match profiles of
        Just pr -> getStr [field] pr
        Nothing -> T.empty
