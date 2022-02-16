module MinidenticonsTests exposing (..)

import Test exposing (..)
import Test.Html.Query as Q
import Test.Html.Selector exposing (text, tag, attribute)
import Fuzz exposing (string, tuple)
import Expect exposing (Expectation)

import Svg exposing (svg, rect)
import Svg.Attributes exposing (viewBox, fill, x, y, height, width)

import Minidenticons exposing (simpleHash, identicon)
import Debug exposing (log)


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


identiconTest : Test
identiconTest =

    describe "identicon"

        [ test "'foo' username" <| \_ ->
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
            |> Q.fromHtml
            |> Expect.all
                [ Q.has
                    [ tag "svg"
                    , attribute (viewBox "-1.5 -1.5 8 8")
                    -- xmlns attribute not available https://developer.mozilla.org/en-US/docs/Web/SVG/Element/svg#sect1
                    , attribute (fill "hsl(60 75% 50%)")
                    ]
                , Q.children [] >>
                    Expect.all
                        [ Q.each (Q.has [ tag "rect", attribute (height "1"), attribute (width "1") ])
                        , Q.count (Expect.equal 7)
                        , Q.index 0 >> Q.has [ attribute (x "1"), attribute (y "1") ]
                        , Q.index 1 >> Q.has [ attribute (x "2"), attribute (y "0") ]
                        , Q.index 2 >> Q.has [ attribute (x "2"), attribute (y "1") ]
                        , Q.index 3 >> Q.has [ attribute (x "2"), attribute (y "2") ]
                        , Q.index 4 >> Q.has [ attribute (x "2"), attribute (y "3") ]
                        , Q.index 5 >> Q.has [ attribute (x "2"), attribute (y "4") ]
                        , Q.index 6 >> Q.has [ attribute (x "3"), attribute (y "1") ]
                        ]
                ]
        ]
