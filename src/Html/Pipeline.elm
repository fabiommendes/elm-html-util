module Html.Pipeline exposing
    ( Pipeline, HtmlList
    , error, pipeline, itemsOf, pairsOf, partsOf, tryItemsOf
    , filter, map, mapBoth, mapTag, backwards, empty, negate
    , unwrap, asChildren, asRoot
    )

{-| Html processing pipelines

@docs Pipeline, HtmlList


## Starting pipelines

@docs error, pipeline, itemsOf, pairsOf, partsOf, tryItemsOf


## Transformations

@docs filter, map, mapBoth, mapTag, backwards, empty, negate


## Reducing and summarizing

@docs unwrap, asChildren, asRoot

-}

import Html exposing (..)
import Html.Util exposing (Tag)


{-| Represents a temporary processing of some stream of values

Can be in an Ok or Err state.

-}
type alias Pipeline a =
    Result (List a) (List a)


{-| A Pipeline, for Html nodes
-}
type alias HtmlList msg =
    Pipeline (Html msg)


{-| Creates Html from list of items, with a fallback if list is empty.

This function is designed to be used in tandem with some other functions in
a chain

Example:

    itemsOf text [ "John", "Paul", "Ringo" ]
        |> wrap (p [])
        |> empty [ text "No one found!" ]
        |> root (div [])

-}
itemsOf : (a -> Html msg) -> List a -> HtmlList msg
itemsOf f =
    Ok << List.map f


{-| Similar to itemsOf, but work with functions that return lists of Html elements
-}
partsOf : (a -> List (Html msg)) -> List a -> HtmlList msg
partsOf f =
    Ok << List.concatMap f


{-| Similar to itemsOf, but work in pairs. The HTML is generated from each member of
the pair and concatenated. This is useful for things like <dt>/<dd> pairs in
description lists, from labels and inputs, etc.
-}
pairsOf : (a -> Html msg) -> (b -> Html msg) -> List ( a, b ) -> HtmlList msg
pairsOf fa fb =
    partsOf (\( a, b ) -> [ fa a, fb b ])


{-| Similar to itemsOf, but work with functions that return maybes
-}
tryItemsOf : (a -> Maybe (Html msg)) -> List a -> HtmlList msg
tryItemsOf f =
    Ok << List.filterMap f


pipeline : List a -> Pipeline a
pipeline =
    Ok


error : a -> Pipeline a
error =
    Err << List.singleton


{-| Map each item in pipeline with function.
-}
map : (a -> a) -> Pipeline a -> Pipeline a
map f =
    Result.map (List.map f)


{-| Map each item in pipeline with function both in the error and success cases.
-}
mapBoth : (a -> b) -> Pipeline a -> Pipeline b
mapBoth f pipe =
    case pipe of
        Ok xs ->
            Ok (List.map f xs)

        Err xs ->
            Err (List.map f xs)


{-| Wrap each item with tag
-}
mapTag : Tag msg -> HtmlList msg -> HtmlList msg
mapTag tag =
    Result.map (List.map (tag << List.singleton))


{-| Flip error and success cases
-}
negate : Pipeline a -> Pipeline a
negate pipe =
    case pipe of
        Ok xs ->
            Err xs

        Err xs ->
            Ok xs


{-| Reorganize items backwards
-}
backwards : Pipeline a -> Pipeline a
backwards =
    Result.map List.reverse


{-| Filter elements of pipeline
-}
filter : (a -> Bool) -> Pipeline a -> Pipeline a
filter f =
    Result.map (List.filter f)


{-| Define the Html representation for empty lists of elements.

Usualy it will present some message like "no items were found!"

-}
empty : List (Html msg) -> HtmlList msg -> HtmlList msg
empty err value =
    case value of
        Ok xs ->
            if List.isEmpty xs then
                Err err

            else
                Ok xs

        Err _ ->
            Err err


{-| Convert HtmlList to a list of Html nodes
-}
asChildren : Pipeline a -> List a
asChildren lst =
    case lst of
        Ok xs ->
            xs

        Err xs ->
            xs


{-| Unwrap the HtmlList and return an element.

The root is usually a tag with attributes applied. Something like `div []`

-}
asRoot : Tag msg -> HtmlList msg -> Html msg
asRoot root lst =
    root (asChildren lst)


{-| Unwrap the success and error cases with different roots.

Example:

    unwrap ( div [ class "error" ], div [ class "ok" ] ) htmlist

-}
unwrap : ( Tag msg, Tag msg ) -> HtmlList msg -> Html msg
unwrap ( err, ok ) lst =
    case lst of
        Ok xs ->
            ok xs

        Err xs ->
            err xs
