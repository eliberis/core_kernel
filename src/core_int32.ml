open Typerep_lib.Std
open Sexplib.Std
open Bin_prot.Std
open Hash.Builtin
open Int32

module T = struct
  type t = int32 [@@deriving hash, sexp, bin_io, typerep]
  let compare (x : t) y = compare x y

  let to_string = to_string
  let of_string = of_string
end

include T

let num_bits = 32

let float_lower_bound = Float0.lower_bound_for_int num_bits
let float_upper_bound = Float0.upper_bound_for_int num_bits

let float_of_bits = float_of_bits
let bits_of_float = bits_of_float
let shift_right_logical = shift_right_logical
let shift_right = shift_right
let shift_left = shift_left
let bit_not = lognot
let bit_xor = logxor
let bit_or = logor
let bit_and = logand
let min_value = min_int
let max_value = max_int
let abs = abs
let pred = pred
let succ = succ
let rem = rem
let neg = neg
let minus_one = minus_one
let one = one
let zero = zero
let compare = compare
let to_float = to_float
let of_float_unchecked = of_float
let of_float f =
  if f >= float_lower_bound && f <= float_upper_bound then
    of_float f
  else
    Common.invalid_argf "Core_int32.of_float: argument (%f) is out of range or NaN"
      (Float0.box f)
      ()
;;

include Comparable.Validate_with_zero (struct
  include T
  let zero = zero
end)

module Replace_polymorphic_compare = struct
  let compare = compare
  let ascending = compare
  let descending x y = compare y x
  let min (x : t) y = if x < y then x else y
  let max (x : t) y = if x > y then x else y
  let equal (x : t) y = x = y
  let ( >= ) (x : t) y = x >= y
  let ( <= ) (x : t) y = x <= y
  let ( = ) (x : t) y = x = y
  let ( > ) (x : t) y = x > y
  let ( < ) (x : t) y = x < y
  let ( <> ) (x : t) y = x <> y
  let between t ~low ~high = low <= t && t <= high
  let clamp_unchecked t ~min ~max =
    if t < min then min else if t <= max then t else max

  let clamp_exn t ~min ~max =
    assert (min <= max);
    clamp_unchecked t ~min ~max

  let clamp t ~min ~max =
    if min > max then
      Or_error.error "clamp requires [min <= max]"
        (`Min min, `Max max) [%sexp_of: [`Min of T.t] * [`Max of T.t]]
    else
      Ok (clamp_unchecked t ~min ~max)
end

include Replace_polymorphic_compare

include Hashable.Make_binable (T)
include Comparable.Map_and_set_binable (T)

let ( / ) = div
let ( * ) = mul
let ( - ) = sub
let ( + ) = add
let ( ~- ) = neg

let incr r = r := !r + one
let decr r = r := !r - one

let of_int32 t = t
let of_int32_exn = of_int32
let to_int32 t = t
let to_int32_exn = to_int32

let popcount = Popcount.int32_popcount

module Conv = Int_conversions
let of_int = Conv.int_to_int32
let of_int_exn = Conv.int_to_int32_exn
let to_int = Conv.int32_to_int
let to_int_exn = Conv.int32_to_int_exn
let of_int64 = Conv.int64_to_int32
let of_int64_exn = Conv.int64_to_int32_exn
let to_int64 = Conv.int32_to_int64
let of_nativeint = Conv.nativeint_to_int32
let of_nativeint_exn = Conv.nativeint_to_int32_exn
let to_nativeint = Conv.int32_to_nativeint
let to_nativeint_exn = to_nativeint

let pow b e = of_int_exn (Int_math.int_pow (to_int_exn b) (to_int_exn e))

include Conv.Make (T)

include Conv.Make_hex(struct

  type t = int32 [@@deriving bin_io, compare, hash, typerep]

  let zero = zero
  let neg = (~-)
  let (<) = (<)
  let to_string i = Printf.sprintf "%lx" i
  let of_string s = Scanf.sscanf s "%lx" Fn.id

  let module_name = "Core_kernel.Std.Int32.Hex"

end)

include Pretty_printer.Register (struct
  type nonrec t = t
  let to_string = to_string
  let module_name = "Core_kernel.Std.Int32"
  end)

include Quickcheck.Make_int (struct
    type nonrec t = t [@@deriving sexp, compare, hash]
    include (Replace_polymorphic_compare
             : Polymorphic_compare_intf.Infix with type t := t)
    let min_value         = min_value
    let max_value         = max_value
    let succ              = succ
    let pred              = pred
    let splittable_random = Splittable_random.int32
  end)

module Pre_O = struct
  let ( + ) = ( + )
  let ( - ) = ( - )
  let ( * ) = ( * )
  let ( / ) = ( / )
  let ( ~- ) = ( ~- )
  include (Replace_polymorphic_compare : Polymorphic_compare_intf.Infix with type t := t)
  let abs = abs
  let neg = neg
  let zero = zero
  let of_int_exn = of_int_exn
end

module O = struct
  include Pre_O
  include Int_math.Make (struct
    type nonrec t = t
    include Pre_O
    let rem = rem
    let to_float = to_float
    let of_float = of_float
    let of_string = T.of_string
    let to_string = T.to_string
  end)
end

include O (* [Int32] and [Int32.O] agree value-wise *)
