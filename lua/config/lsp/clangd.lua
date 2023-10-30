local table_ext_methods = {}

function table_ext_methods:keys()
  local keys = {}
  local n = 0
  for k, v in pairs(self) do
    n = n + 1
    keys[n] = k
  end
  return keys
end

function table_ext_methods:values()
  local values = {}
  local n = 0
  for k, v in pairs(self) do
    n = n + 1
    values[n] = v
  end
  return values
end

local table_ext_mt = {__index = table_ext_methods}

local sep = (function()
  if jit then
    local os = string.lower(jit.os)
    if os ~= 'windows' then
      return '/'
    else
      return '\\'
    end
  else
    return package.config:sub(1, 1)
  end
end)()

function my_split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

local function parse_source(root)
  local src = {}
  local inc_dir = {}
  local stack = {root}
  while #stack > 0 do
    local dir = table.remove(stack)
    local handle = vim.loop.fs_scandir(dir)
    while handle do
      local name, typ = vim.loop.fs_scandir_next(handle)
      if not name then
        break
      end
      if typ == 'directory' then
        table.insert(stack, dir .. sep .. name)
      else
        assert(typ == 'file')
        if string.match(name, '%.cc?$') or string.match(name, '%.cpp$') or string.match(name, '%.cxx$') or string.match(name, '%.c++$') then
          local rel_file = string.gsub(dir .. sep .. name, '^' .. root .. sep, '')
          table.insert(src, rel_file)
        elseif string.match(name, '%.hh?$') or string.match(name, '%.hpp$') or string.match(name, '%.hxx$') then
          -- trim root path
          local rel_dir = string.gsub(dir, '^' .. root .. sep, '')
          if inc_dir[rel_dir] == nil then
            inc_dir[rel_dir] = rel_dir
          end

          -- trim sub path one by one
          local split_element_all = my_split(rel_dir, sep)
          local new_path = rel_dir
          while #split_element_all > 1 do
            local split_path = table.remove(split_element_all)
            new_path = string.gsub(new_path, sep .. split_path .. '$', '') -- trim root path
            if inc_dir[new_path] == nil then
              inc_dir[new_path] = new_path
            end
          end
        end
      end
    end
  end

  setmetatable(inc_dir, table_ext_mt)
  inc_dir = inc_dir:values()
  table.sort(inc_dir)
  table.sort(src)

  return src, inc_dir
end

function generate_compile_commands(root)
  root = root or vim.fn.getcwd()
  local src, inc_dir = parse_source(root)

  local function replace_sep(s)
    return string.gsub(s, '\\', '/')
  end

  local function to_str(t)
    local f = ''
    for _, v in ipairs(t) do
      f = f .. '-I \\"' .. replace_sep(v) .. '\\" '
    end
    return f
  end

  local commands = {}
  for _, v in ipairs(src) do
    local command = {}
    local new_v = replace_sep(v)
    command['directory'] = replace_sep(root)
    command['command'] = 'clang -m32 ' .. to_str(inc_dir) .. '\\"' .. new_v .. '\\"'
    command['file'] = new_v
    table.insert(commands, command)
  end

  local function to_file(t)
    local f = '[\n'
    for i, c in ipairs(t) do
      f = f .. '  {\n'
      for k, v in pairs(c) do
        f = f .. string.format('    "%s": "%s"', k, v)
        if next(c, k) then
          f = f .. ','
        end
        f = f .. '\n'
      end
      f = f .. '  }'
      if i < #t then
        f = f .. ','
      end
      f = f .. '\n'
    end
    f = f .. ']'
    return f
  end

  local file = io.open(root .. sep .. 'compile_commands.json', 'w+')
  file:write(to_file(commands))
  file:close()
end

function generate_compile_flags(root)
  root = root or vim.fn.getcwd()
  local _, inc_dir = parse_source(root)

  local function to_file(t)
    local f = ''
    for _, v in ipairs(t) do
      f = f .. '-I\n' .. v .. sep .. '\n'
    end
    return f
  end

  local file = io.open(root .. sep .. 'compile_flags.txt', 'w+')
  file:write(to_file(inc_dir))
  file:close()
end
