module Minidenticons exposing (identicon, simpleHash)

{-| This library contains the main `identicon` function as well as a bonus `simpleHash` function.

# SVG identicon
@docs identicon

# Bonus
@docs simpleHash

-}

import Bitwise
import Html exposing (Html)
import Html.Attributes exposing (attribute)
import Svg exposing (svg, rect)
import Svg.Attributes exposing (viewBox, fill, x, y, width, height)
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


{-| Hash function used by Minidenticons.
Based on the [FNV1a](http://www.isthe.com/chongo/tech/comp/fnv/index.html) hash algorithm, modified for *signed* 32 bit integers.
Always return a *positive* integer.

    simpleHash "alienHead66" -- 39870209603664160

-}
simpleHash : String -> Int
simpleHash str =
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

{-| Generate the SVG identicon.

The `identicon` function will return a SVG element generated from its username string argument.
The saturation and lightness arguments have to be percentages, i.e integers between 0 and 100.

For instance for the username "alienHead66", with a saturation of 75% and a lightness of 50%:

    identicon 75 50 "alienHead66"

You will get the following identicon (without the border):

[!["alienHead66" identicon](https://raw.githubusercontent.com/laurentpayot/minidenticons-elm/main/img/alienHead66_150.svg)](https://raw.githubusercontent.com/laurentpayot/minidenticons-elm/main/img/alienHead66_150.svg)
- Note that the picture above is resized. [By default identicons will take all the space available.](https://raw.githubusercontent.com/laurentpayot/minidenticons-elm/main/img/alienHead66.svg)

- The white space around the colored squares is here to allow uncropped circle avatars like the ones you can see in [the demo](https://laurentpayot.github.io/minidenticons/).

Play with [the demo](https://laurentpayot.github.io/minidenticons/) to find a combination of saturation and lightness that matches your website theme colors: light, dark, pastel or whatever 😎

![Minidenticons light](https://raw.githubusercontent.com/laurentpayot/minidenticons-elm/main/img/minidenticons_light.png)
![Minidenticons dark](https://raw.githubusercontent.com/laurentpayot/minidenticons-elm/main/img/minidenticons_dark.png)
![Minidenticons pastel](https://raw.githubusercontent.com/laurentpayot/minidenticons-elm/main/img/minidenticons_pastel.png)

-}
identicon : Int -> Int -> String -> Html msg
identicon saturation lightness username =
    let
        hash : Int
        hash = simpleHash username
        hue : Int
        hue =
            hash // fnvPrime
            |> Bitwise.shiftRightZfBy 0 -- needed to avoid negative values
            |> modBy colorsNb
            |> (*) (360 // colorsNb)
    in
    svg [ viewBox "-1.5 -1.5 8 8"
        , attribute "xmlns" "http://www.w3.org/2000/svg"
        , fill <|
            "hsl(" ++ fromInt hue ++ " " ++ fromInt saturation ++ "% " ++ fromInt lightness ++ "%)"
        ] <|
        List.filterMap
            (\i ->
                -- 2 + ((3 * 5 - 1) - modulo) to concentrate squares at the center
                if modBy (16 - modBy 15 i) hash < squareDensity then
                    Just <| rect
                        [ x <| fromInt <| if i > 14 then 7 - i // 5 else i // 5
                        , y <| fromInt <| modBy 5 i
                        , width "1"
                        , height "1"
                        ] []
                else
                    Nothing
            )
            (List.range 0 24)
