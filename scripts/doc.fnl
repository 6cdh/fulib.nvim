(local fennel (require :fennel))
(set fennel.path (.. "../fnl/?/init.fnl;fnl/?/init.fnl;" fennel.path))
(local fl (require :fulib))

(local markdown {:title "# %s"
                 :abstract "%s"
                 :section "## %s"
                 :function "#### %s\n```fennel\n%s\n%s\n```\n%s"
                 :linebreak "\n\n"})

;; The functions in `comment*` namespace can be used in comment of source code to document.

;; fnlfmt: skip
(local comment*
       {:title (fn [str]
                 (string.format markdown.title str))
        :abstract (fn [str]
                    (string.format markdown.abstract str))
        :section (fn [str]
                   (string.format markdown.section str))
        :export (fn []
                  "")
        :function (fn [name args docstring]
                    (let [type-hint (docstring:match "(.-)\n")
                          function-description (docstring:match ".-\n(.*)")]
                      (string.format markdown.function name
                         (string.format "(%s %s)" name
                            (table.concat (fl.map #(. $1 1) args) " "))
                       type-hint function-description)))
        :generated_by (fn []
                        (string.format "Generated by `%s`" (. arg 0)))})

(fn parse [s]
  (fn filter-notnil [s]
    (or s ""))

  (fn parse-list [ast]
    (if (and (= (. ast 1 1) :fn)
             (-> ast (. 2 1) (filter-notnil) (: :find :^M.)))
        (comment*.function (-> (. ast 2 1) (: :sub 3)) (. ast 3) (. ast 4))
        ""))

  (fn parse-comment [s]
    (fn filter-evalable [s]
      (when (not= ";" (s:sub 1 1))
        s))

    (-> s
        (: :gsub ";+%s*@([%w_%-]*)%s*(%b())"
           #(string.format "(%s %q)" $1 ($2:sub 2 -2)))
        (: :gsub ";+%s*@([%w_%-]*)" "(%1)")
        (filter-evalable)
        (filter-notnil)
        (fennel.eval {:env comment*})))

  (fn map-iterator [f it]
    (var forms [])
    (each [k v it]
      (fl.append forms (f v k)))
    forms)

  (let [parse (fennel.parser (fennel.stringStream s) nil {:comments true})
        forms (map-iterator fl.id parse)]
    (-> (fn [ast]
          (if (fennel.list? ast) (parse-list ast)
              (fennel.comment? ast) (parse-comment (. ast 1))
              ""))
        (fl.map forms)
        (table.concat markdown.linebreak))))

(fn main []
  (-> (io.read :*a) (parse) (print)))

(main)

