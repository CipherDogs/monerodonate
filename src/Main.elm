module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Html.Parser
import Html.Parser.Util
import QRCode
import Svg.Attributes as SvgA
import Url
import Url.Parser as Parser
import Url.Parser.Query as Query



-- MAIN


main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- MODEL


type alias Model =
    { link : String
    , donate : String
    , address : String
    , html : String
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url _ =
    let
        address =
            parseQuery url
    in
    ( { link = "https://donate.cipherdogs.net/?address="
      , donate = "4A5cX5VRHSmitG2fyZZqJu1hTFR53aKpPD9GjnBi6D3p5qVNA8c3gFxB7Q8E1aJQiHNt2EBjjviUTMNWmX4f4V8RSE3JX9f"
      , address = address
      , html = ""
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = UrlChanged Url.Url
    | LinkClicked Browser.UrlRequest
    | SetAddress String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChanged _ ->
            ( model, Cmd.none )

        LinkClicked _ ->
            ( model, Cmd.none )

        SetAddress address ->
            ( { model
                | html =
                    "<a target='_blank' href='"
                        ++ model.link
                        ++ address
                        ++ "'><img height='100' width='100' src='https://donate.cipherdogs.net/img/monero.png'></a>"
              }
            , Cmd.none
            )



-- VIEW


textHtml : String -> List (Html.Html msg)
textHtml t =
    case Html.Parser.run t of
        Ok nodes ->
            Html.Parser.Util.toVirtualDom nodes

        Err _ ->
            []


generateLink : String -> String -> Html Msg
generateLink html address =
    section [ class "generate" ]
        [ h3 [] [ text "Generate Monero Donate Link" ]
        , p [] [ text "Address" ]
        , input
            [ class "address"
            , autofocus True
            , maxlength 95
            , type_ "text"
            , placeholder "4.. / 8.. / OpenAlias"
            , onInput SetAddress
            ]
            []
        , div [ class "result" ]
            [ div [ class "result__text" ]
                [ p [] [ text "Result" ]
                , textarea [] [ text html ]
                ]
            , div [ class "html" ]
                [ p [] [ text "Preview" ]
                , div [] (textHtml html)
                ]
            ]
        ]


qrCodeView : String -> Html msg
qrCodeView message =
    QRCode.fromString message
        |> Result.map
            (QRCode.toSvg
                [ SvgA.width "256px"
                , SvgA.height "256px"
                ]
            )
        |> Result.withDefault (Html.text "Error while encoding to QRCode.")


viewQRcode : String -> Html Msg
viewQRcode address =
    section []
        [ h3 [] [ text "Monero Donate Address" ]
        , div [] [ qrCodeView address ]
        , div [ class "view__address" ]
            [ text "Address"
            , div [] [ text address ]
            ]
        , a [ class "button", href ("monero:" ++ address), target "_blank" ] [ text "Donate" ]
        ]


view : Model -> Browser.Document Msg
view model =
    { title = "Monero Donate"
    , body =
        [ main_ []
            [ img [ class "logo", src "img/monero-logo.png" ] []
            , if String.isEmpty model.address then
                generateLink model.html model.address

              else
                viewQRcode model.address
            , p [ class "footer" ]
                [ text "Add to your site a link to donate Monero"
                , a [ href (model.link ++ model.donate), target "_blank" ] [ text "Donate" ]
                ]
            ]
        ]
    }



-- HELPERS


parseQuery : Url.Url -> String
parseQuery url =
    let
        query =
            Parser.parse (Parser.query (Query.string "address")) url
    in
    Maybe.withDefault "" (Maybe.withDefault (Just "") query)
