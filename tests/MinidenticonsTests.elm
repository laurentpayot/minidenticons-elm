module MinidenticonsTests exposing (..)

import Test exposing (..)
import Expect exposing (Expectation)
import Fuzz exposing (string, tuple)

import Minidenticons exposing (simpleHash)


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
