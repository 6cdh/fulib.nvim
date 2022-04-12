local M = {}
M.inc = function(num)
  return (num + 1)
end
M.dec = function(num)
  return (num - 1)
end
M["odd?"] = function(num)
  return ((num % 2) == 1)
end
M["even?"] = function(num)
  return not M["odd?"](num)
end
M["nil?"] = function(v)
  return (v == nil)
end
M["not-nil?"] = function(v)
  return (v ~= nil)
end
M["table?"] = function(v)
  return (type(v) == "table")
end
M["not-table?"] = function(v)
  return not M["table?"](v)
end
M["list?"] = function(v)
  local function _2_()
    local t_1_ = v
    if (nil ~= t_1_) then
      t_1_ = (t_1_)[1]
    else
    end
    return t_1_
  end
  return (M["table?"](v) and (M["empty?"](v) or not M["nil?"](_2_())))
end
M["not-list?"] = function(v)
  return not M["list?"](v)
end
local function flt_eq_3f(flt1, flt2)
  return (math.abs((flt1 - flt2)) < 1e-15)
end
local function subset_3f(tbl1, tbl2)
  local function _4_(v, k)
    return M["eq?"]((tbl2)[k], v)
  end
  return M.all(_4_, tbl1)
end
local function tbl_eq_3f(tbl1, tbl2)
  return (subset_3f(tbl1, tbl2) and subset_3f(tbl2, tbl1))
end
M["eq?"] = function(v1, v2)
  local _5_ = {type(v1), type(v2)}
  if ((_G.type(_5_) == "table") and ((_5_)[1] == "number") and ((_5_)[2] == "number")) then
    return flt_eq_3f(v1, v2)
  elseif ((_G.type(_5_) == "table") and ((_5_)[1] == "table") and ((_5_)[2] == "table")) then
    return tbl_eq_3f(v1, v2)
  elseif true then
    local _ = _5_
    return (v1 == v2)
  else
    return nil
  end
end
M["not-eq?"] = function(v1, v2)
  return not M["eq?"](v1, v2)
end
M.cons = function(elem, lst)
  local nlst = M.copy(lst)
  table.insert(nlst, 1, elem)
  return nlst
end
M.car = function(lst)
  return lst[1]
end
M.cdr = function(lst)
  local nlst = M.copy(lst)
  table.remove(nlst, 1)
  return nlst
end
M.copy = function(tbl)
  return M.map(M.id, tbl)
end
M.length = function(tbl)
  if M["list?"](tbl) then
    return #tbl
  else
    return #M["table-values"](tbl)
  end
end
M["empty?"] = function(v)
  local _8_ = {type(v)}
  if ((_G.type(_8_) == "table") and ((_8_)[1] == "string")) then
    return (v == "")
  elseif ((_G.type(_8_) == "table") and ((_8_)[1] == "table")) then
    return M["nil?"](next(v))
  elseif true then
    local _ = _8_
    return false
  else
    return nil
  end
end
M["not-empty?"] = function(v)
  return not M["empty?"](v)
end
M["member?"] = function(elem, tbl)
  local function _10_(_241)
    return M["eq?"](elem, _241)
  end
  return M.any(_10_, tbl)
end
M["not-member?"] = function(elem, tbl)
  return not M["member?"](elem, tbl)
end
M["table-keys"] = function(tbl)
  local ntbl = {}
  local function _11_(_241, _242)
    return M["append!"](ntbl, _242)
  end
  M["for-each"](_11_, tbl)
  return ntbl
end
M["table-values"] = function(tbl)
  local ntbl = {}
  local function _12_(_241)
    return M["append!"](ntbl, _241)
  end
  M["for-each"](_12_, tbl)
  return ntbl
end
M.indexed = function(list)
  local function _13_(_241, _242)
    return {_242, _241}
  end
  return M.map(_13_, list)
end
M.first = function(list)
  return M.car(list)
end
M.last = function(list)
  return list[#list]
end
M["append!"] = function(tbl, v)
  tbl[(#tbl + 1)] = v
  return tbl
end
M.range = function(start, _end, step)
  local step0 = (step or 1)
  local nlst = {}
  for i = start, _end, step0 do
    M["append!"](nlst, i)
  end
  return nlst
end
M.id = function(v)
  return v
end
local function all_lst(pred, lst)
  for i = 1, #lst do
    if not pred(lst[i], i) then
      return false
    else
    end
  end
  return true
end
local function all_tbl(pred, tbl)
  for k, v in pairs(tbl) do
    if not pred(v, k) then
      return false
    else
    end
  end
  return true
end
M.all = function(pred, tbl)
  local _16_
  if M["list?"](tbl) then
    _16_ = all_lst
  else
    _16_ = all_tbl
  end
  return _16_(pred, tbl)
end
M.any = function(pred, tbl)
  local function _18_(...)
    return not pred(...)
  end
  return not M.all(_18_, tbl)
end
local function for_each_in_lst(f, lst)
  for i = 1, #lst do
    f(lst[i], i)
  end
  return nil
end
local function for_each_in_tbl(f, tbl)
  for i, v in pairs(tbl) do
    f(v, i)
  end
  return nil
end
M["for-each"] = function(f, tbl)
  local _19_
  if M["list?"](tbl) then
    _19_ = for_each_in_lst
  else
    _19_ = for_each_in_tbl
  end
  return _19_(f, tbl)
end
M.map = function(f, tbl)
  local ntbl = {}
  if M["list?"](tbl) then
    local function _21_(_241, _242)
      return M["append!"](ntbl, f(_241, _242))
    end
    M["for-each"](_21_, tbl)
  else
    local function _22_(_241, _242)
      ntbl[_242] = f(_241, _242)
      return nil
    end
    M["for-each"](_22_, tbl)
  end
  return ntbl
end
M.filter = function(pred, tbl)
  local function _24_(_241, _242)
    if pred(_241, _242) then
      return _241
    else
      return nil
    end
  end
  return M.map(_24_, tbl)
end
M.count = function(pred, tbl)
  return M.length(M.filter(pred, tbl))
end
M.foldl = function(f, init, lst)
  local acc = init
  local function _26_(_241, _242)
    acc = f(acc, _241, _242)
    return nil
  end
  M["for-each"](_26_, lst)
  return acc
end
M.foldr = function(f, init, lst)
  local acc = init
  local function _27_(_241, _242)
    acc = f(_241, acc, _242)
    return nil
  end
  M["for-each"](_27_, M.reverse(lst))
  return acc
end
M.reverse = function(lst)
  local function _28_(_241, _242)
    return lst[((#lst + 1) - _242)]
  end
  return M.map(_28_, lst)
end
local function to_exist_map(lst)
  local ntbl = {}
  local function _29_(_241)
    ntbl[_241] = true
    return nil
  end
  for_each_in_lst(_29_, lst)
  return ntbl
end
local function intersect_lst(tbl1, tbl2)
  local in_tbl1 = to_exist_map(tbl1)
  local function _30_(_241)
    return (in_tbl1)[_241]
  end
  return M.filter(_30_, tbl2)
end
local function intersect_tbl(tbl1, tbl2)
  if M["list?"](tbl1) then
    local function _31_(_241, _242)
      return not M["nil?"]((tbl1)[_242])
    end
    return M.filter(_31_, tbl2)
  else
    local function _32_(_241, _242)
      return not M["nil?"]((tbl2)[_242])
    end
    return M.filter(_32_, tbl1)
  end
end
M.intersect = function(tbl1, tbl2)
  if (M["list?"](tbl1) and M["list?"](tbl2)) then
    return intersect_lst(tbl1, tbl2)
  else
    return intersect_tbl(tbl1, tbl2)
  end
end
M["zip-with"] = function(f, lst1, lst2)
  local len = math.min(#lst1, #lst2)
  local function _35_(_241)
    return f((lst1)[_241], (lst2)[_241])
  end
  return M.map(_35_, M.range(1, len))
end
M.zip = function(lst1, lst2)
  local function _36_(_241, _242)
    return {_241, _242}
  end
  return M["zip-with"](_36_, lst1, lst2)
end
return M
