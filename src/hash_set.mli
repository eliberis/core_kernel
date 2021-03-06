(** A mutable set of elements *)

open Hash_set_intf

type 'a t [@@deriving sexp_of]

(** We use [[@@deriving sexp_of]] but not [[@@deriving sexp]] because we want people to be
    explicit about the hash and comparison functions used when creating hashtables.  One
    can use [Hash_set.Poly.t], which does have [[@@deriving sexp]], to use polymorphic
    comparison and hashing. *)

include Creators
  with type 'a t := 'a t
  with type 'a elt = 'a
  with type ('key, 'z) create_options := ('key, 'z) create_options_with_hashable_required

include Accessors with type 'a t := 'a t with type 'a elt := 'a elt

val hashable : 'key t -> 'key Core_hashtbl_intf.Hashable.t

(** [inter t1 t2] computes the set intersection of [t1] and [t2].  Runs in O(max(length
    t1, length t2)) *)
val inter : 'key t -> 'key t -> 'key t

module type Elt_plain   = Core_hashtbl.Key_plain
module type Elt         = Core_hashtbl.Key
module type Elt_binable = Core_hashtbl.Key_binable
module type S_plain   = S_plain   with type 'a hash_set := 'a t
module type S         = S         with type 'a hash_set := 'a t
module type S_binable = S_binable with type 'a hash_set := 'a t

(** A hash set that uses polymorphic comparison *)
module Poly : sig

  type 'a t [@@deriving sexp]

  include Creators
    with type 'a t := 'a t
    with type 'a elt = 'a
    with type ('key, 'z) create_options := ('key, 'z) create_options_without_hashable

  include Accessors with type 'a t := 'a t with type 'a elt := 'a elt

end with type 'a t = 'a t

module Make_plain   (Elt : Elt_plain  ) : S_plain   with type elt = Elt.t
module Make         (Elt : Elt        ) : S         with type elt = Elt.t
module Make_binable (Elt : Elt_binable) : S_binable with type elt = Elt.t
