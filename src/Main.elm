module Main exposing (main)

-- elm install avh4/elm-color

import Browser
import Browser.Events exposing (onAnimationFrameDelta)
import Canvas exposing (..)
import Canvas.Settings exposing (..)
import Canvas.Texture exposing (..)
import Color
import Html exposing (Html)
import Html.Attributes exposing (style)


type alias Model =
    { frame : Int
    , sprites : Load Sprites
    }


type Load a
    = Loading
    | Success a
    | Failure


type alias Sprites =
    { t : Texture
    }


type Msg
    = AnimationFrame Float
    | TextureLoaded (Maybe Texture)


init : ( Model, Cmd Msg )
init =
    ( { frame = 0, sprites = Loading }
    , Cmd.none
    )


view : Model -> Html Msg
view model =
    let
        width =
            1024

        height =
            768

        firstBelt =
            case model.sprites of
                Success sprites ->
                    renderBelt sprites.t

                _ ->
                    []
    in
    Canvas.toHtmlWith
        { width = width
        , height = height
        , textures = [ loadFromImageUrl "/hr-transport-belt.png" TextureLoaded ]
        }
        [ style "border" "1px solid black" ]
        ([ shapes [ fill Color.white ] [ rect ( 0, 0 ) width height ]
         , renderSquare
         ]
            ++ firstBelt
        )


renderSquare =
    shapes [ fill Color.lightGrey ]
        [ rect ( 0, 0 ) 1024 768 ]


renderBelt foo =
    let
        x =
            32

        y =
            38

        w =
            64

        h =
            70

        spriteLocation =
            { x = x, y = y, width = w, height = h }

        westToEastBelt =
            sprite spriteLocation foo
    in
    [ shapes [ fill Color.lightGreen ] [ rect ( 0, 0 ) w h ]
    , texture [] ( 0, 0 ) westToEastBelt
    ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AnimationFrame _ ->
            ( { model | frame = model.frame + 1 }
            , Cmd.none
            )

        TextureLoaded (Just texture) ->
            let
                t =
                    Debug.log "texture" texture
            in
            ( { model | sprites = Success { t = texture } }, Cmd.none )

        TextureLoaded Nothing ->
            let
                foo =
                    Debug.log "loading failed" 0
            in
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    onAnimationFrameDelta AnimationFrame


main : Program () Model Msg
main =
    Browser.element { init = \_ -> init, update = update, subscriptions = subscriptions, view = view }
