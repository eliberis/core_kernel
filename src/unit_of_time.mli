(** Represents a unit of time, e.g. used by [Time.Span.to_string_hum].  Comparison
    respects Nanosecond < Microsecond < Millisecond < Second < Minute < Hour < Day. *)

type t =
  | Nanosecond
  | Microsecond
  | Millisecond
  | Second
  | Minute
  | Hour
  | Day
[@@deriving sexp, compare, hash]
