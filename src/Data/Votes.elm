module Data.Votes exposing (..)

import Data.Category as Category exposing (..)
import Http exposing (encodeUri)
import Json.Decode
import Json.Encode


type alias VoteCount =
    { category : Category, count : Int }


decodeVoteCount : Json.Decode.Decoder (List VoteCount)
decodeVoteCount =
    Json.Decode.list
        (Json.Decode.map2 VoteCount
            (Json.Decode.field "category_id" Json.Decode.int
                |> Json.Decode.map Category.fromId
            )
            (Json.Decode.field "count" Json.Decode.int)
        )


getVotes : String -> Http.Request (List VoteCount)
getVotes url =
    Http.get ("https://fake-news-detector-api.herokuapp.com/votes?url=" ++ encodeUri url) decodeVoteCount


encodeNewVote : String -> String -> String -> Category -> Json.Encode.Value
encodeNewVote uuid url title category =
    Json.Encode.object
        [ ( "uuid", Json.Encode.string uuid )
        , ( "url", Json.Encode.string url )
        , ( "title", Json.Encode.string title )
        , ( "category_id", Json.Encode.int (Category.toId category) )
        ]


postVote : String -> String -> String -> Category -> Http.Request ()
postVote uuid url title category =
    Http.post "https://fake-news-detector-api.herokuapp.com/vote"
        (Http.jsonBody (encodeNewVote uuid url title category))
        (Json.Decode.succeed ())