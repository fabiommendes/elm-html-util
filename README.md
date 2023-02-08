# HTML utilities

`elm-html-util` implements some utility functions to work with ´elm/html´ 

Install using 

    elm install fabiommendes/elm-html-util


And import in the same namespace as your regular Html elements (or attributes, events, etc)

```elm

import Html.Util as H
import Html as H

type alias Model = 
    { names: List String }

view model = 
    H.div [] 
        [ H.text "Say Hello to:"
        , H.uList H.text [] model.names -- renders an unordered list
        ]
```
