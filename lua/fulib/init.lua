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
M["tbl?"] = function(v)
  return (type(v) == "table")
end
M["list?"] = function(v)
  local function _2_()
    local t_1_ = v
    if (nil ~= t_1_) then
      t_1_ = (t_1_)[1]
    end
    return t_1_
  end
  return (M["tbl?"](v) and (M["empty?"](v) or not M["nil?"](_2_())))
end
local function flt_eq_3f(flt1, flt2)
  return (math.abs((flt1 - flt2)) < 1e-06)
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
  if ((type(_5_) == "table") and ((_5_)[1] == "number") and ((_5_)[2] == "number")) then
    return flt_eq_3f(v1, v2)
  elseif ((type(_5_) == "table") and ((_5_)[1] == "table") and ((_5_)[2] == "table")) then
    return tbl_eq_3f(v1, v2)
  else
    local _ = _5_
    return (v1 == v2)
  end
end
M.copy = function(tbl)
  return M.map(M.id, tbl)
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
M["empty?"] = function(v)
  local _7_ = {type(v)}
  if ((type(_7_) == "table") and ((_7_)[1] == "string")) then
    return (v == "")
  elseif ((type(_7_) == "table") and ((_7_)[1] == "table")) then
    return M["nil?"](next(v))
  else
    local _ = _7_
    return false
  end
end
M["member?"] = function(elem, tbl)
  local function _9_(_241)
    return M["eq?"](elem, _241)
  end
  return M.any(_9_, tbl)
end
M["tbl-keys"] = function(tbl)
  local ntbl = {}
  local function _10_(_241, _242)
    return M.append(ntbl, _242)
  end
  M.for_each(_10_, tbl)
  return ntbl
end
M["tbl-values"] = function(tbl)
  local ntbl = {}
  local function _11_(_241)
    return M.append(ntbl, _241)
  end
  M.for_each(_11_, tbl)
  return ntbl
end
M.id = function(v)
  return v
end
local function all_lst(pred, lst)
  for i = 1, #lst do
    if not pred(lst[i], i) then
      return false
    end
  end
  return true
end
local function all_tbl(pred, tbl)
  for k, v in pairs(tbl) do
    if not pred(v, k) then
      return false
    end
  end
  return true
end
M.all = function(pred, tbl)
  local _14_
  if M["list?"](tbl) then
    _14_ = all_lst
  else
    _14_ = all_tbl
  end
  return _14_(pred, tbl)
end
M.any = function(pred, tbl)
  local function _16_(...)
    return not pred(...)
  end
  return not M.all(_16_, tbl)
end
M.append = function(tbl, v)
  tbl[(#tbl + 1)] = v
  return tbl
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
M.for_each = function(f, tbl)
  local _17_
  if M["list?"](tbl) then
    _17_ = for_each_in_lst
  else
    _17_ = for_each_in_tbl
  end
  return _17_(f, tbl)
end
M.map = function(f, tbl)
  local ntbl = {}
  if M["list?"](tbl) then
    local function _19_(_241, _242)
      return M.append(ntbl, f(_241, _242))
    end
    M.for_each(_19_, tbl)
  else
    local function _20_(_241, _242)
      ntbl[_242] = f(_241, _242)
      return nil
    end
    M.for_each(_20_, tbl)
  end
  return ntbl
end
M.filter = function(pred, tbl)
  local function _22_(_241, _242)
    if pred(_241, _242) then
      return _241
    end
  end
  return M.map(_22_, tbl)
end
M.foldl = function(f, init, lst)
  local acc = init
  local function _24_(_241, _242)
    acc = f(acc, _241, _242)
    return nil
  end
  M.for_each(_24_, lst)
  return acc
end
M.foldr = function(f, init, lst)
  local acc = init
  local function _25_(_241, _242)
    acc = f(_241, acc, _242)
    return nil
  end
  M.for_each(_25_, M.reverse(lst))
  return acc
end
M.reverse = function(lst)
  local function _26_(_241, _242)
    return lst[((#lst + 1) - _242)]
  end
  return M.map(_26_, lst)
end
local function to_exist_map(lst)
  local ntbl = {}
  local function _27_(_241)
    ntbl[_241] = true
    return nil
  end
  for_each_in_lst(_27_, lst)
  return ntbl
end
local function intersect_lst(tbl1, tbl2)
  local in_tbl1 = to_exist_map(tbl1)
  local function _28_(_241)
    return (in_tbl1)[_241]
  end
  return M.filter(_28_, tbl2)
end
local function intersect_tbl(tbl1, tbl2)
  if M["list?"](tbl1) then
    local function _29_(_241, _242)
      return not M["nil?"]((tbl1)[_242])
    end
    return M.filter(_29_, tbl2)
  else
    local function _30_(_241, _242)
      return not M["nil?"]((tbl2)[_242])
    end
    return M.filter(_30_, tbl1)
  end
end
M.intersect = function(tbl1, tbl2)
  if (M["list?"](tbl1) and M["list?"](tbl2)) then
    return intersect_lst(tbl1, tbl2)
  else
    return intersect_tbl(tbl1, tbl2)
  end
end
local function range(start, _end)
  local nlst = {}
  for i = start, _end do
    M.append(nlst, i)
  end
  return nlst
end
M.zip_with = function(f, lst1, lst2)
  local len = math.min(#lst1, #lst2)
  local function _33_(_241)
    return f((lst1)[_241], (lst2)[_241])
  end
  return M.map(_33_, range(1, len))
end
M.zip = function(lst1, lst2)
  local function _34_(_241, _242)
    return {_241, _242}
  end
  return M.zip_with(_34_, lst1, lst2)
end
local function neg_register(fname)
  local function _35_(...)
    return not M[fname](...)
  end
  M[("!" .. fname)] = _35_
  return nil
end
local function neg_registers(fnames)
  local function _36_(_241)
    return neg_register(_241)
  end
  return M.for_each(_36_, fnames)
end
neg_registers({"tbl?", "list?", "nil?", "flt_eq?", "tbl_eq?", "eq?", "empty?", "member?"})
return M
