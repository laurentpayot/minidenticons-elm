module MinidenticonsTests exposing (..)

import Test exposing (..)
import Test.Html.Query as Q
import Test.Html.Selector exposing (tag, attribute)
import Fuzz exposing (string, tuple)
import Expect exposing (Expectation)

import Html exposing (Html)
import Html.Attributes
import Svg.Attributes exposing (viewBox, fill, x, y, height, width)
import String exposing (fromInt)

import Minidenticons exposing (simpleHash, identicon)


-- workaround for https://github.com/elm-explorations/test/issues/136
suchThat : (a -> Bool) -> (a -> Expectation) -> a -> Expectation
suchThat filter expect value =
    if filter value then
        expect value
    else
        Expect.pass

simpleHashTest : Test
simpleHashTest =

    describe "simpleHash"

        [ test "'foobar' string" <| \_ ->
            "foobar"
            |> simpleHash
            |> Expect.equal 1969938396939302

        , test "'alienHead66' string" <| \_ ->
            "alienHead66"
            |> simpleHash
            |> Expect.equal 39870209603664160

        , test "Empty string" <| \_ ->
            ""
            |> simpleHash
            |> Expect.equal 2166136261

        , fuzz (tuple (string, string)) "Different hashes for different strings" <|
            suchThat (\(randomStr1, randomStr2) -> randomStr1 /= randomStr2) <|
                \(randomStr1, randomStr2) ->
                    Expect.notEqual (simpleHash randomStr1) (simpleHash randomStr2)
        ]


checkSquares : List (Int, Int) -> Q.Multiple msg -> Expectation
checkSquares squares =
    if squares == [] then
        \_ -> Expect.pass
    else
        Expect.all <|
            List.indexedMap
                (\i (xInt, yInt) ->
                    Q.index i >> Q.has [ attribute (x (fromInt xInt)), attribute (y (fromInt yInt)) ]
                )
                squares

checkIdenticon : Int -> Int -> Int -> List (Int, Int) -> Html msg -> Expectation
checkIdenticon saturation lightness hue squares =
    Q.fromHtml
    >> Expect.all
        [ Q.has
            [ tag "svg"
            , attribute (viewBox "-1.5 -1.5 8 8")
            , attribute (Html.Attributes.attribute "xmlns" "http://www.w3.org/2000/svg")
            , attribute <| fill <|
                "hsl(" ++ fromInt hue ++ " " ++ fromInt saturation ++ "% " ++ fromInt lightness ++ "%)"
            ]
        , Q.children []
          >> Expect.all
                [ Q.each <| Q.has [ tag "rect", attribute (height "1"), attribute (width "1") ]
                , Q.count <| Expect.equal (List.length squares)
                , checkSquares squares
                ]
        ]

identiconTest : Test
identiconTest =

    describe "identicon"

        [ test "Empty string username" <| \_ ->
            {-
            <svg viewBox="-1.5 -1.5 8 8" xmlns="http://www.w3.org/2000/svg" fill="hsl(60 75% 50%)">
            </svg>
            -}
            ""
            |> identicon 75 50
            |> checkIdenticon 75 50
                60 []

        , test "'foo' username" <| \_ ->
            {-
            <svg viewBox="-1.5 -1.5 8 8" xmlns="http://www.w3.org/2000/svg" fill="hsl(60 75% 50%)">
                <rect x="1" y="1" width="1" height="1" />
                <rect x="2" y="0" width="1" height="1" />
                <rect x="2" y="1" width="1" height="1" />
                <rect x="2" y="2" width="1" height="1" />
                <rect x="2" y="3" width="1" height="1" />
                <rect x="2" y="4" width="1" height="1" />
                <rect x="3" y="1" width="1" height="1" />
            </svg>
            -}
            "foo"
            |> identicon 75 50
            |> checkIdenticon 75 50
                60 [ (1, 1), (2, 0), (2, 1), (2, 2), (2, 3), (2, 4), (3, 1) ]

        , test "'alienHead66' username" <| \_ ->
            {-
            <svg viewBox="-1.5 -1.5 8 8" xmlns="http://www.w3.org/2000/svg" fill="hsl(0 75% 50%)">
                <rect x="0" y="0" width="1" height="1" />
                <rect x="0" y="2" width="1" height="1" />
                <rect x="1" y="1" width="1" height="1" />
                <rect x="1" y="3" width="1" height="1" />
                <rect x="1" y="4" width="1" height="1" />
                <rect x="2" y="1" width="1" height="1" />
                <rect x="2" y="2" width="1" height="1" />
                <rect x="2" y="3" width="1" height="1" />
                <rect x="2" y="4" width="1" height="1" />
                <rect x="4" y="0" width="1" height="1" />
                <rect x="4" y="2" width="1" height="1" />
                <rect x="3" y="1" width="1" height="1" />
                <rect x="3" y="3" width="1" height="1" />
                <rect x="3" y="4" width="1" height="1" />
            </svg>
            -}
            "alienHead66"
            |> identicon 75 50
            |> checkIdenticon 75 50
                0
                [ (0, 0), (0, 2), (1, 1), (1, 3), (1, 4), (2, 1), (2, 2)
                , (2, 3), (2, 4), (4, 0), (4, 2), (3, 1), (3, 3), (3, 4)
                ]

        ]
