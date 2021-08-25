(fn testsuite [module name tests]
  (local case-list [])
  (each [expr expect (pairs tests)]
    (table.insert case-list {:expr `#,expr :expr-str (view expr) : expect}))
  ;; NOTE: See https://github.com/bakpakin/Fennel/issues/384 about why use
  ;; `(#(something)) rather than `(something)
  `(#(table.insert ,module {:name ,name :cases ,case-list})))

{: testsuite}

