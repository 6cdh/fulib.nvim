(local {: view} (require :fennel))

(local M {})

;; Functional Utils

(fn all [pred tbl]
  (each [k v (pairs tbl)]
    (if (not (pred v k)) (lua "return false")))
  true)

(fn append [lst v]
  (table.insert lst v))

(fn filter-lst [pred lst]
  (let [nlst []]
    (each [k v (ipairs lst)]
      (when (pred v k)
        (append nlst v)))
    nlst))

(fn for-each [f tbl iter]
  (each [k v (iter tbl)]
    (f v k)))

(fn id [v]
  v)

(fn map-lst [f lst]
  (let [nlst []]
    (for-each (fn [v i]
                (append nlst (f v i))) lst
              (or lst.__pairs ipairs))
    nlst))

(fn map-tbl [f tbl]
  (let [ntbl []]
    (for-each (fn [v k]
                (tset ntbl k (f v k))) tbl pairs)
    ntbl))

(fn eq? [v1 v2]
  (fn flt_eq? [flt1 flt2]
    (-> (- flt1 flt2) (math.abs) (< 1e-06)))

  (fn subset? [tbl1 tbl2]
    (all (fn [v k]
           (eq? (. tbl2 k) v)) tbl1))

  (fn tbl_eq? [tbl1 tbl2]
    (and (subset? tbl1 tbl2) (subset? tbl2 tbl1)))

  (match [(type v1) (type v2)]
    [:number :number] (flt_eq? v1 v2)
    [:table :table] (tbl_eq? v1 v2)
    _ (= v1 v2)))

(fn count [pred tbl init]
  (var cnt 0)
  (for-each (fn [v k]
              (when (pred v k)
                (set cnt (+ cnt 1)))) tbl pairs)
  cnt)

(fn repeat [n term]
  (fn repeat-str [n str]
    (string.rep str n))

  (match (type term)
    :string (repeat-str n term)))

(fn sum [tbl]
  (var acc 0)
  (for-each #(set acc (+ acc $1)) tbl pairs)
  acc)

;; maybe

(local maybe {:placeholder :maybe
              :matcher (fn [got expect]
                         (for [i 2 (length expect)]
                           (if (eq? got (. expect i)) (lua "return true")))
                         false)})

(fn M.maybe [...]
  [maybe.placeholder ...])

;; Colorize Text

(fn colorize [color str]
  (fn color-term [color]
    (match color
      :blue "[0;34m"
      :cyan "[0;36m"
      :red "[0;31m"
      :green "[0;32m"
      :yellow "[0;33m"
      _ (error (.. "No color: " color))))

  (let [start-color "\027"
        reset-color "\027[0m"]
    (.. start-color (color-term color) str reset-color)))

;; output

(fn colorful-format [str ...]
  (local pattern {"%%b" (colorize :blue "%%s")
                  "%%c" (colorize :cyan "%%s")
                  "%%g" (colorize :green "%%s")
                  "%%r" (colorize :red "%%s")
                  "%%y" (colorize :yellow "%%s")
                  :PASSED (colorize :green :PASSED)
                  :FAILED (colorize :red :FAILED)})
  (var s str)
  (map-tbl (fn [dst src]
             (set s (s:gsub src dst))) pattern)
  (string.format s ...))

(fn output-format []
  (-> "Format: [%y] %g => %y -> %r | %g"
      (colorful-format :suite-name :status :expr :got :expect) (print)))

(fn output-succ [name]
  (-> "[%y] PASSED" (colorful-format name) (print)))

(fn output-fail [name info]
  (-> "[%y] FAILED => %y -> %r | %g"
      (colorful-format name info.expr-str (view info.got) (view info.expect))
      (print)))

(fn output-summary [smy]
  (local all-num (+ smy.passed-num smy.failed-num))
  (local msg
         (if smy.passed?
             (string.format "%d/%d cases PASSED" smy.passed-num all-num)
             (string.format "%d/%d cases FAILED" smy.failed-num all-num)))
  (print (-> (length msg) (repeat "=")))
  (print (colorful-format msg)))

;; Do tests

(fn M.dotests [tests]
  (fn dosuites [tests]
    "[{:name str :cases [case]}] -> [{:name str :cases [case-statis]}]
     case: {
         expr: function that return a result
         expr-str: (fennel.view body-of-expr)
         expect: expected-value
         }
     case-statis: {
         expr-str(string): expr-str in case
         got: result of executed expr in case
         expect: expected-value
         passed?(bool): status of the suite
         }"
    (fn doeach-suite [suite]
      "{:name str :cases [case]} -> {:name str :cases [case-statis]}"
      (fn deep-match? [got expect]
        (match expect
          [maybe.placeholder] (maybe.matcher got expect)
          _ (eq? got expect)))

      (fn output-suite [suiteinfo]
        "{:name str :cases [case-statis]} -> nil"
        (let [failed-cases (filter-lst #(not $1.passed?) suiteinfo.cases)]
          (match (length failed-cases)
            0 (output-succ suiteinfo.name)
            _ (map-lst #(output-fail suiteinfo.name $1) failed-cases))))

      (let [suite-res {:name suite.name
                       :cases (-> (fn [case]
                                    (let [res (case.expr)]
                                      ;; case-statis
                                      {:passed? (deep-match? res case.expect)
                                       :name suite.name
                                       :expr-str case.expr-str
                                       :expect case.expect
                                       :got res}))
                                  (map-lst suite.cases))}]
        (output-suite suite-res)
        suite-res))

    (map-lst doeach-suite tests))

  (fn summary [statis]
    "[{:name str :cases [case-statis]}] -> smy
       smy: {
             :passed? bool
             :passed-num number-of-passed-cases
             :failed-num number-of-failed-cases
           }"
    (fn count-case [pred statis]
      (-> (fn [suite]
            (count pred suite.cases))
          (map-lst statis)
          (sum)))

    (local passed-num (count-case #$1.passed? statis))
    (local failed-num (count-case #(not $1.passed?) statis))
    {:passed? (= failed-num 0) : passed-num : failed-num})

  (fn exit [smy]
    (os.exit (if smy.passed? 0 1)))

  (output-format)
  (local smy (-> tests (dosuites) (summary)))
  (output-summary smy)
  (exit smy))

M

