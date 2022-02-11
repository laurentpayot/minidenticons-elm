module Minidenticons exposing (..)

import Bitwise
import Html exposing (Html)
import Svg exposing (svg, rect)
import Svg.Attributes exposing (viewBox, fill)
import String exposing (fromInt)


-- squareDensity of 4 for the lowest probability of collision
squareDensity : Int
squareDensity = 4

-- 18 different colors only for easy distinction
colorsNb : Int
colorsNb = 18

-- bit FNV-1a hash parameters
fnvPrime : Int
fnvPrime = 16777619

offsetBasis : Int
offsetBasis = 2166136261


-- FNV1a-like hash function http://www.isthe.com/chongo/tech/comp/fnv/index.html
pseudoFNV1a : String -> Int
pseudoFNV1a str =
    str
    |> String.toList
    |> List.foldl
        (\char hash ->
            char
            |> Char.toCode
            |> Bitwise.xor hash
            -- >>> 0 for 32 bit unsigned integer conversion https://2ality.com/2012/02/js-integers.html
            |> Bitwise.shiftRightZfBy 0
            |> (*) fnvPrime
        )
        offsetBasis

-- TODO https://package.elm-lang.org/help/documentation-format
identicon : String -> Int -> Int -> Html msg
identicon username saturation lightness =
    let
        hash : Int
        hash = pseudoFNV1a username
        hue : Int
        hue = (modBy colorsNb (hash // fnvPrime)) * (360 // colorsNb)
    in
    svg [ viewBox "-1.5 -1.5 8 8"
        , fill <|
            "hsl(" ++ fromInt hue ++ " " ++ fromInt saturation ++ "% " ++ fromInt lightness ++ "%)"
        ] <|
        List.filterMap (\i ->
            -- 2 + ((3 * 5 - 1) - modulo) to concentrate squares at the center
            if modBy (16 - modBy 15 i) hash < squareDensity then
                Just <|
                    rect [ Svg.Attributes.x <| fromInt <| if i > 14 then 7 - i // 5 else i // 5
                        , Svg.Attributes.y <| fromInt <| modBy 5 i
                        , Svg.Attributes.width "1"
                        , Svg.Attributes.height "1"
                        ] []
            else
                Nothing
        ) (List.range 0 24)
