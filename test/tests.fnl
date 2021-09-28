(local fennel (require :fennel))
(set fennel.path (.. "../fnl/?/init.fnl;" fennel.path))

(local fl (require :fulib))
(local {: maybe : dotests} (require :tester))
(import-macros ms :tester.macros)

(local M {})

(macro testsuite [name tests]
  `(ms.testsuite M ,name ,tests))

;; numeric

(testsuite :inc {(fl.inc -1) 0
                 (fl.inc 0) 1
                 (fl.inc 1) 2
                 (fl.inc :-1) 0
                 (fl.inc :0) 1
                 (fl.inc :1) 2})

(testsuite :dec {(fl.dec -1) -2
                 (fl.dec 0) -1
                 (fl.dec 1) 0
                 (fl.dec :-1) -2
                 (fl.dec :0) -1
                 (fl.dec :1) 0})

(testsuite :odd? {(fl.odd? 1) true (fl.odd? 0) false})

(testsuite :even? {(fl.even? 0) true (fl.even? 1) false})

;; type

(testsuite :nil? {(fl.nil? nil) true
                  (fl.nil? false) false
                  (fl.nil? true) false
                  (fl.nil? []) false
                  (fl.nil? [1]) false
                  (fl.nil? {:k :v}) false
                  (fl.nil? "") false
                  (fl.nil? :1) false
                  (fl.nil? #1) false
                  (fl.nil? 1) false
                  (fl.nil? 0) false})

(testsuite :not-nil? {(fl.not-nil? nil) false
                      (fl.not-nil? false) true
                      (fl.not-nil? true) true
                      (fl.not-nil? []) true
                      (fl.not-nil? [1]) true
                      (fl.not-nil? {:k :v}) true
                      (fl.not-nil? "") true
                      (fl.not-nil? :1) true
                      (fl.not-nil? #1) true
                      (fl.not-nil? 1) true
                      (fl.not-nil? 0) true})

(testsuite :table? {(fl.table? nil) false
                  (fl.table? false) false
                  (fl.table? true) false
                  (fl.table? []) true
                  (fl.table? [1]) true
                  (fl.table? {:k :v}) true
                  (fl.table? "") false
                  (fl.table? :1) false
                  (fl.table? #1) false
                  (fl.table? 1) false
                  (fl.table? 0) false})

(testsuite :not-table? {(fl.not-table? nil) true
                      (fl.not-table? false) true
                      (fl.not-table? true) true
                      (fl.not-table? []) false
                      (fl.not-table? [1]) false
                      (fl.not-table? {:k :v}) false
                      (fl.not-table? "") true
                      (fl.not-table? :1) true
                      (fl.not-table? #1) true
                      (fl.not-table? 1) true
                      (fl.not-table? 0) true})

(testsuite :list? {(fl.list? nil) false
                   (fl.list? false) false
                   (fl.list? true) false
                   (fl.list? []) true
                   (fl.list? [1]) true
                   (fl.list? {:k :v}) false
                   (fl.list? "") false
                   (fl.list? :1) false
                   (fl.list? #1) false
                   (fl.list? 1) false
                   (fl.list? 0) false})

(testsuite :not-list? {(fl.not-list? nil) true
                       (fl.not-list? false) true
                       (fl.not-list? true) true
                       (fl.not-list? []) false
                       (fl.not-list? [1]) false
                       (fl.not-list? {:k :v}) true
                       (fl.not-list? "") true
                       (fl.not-list? :1) true
                       (fl.not-list? #1) true
                       (fl.not-list? 1) true
                       (fl.not-list? 0) true})

(testsuite :eq? {(fl.eq? true true) true
                 (fl.eq? false false) true
                 (fl.eq? true false) false
                 (fl.eq? false true) false
                 (fl.eq? 1.2 (* 0.2 6)) true
                 (fl.eq? "1 " "1 ") true
                 (fl.eq? nil nil) true
                 (fl.eq? [] []) true
                 (fl.eq? [1] [1]) true
                 (fl.eq? [1] []) false
                 (fl.eq? [1] :1) false
                 (fl.eq? nil false) false
                 (let [t []]
                    (table.insert t 1)
                    (fl.eq? t [1])) true})

(testsuite :not-eq? {(fl.not-eq? true true) false
                     (fl.not-eq? false false) false
                     (fl.not-eq? true false) true
                     (fl.not-eq? false true) true
                     (fl.not-eq? 1.2 (* 0.2 6)) false
                     (fl.not-eq? "1 " "1 ") false
                     (fl.not-eq? nil nil) false
                     (fl.not-eq? [] []) false
                     (fl.not-eq? [1] [1]) false
                     (fl.not-eq? [1] []) true
                     (fl.not-eq? [1] :1) true
                     (fl.not-eq? nil false) true
                     (let [t []]
                        (table.insert t 1)
                        (fl.not-eq? t [1])) false})

(testsuite :copy {(fl.copy []) []
                  (fl.copy [1 2 3]) [1 2 3]
                  (fl.copy {:k :v :k2 :v2}) {:k :v :k2 :v2}})

;; Lisp primitives

(testsuite :cons {(fl.cons 1 []) [1]
                  (fl.cons 1 [1]) [1 1]
                  (fl.cons 2 [1]) [2 1]
                  (fl.cons [2] [1]) [[2] 1]
                  (fl.cons true [1]) [true 1]})

(testsuite :car {(fl.car [2 3]) 2 (fl.car [[1 2 3] 2 3]) [1 2 3]})

(testsuite :cdr {(fl.cdr [2 3]) [3]
                 (fl.cdr [[2 3]]) []
                 (fl.cdr [true 1]) [1]
                 (fl.cdr [[2] 3]) [3]
                 (fl.cdr [2 [3]]) [[3]]})

;; List

(testsuite :empty? {(fl.empty? nil) false
                    (fl.empty? false) false
                    (fl.empty? true) false
                    (fl.empty? []) true
                    (fl.empty? [1]) false
                    (fl.empty? {:k :v}) false
                    (fl.empty? "") true
                    (fl.empty? :1) false
                    (fl.empty? #1) false
                    (fl.empty? 1) false
                    (fl.empty? 0) false})

(testsuite :not-empty? {(fl.not-empty? nil) true
                        (fl.not-empty? false) true
                        (fl.not-empty? true) true
                        (fl.not-empty? []) false
                        (fl.not-empty? [1]) true
                        (fl.not-empty? {:k :v}) true
                        (fl.not-empty? "") false
                        (fl.not-empty? :1) true
                        (fl.not-empty? #1) true
                        (fl.not-empty? 1) true
                        (fl.not-empty? 0) true})

(testsuite :member? {(fl.member? 3 [2 3]) true
                     (fl.member? 1 [2 4]) false
                     (fl.member? 2 [:k 1 :k2 2]) true
                     (fl.member? 3 [:k 1 :k2 2]) false
                     (fl.member? false [:k 1 :k2 2]) false})

(testsuite :not-member?
           {(fl.not-member? 3 [2 3]) false
            (fl.not-member? 1 [2 4]) true
            (fl.not-member? 2 [:k 1 :k2 2]) false
            (fl.not-member? 3 [:k 1 :k2 2]) true
            (fl.not-member? false [:k 1 :k2 2]) true})

(testsuite :table-keys {(fl.table-keys {:k 1 :k2 2}) (maybe [:k :k2] [:k2 :k])
                      (fl.table-keys []) []
                      (fl.table-keys [4 5 6]) [1 2 3]})

(testsuite :table-values {(fl.table-values {:k :v :k2 :v2}) (maybe [:v :v2]
                                                               [:v2 :v])
                        (fl.table-values []) []
                        (fl.table-values [4 5 6]) [4 5 6]})

(testsuite :id {(fl.id 1) 1
                (fl.id :1) :1
                (fl.id []) []
                (fl.id {:k :v}) {:k :v}
                (let [tbl []]
                   (table.insert tbl 1)
                   (= (fl.id tbl) tbl)) true})

(testsuite :all
           {(fl.all #(= true $1) [true true true]) true
            (fl.all #(= 1 $1) [1 1 1 2]) false
            (fl.all #(> $1 0) [1 2 3]) true
            (fl.all #(> $1 0) [1 2 -3]) false
            (fl.all #(if (-> (% $2 2) (= 1)) (> $1 0) true) [1 -1 2 -2]) true
            (fl.all #(= (type $2) :string) {:k :v :k2 :v2}) true
            (fl.all #(= (type $2) :string) {2 :v2 :k :v}) false})

(testsuite :any
           {(fl.any #(= true $1) [true true true]) true
            (fl.any #(= 1 $1) [1 1 1 2]) true
            (fl.any #(= 1 $1) [2 3 -1 2]) false
            (fl.any #(> $1 0) [1 2 3]) true
            (fl.any #(< $1 0) [1 2 -3]) true
            (fl.any #(if (-> (% $2 2) (= 1)) (> $1 0) false) [-1 1 -2 2 3 4]) true
            (fl.any #(= (type $2) :string) {2 :v :k2 :v2}) true
            (fl.any #(= (type $2) :string) {2 :v2 3 :v}) false})

(testsuite :append {(fl.append [] 1) [1]
                    (fl.append [1] 2) [1 2]
                    (fl.append [:x] 0) [:x 0]})

(testsuite :for_each {(fl.for_each #$ [1 2 3]) nil})

(testsuite :map
           {(fl.map #(* 2 $1) [2 4 6]) [4 8 12]
            (fl.map #(+ $1 1) [2 3 5]) [3 4 6]
            (fl.map #(+ $1 1) {:k 1 :k2 :2}) {:k 2 :k2 3}
            (fl.map tostring {:k 1 :k2 :2}) {:k :1 :k2 :2}})

(testsuite :filter
           {(fl.filter #(> $1 2) [1 2 3 4 5]) [3 4 5]
            (fl.filter #(-> (% $1 2) (= 0)) [1 2 3 4 5]) [2 4]
            (fl.filter #(-> (% $2 2) (= 1)) [1 2 3 4 5]) [1 3 5]
            (fl.filter #(= (type $2) :string) {3 :x :k :v :k2 :v2}) {:k :v
                                                                     :k2 :v2}})

;; fnlfmt: skip
(testsuite :foldl
           {(fl.foldl #(+ $1 $2) 0 [1 2 3 4]) 10
            (fl.foldl #(* $1 $2) 1 [1 2 3 4]) 24
            (fl.foldl (fn [acc v]
                          (table.insert acc 1 v) acc) []
                        [1 2 3]) [3 2 1]})

;; fnlfmt: skip
(testsuite :foldr {
           (fl.foldr #(+ $1 $2) 0 [1 2 3 4]) 10
            (fl.foldr #(* $1 $2) 1 [1 2 3 4]) 24
            (fl.foldr (fn [v acc]
                          (table.insert acc v) acc) []
                        [1 2 3]) [3 2 1]})

(testsuite :reverse {(fl.reverse [1 2 3]) [3 2 1] (fl.reverse []) []})

(testsuite :intersect
           {(fl.intersect [1 2 3] [2 3 4]) [2 3]
            (fl.intersect {:k :v :k2 :v2 :k3 :v3} {:k :v :k3 :v3 :k4 :v4}) {:k :v
                                                                            :k3 :v3}
            (fl.intersect [] [1 2 3]) []
            (fl.intersect [1 2 3] []) []
            (fl.intersect [] []) []
            (fl.intersect {2 3 :k :v} [1 3]) {2 3}
            (fl.intersect [1 3] {2 3 :k :v}) {2 3}})

(testsuite :zip {(fl.zip [1 2 3] [2 3 4]) [[1 2] [2 3] [3 4]]
                 (fl.zip [1 2 3] []) []
                 (fl.zip [] [1 2 3]) []
                 (fl.zip [1 2] [1 2 3]) [[1 1] [2 2]]})

(testsuite :zip_with
           {(fl.zip_with #(* $1 $2) [1 2 3] [4 5 6]) [4 10 18]
            (fl.zip_with #[(+ $1 $2)] [1 2 3] [4 5 6]) [[5] [7] [9]]})

(dotests M)

