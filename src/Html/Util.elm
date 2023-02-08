module Html.Util exposing
    ( Element, Tag
    , uList, oList, dList, anyList
    )

{-| A simple module with utilty functions enhancing elm/html and elm-community/html-extra.

It can be safely imported in the same namespace as Html and Html.Extra, e.g.,

    import Html as H
    import Html.Extra as H
    import Html.Util as H

Html focus in exposing the different types of Html nodes and not much else. The utilities here
correspond to some common patterns seen in creating of Html documents.

@docs Element, Tag


## List functions

@docs uList, oList, dList, anyList

-}

import Html exposing (..)


{-| Alias to the type of typical Html tag functions like `div`, `p`, `h1`, etc

They correspond to the tag name "div" in the HTML.

    <div class="foobar">
        data
    </div>

-}
type alias Element msg =
    List (Attribute msg) -> List (Html msg) -> Html msg


{-| Alias to the type of typical Html tag functions with applied attributes.

Something like `div []`, `p [ class = "prose" ]`, etc.

They correspond to the full tag `<div class="foobar">` in the HTML.

    <div class="foobar">
        data
    </div>

-}
type alias Tag msg =
    List (Html msg) -> Html msg


{-| Creates an <ul> list from a list of elements.

It requires a function that maps items to Html nodes. It automatically creates the <ul> and
<li> nodes.

A list of strings, for instance, can be rendered as:

    uList text [] [ "foo", "bar", "baz" ]

-}
uList : (a -> Html msg) -> List (Attribute msg) -> List a -> Html msg
uList render attrs =
    anyList (ul attrs) (render >> List.singleton >> li [])


{-| Similar to uList, but wraps with an <ol> instead of <ul>.
-}
oList : (a -> Html msg) -> List (Attribute msg) -> List a -> Html msg
oList render attrs =
    anyList (ol attrs) (render >> List.singleton >> li [])


{-| Creates a description list <dl> from a list of (key, value) pairs.

A list of string pairs, for instance, can be rendered as:

    descriptionList ( text, text ) [] [ ( "foo", "bar" ), ( "spam", "eggs" ) ]

-}
dList : ( a -> Html msg, b -> Html msg ) -> List (Attribute msg) -> List ( a, b ) -> Html msg
dList ( renderKey, renderValue ) attrs items =
    items
        |> List.concatMap (\( k, v ) -> [ renderKey k, renderValue v ])
        |> dl attrs


{-| Creates Html from list of items.

The root wrapper creates a node from a list of Html`s (e.g.,`Html.ul []\`) and the
item wrapper creates the html nodes from data.

It is used to implement uList and oList internally and you can use to implement
similar functions.

uList, for instance, is implemented like

    uList render attrs =
        anyList (ul attrs) (render >> List.singleton >> li [])

-}
anyList : Tag msg -> (a -> Html msg) -> List a -> Html msg
anyList wrapper itemWrapper items =
    (items |> List.map itemWrapper) |> wrapper
