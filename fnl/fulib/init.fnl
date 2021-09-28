;; @title(fulib.nvim)

;; @abstract(A Functional library in Fennel for nvim.)
;; @generated_by

;; @section(type hints)

;; @para(This lib uses haskell-like type annotation.)
;; @para(Its syntax is)
;; @code(first_argument_type [-> second_argument_type [-> ...]] -> return type)
;; @para(For example, a function with type `a -> b` means it accepts a type `a` parameter)
;; @para(and have return a type `b` value. The type annotation `a -> b -> c` means it accepts two)
;; @para(parameters: the first is type `a` and the second type `b`, and return type `c`.)

;; @item(`bool`: bool)
;; @item(`number`: number)
;; @item(`string`: string)
;; @item(`list` or `[v]`: the tables that is empty or contains not-nil value at the index 1)
;; @item(`table` or `{k v}`: table)
;; @item(`any`: any type)
;; @item(`(a -> b)`: function type that accepts type `a` and return type `b`)
;; @item(`[a|b]`: type `a` or type `b`)

;; @section(Design)

;; @para(fulib would assume the arguments are immutable. It should not change its arguments)
;; @para(except they are obviously needs to be changed. For example, the function `append`.)

;; @export
(local M {})

(macro dispatch [cond f1 f2]
  `(if ,cond ,f1 ,f2))

;; @section(number)

(fn M.inc [num]
  "[number|string] -> number

  O(1). Increase `num`. `num` may be a number or string that can be converted to a number."
  (+ num 1))

(fn M.dec [num]
  "[number|string] -> number

  O(1). Decrease `num`. `num` may be a number or string that can be converted to a number."
  (- num 1))

(fn M.odd? [num]
  "[number|string] -> bool

  O(1). Return true if `num` is odd, false otherwise. If `num` is a string, it must be
  convertible to a number."
  (= (% num 2) 1))

(fn M.even? [num]
  "[number|string] -> bool

  O(1). Return true if `num` is even, false otherwise. If `num` is a string, it must be
  convertible to a number."
  (not (M.odd? num)))

;; @section(type)

(fn M.nil? [v]
  "any -> bool

  O(1). Return true if `v` is nil, false otherwise."
  (= v nil))

(fn M.not-nil? [v]
  "any -> bool

  O(1). Return false if `v` is nil, true otherwise."
  (not= v nil))

(fn M.table? [v]
  "any -> bool

  O(1). Return true if `v` is a table, false otherwise."
  (= (type v) :table))

(fn M.not-table? [v]
  "any -> bool

  O(1). Return false if `v` is a table, true otherwise."
  (not (M.table? v)))

(fn M.list? [v]
  "any -> bool

  O(1). Return true if `v` is a list, false otherwise. A table `t` is a list if it is empty
  or `t[1] != nil`."
  (and (M.table? v) (or (M.empty? v) (not (M.nil? (?. v 1))))))

(fn M.not-list? [v]
  "any -> bool

  O(1). Return false if `v` is a list, true otherwise. A table `t` is a list if it is empty
  or `t[1] != nil`."
  (not (M.list? v)))

(fn flt_eq? [flt1 flt2]
  (-> (- flt1 flt2) (math.abs) (< 1e-06)))

(fn subset? [tbl1 tbl2]
  "Is tbl1 a subset of tbl2?"
  (M.all (fn [v k]
           (M.eq? (. tbl2 k) v)) tbl1))

(fn tbl_eq? [tbl1 tbl2]
  (and (subset? tbl1 tbl2) (subset? tbl2 tbl1)))

(fn M.eq? [v1 v2]
  "any -> any -> bool

  O(1) if `v1` and `v2` are not both table, otherwise it compares `v1` and `v2`
  recursively. Basically the same as `v1 == v2` in Lua except
  * for table, it will perform `eq?` for each key and corresponding value.
  * for number, it will perform float equality comparisons."
  (match [(type v1) (type v2)]
    [:number :number] (flt_eq? v1 v2)
    [:table :table] (tbl_eq? v1 v2)
    _ (= v1 v2)))

(fn M.not-eq? [v1 v2]
  "any -> any -> bool

  O(1) if `v1` and `v2` are not both table. Basically the same as `v1 ~= v2` in Lua except
  * for table, it will perform `not-eq?` for each key and corresponding value.
  * for number, it will perform float equality comparisons."
  (not (M.eq? v1 v2)))

;; @section(Lisp primitives)

(fn M.cons [elem lst]
  "any -> list -> list

  O(n). Insert `elem` in front of `lst`. A new list would be created and returned."
  (let [nlst (M.copy lst)]
    (table.insert nlst 1 elem)
    nlst))

(fn M.car [lst]
  "list -> any

  O(1). Return the first element of `lst`."
  (. lst 1))

(fn M.cdr [lst]
  "list -> list

  O(n). Remove the first element of `lst` and return `lst`. A new table would be created
  and returned."
  (let [nlst (M.copy lst)]
    (table.remove nlst 1)
    nlst))

;; @section(Table/List)

(fn M.copy [tbl]
  "table -> table

  O(n). Return a copy of `tbl`."
  (M.map M.id tbl))

(fn M.empty? [v]
  "[table|string] -> bool

  O(1). Return true if `v` is an empty string or empty table, false otherwise."
  (match [(type v)]
    [:string] (= v "")
    [:table] (M.nil? (next v))
    _ false))

(fn M.not-empty? [v]
  "[table|string] -> bool

  O(1). Return false if `v` is an empty string or empty table, true otherwise."
  (not (M.empty? v)))

(fn M.member? [elem tbl]
  "any -> table -> bool

  O(n). Return true if `elem` is one of the values of `tbl`, false otherwise."
  (M.any #(M.eq? elem $1) tbl))

(fn M.not-member? [elem tbl]
  "any -> table -> bool

  O(n). Return false if `elem` is one of the values of `tbl`, true otherwise."
  (not (M.member? elem tbl)))

(fn M.table-keys [tbl]
  "table -> list

  O(n). Return the list of keys of `tbl`."
  (let [ntbl []]
    (M.for_each #(M.append ntbl $2) tbl)
    ntbl))

(fn M.table-values [tbl]
  "table -> list

  O(n). Return the list of values of `tbl`."
  (let [ntbl []]
    (M.for_each #(M.append ntbl $1) tbl)
    ntbl))

(fn M.append [tbl v]
  "list -> any -> list

  O(1). Append `v` into `tbl`."
  (tset tbl (+ (length tbl) 1) v)
  tbl)

;; @section(Common functional utils)

(fn M.id [v]
  "any -> any

  O(1). Identity function."
  v)

;; all

(fn all_lst [pred lst]
  (for [i 1 (length lst)]
    (if (not (pred (. lst i) i)) (lua "return false")))
  true)

(fn all_tbl [pred tbl]
  (each [k v (pairs tbl)]
    (if (not (pred v k)) (lua "return false")))
  true)

(fn M.all [pred tbl]
  "[(v -> k -> bool)|(v -> bool)] -> {k v}

  O(n * pred). Return true if predicate `pred` return true for all elements of `tbl`,
  false otherwise."
  ((dispatch (M.list? tbl) all_lst all_tbl) pred tbl))

;; any

(fn M.any [pred tbl]
  "[(v -> k -> bool)|(v -> bool)] -> {k v}

  O(n * pred). Return true if predicate `pred` return true for at least elements of `tbl`,
  false otherwise."
  (not (M.all #(not (pred $...)) tbl)))

;; map

(fn for_each_in_lst [f lst]
  (for [i 1 (length lst)]
    (f (. lst i) i)))

(fn for_each_in_tbl [f tbl]
  (each [i v (pairs tbl)]
    (f v i)))

(fn M.for_each [f tbl]
  "[(v -> k -> any)|(v -> any)] -> [table|list] -> [table|list]

  O(n * f). Apply function `f` for all elements of `tbl` without change `tbl` or create a new
  list."
  ((dispatch (M.list? tbl) for_each_in_lst for_each_in_tbl) f tbl))

(fn M.map [f tbl]
  "[(v -> k -> any)|(v -> any)] -> table -> table

  O(n * f). Like `for_each` but a new table would be created."
  (let [ntbl {}]
    (if (M.list? tbl) (M.for_each #(M.append ntbl (f $1 $2)) tbl)
        (M.for_each #(tset ntbl $2 (f $1 $2)) tbl))
    ntbl))

;; filter

(fn M.filter [pred tbl]
  "[(v -> k -> bool)|(v -> bool)] -> table -> table

  O(n * pred). Return a new list with the elements of `tbl` for which `pred` returns true."
  (M.map #(when (pred $1 $2)
            $1) tbl))

;; fold

(fn M.foldl [f init lst]
  "[(init -> v -> k -> init)|(init -> v -> init)] -> init -> table -> init

  O(n * f). Start with `init`, reduce `lst` with function `f`, from left to right."
  (var acc init)
  (M.for_each #(set acc (f acc $1 $2)) lst)
  acc)

(fn M.foldr [f init lst]
  "[(v -> init -> k -> init)|(v -> init -> init)] -> init -> table -> init

  O(n * f). Start with `init`, reduce `lst` with function `f`, from right to left."
  (var acc init)
  (M.for_each #(set acc (f $1 acc $2)) (M.reverse lst))
  acc)

;; reverse

(fn M.reverse [lst]
  "list -> list

  O(n). Reverse `lst`."
  (M.map #(. lst (- (+ (length lst) 1) $2)) lst))

;; intersect 

(fn to-exist-map [lst]
  (let [ntbl {}]
    (for_each_in_lst #(tset ntbl $1 true) lst)
    ntbl))

(fn intersect-lst [tbl1 tbl2]
  (local in-tbl1 (to-exist-map tbl1))
  (M.filter #(. in-tbl1 $1) tbl2))

(fn intersect-tbl [tbl1 tbl2]
  (if (M.list? tbl1) (M.filter #(-> (. tbl1 $2) (M.nil?) (not)) tbl2)
      (M.filter #(-> (. tbl2 $2) (M.nil?) (not)) tbl1)))

(fn M.intersect [tbl1 tbl2]
  "table -> table -> list

  O(n). Return the intersection of `tbl1` and `tbl2`."
  (if (and (M.list? tbl1) (M.list? tbl2))
      (intersect-lst tbl1 tbl2)
      (intersect-tbl tbl1 tbl2)))

;; zip

(fn range [start end]
  (let [nlst []]
    (for [i start end]
      (M.append nlst i))
    nlst))

(fn M.zip_with [f lst1 lst2]
  "(v1 -> v2 -> any) -> list -> list -> list

  O(min(m, n)). Return a list corresponding pair of `lst1` and `lst2`."
  (let [len (math.min (length lst1) (length lst2))]
    (M.map #(f (. lst1 $1) (. lst2 $1)) (range 1 len))))

(fn M.zip [lst1 lst2]
  "table -> table -> list

  O(min(m, n)). Return a list of corresponding pair of `lst1` and `lst2`."
  (M.zip_with #[$1 $2] lst1 lst2))

M

