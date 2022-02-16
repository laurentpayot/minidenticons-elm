module MinidenticonsTests exposing (..)

import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector exposing (text, tag, attribute)
import Fuzz exposing (string, tuple)
import Expect exposing (Expectation)

import Svg exposing (svg, rect)
import Svg.Attributes exposing (fill, viewBox, height, width)

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
            "foo"
            |> identicon 50 50
            |> Query.fromHtml
            -- |> Query.has [ tag "svg" ]
            |> log "query"
            |> Query.findAll [ tag "rect" ]
            |> Query.each
                (Expect.all
                    [ Query.has [ tag "rect" ]
                    , Query.has [ attribute (height "1"), attribute (width "1") ]
                    ]
                )
        ]
