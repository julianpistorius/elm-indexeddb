module IndexedDB.Cursor exposing
  ( Cursor, Direction, key, primaryKey, value, advance, continue, delete
  , update
  )

{-| Module that provides an interface to an IndexedDB Cursor.

# Data access
@docs key, primaryKey, value

# Data modification
@docs delete, update

# Cursor handling
@docs advance, continue

# Data structure
@docs Cursor, Direction
-}

import Json.Decode as Json
import Task exposing (Task, andThen, mapError, succeed, fail, fromResult)
import IndexedDB.Error exposing(Error, RawError, promoteError)
import Native.IndexedDB

{-| Cursor data structure.
-}
type alias Cursor =
  { direction : Direction
  , handle : Json.Value
  }

{-| Cursor direction
-}
type Direction
  = Next
  | NextUnique
  | Prev
  | PrevUnique

{-| Return the current key for the cursor.
-}
key : Cursor -> k
key cursor =
  Native.IndexedDB.cursorKey cursor.handle

{-| Return the current primary key for the cursor; this value will be the
same as `key` if the cursor was open via the `ObjectStore` interface but may
be different if it was open via the `Index` interface.
-}
primaryKey : Cursor -> pk
primaryKey cursor =
  Native.IndexedDB.cursorPrimaryKey cursor.handle

{-| Return the current value of the cursor.
-}
value : Json.Decoder v -> Cursor -> Result String v
value decoder cursor =
  Json.decodeValue decoder (Native.IndexedDB.cursorValue cursor.handle)

{-| Advance the cursor by the given count.
-}
advance : Int -> Cursor -> Result Error ()
advance count cursor =
  Result.formatError promoteError(
    Native.IndexedDB.cursorAdvance cursor.handle count
    )

{-| Continue to the next item in the cursor as identified by the given key. If
no key is given, continue to the next item.
-}
continue : Maybe k -> Cursor -> Result Error ()
continue key cursor =
  Result.formatError promoteError(
    Native.IndexedDB.cursorContinue cursor.handle key
    )

{-| Delete the item currently pointed to by the cursor.
-}
delete : Cursor -> Task Error ()
delete cursor =
  mapError promoteError (
    Native.IndexedDB.cursorDelete cursor.handle
    )

{-| Update the item currently pointed to by the cursor.
-}
update : v -> Cursor -> Task Error ()
update value cursor =
  mapError promoteError (
    Native.IndexedDB.cursorUpdate cursor.handle value
    )
