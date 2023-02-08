module Internal exposing (isEmpty)

{-| Internal functions
-}


{-| Check if a list of lists has any element
-}
isEmpty : List (List a) -> Bool
isEmpty lst =
    case lst of
        [] ->
            True

        x :: xs ->
            if List.isEmpty x then
                isEmpty xs

            else
                False
