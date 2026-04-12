local lfs = require "lfs"
local io = require "io"
local markdown = require "markdown"
local aspect_template = require "aspect.template"
local aspect = aspect_template.new()

-- string
local function s_startswith(str, start_str)
    if not str then return false end
    return string.sub(str, 1, string.len(start_str)) == start_str
end

local function s_endswith(str, end_str)
    if not str then return false end
    return end_str == '' or string.sub(str, -string.len(end_str)) == end_str
end

-- file
local function f_ensure_dir(dir)
    if dir == "" or dir == "." then return true end
    local ok, err = lfs.attributes(dir)
    if ok then return true end             -- 目录已存在
    -- 逐级创建父目录
    local parent = dir:match("^(.*)[/\\]") -- 提取父目录（兼容 Windows/Unix）
    if parent then
        f_ensure_dir(parent)
    end
    return lfs.mkdir(dir)
end

local function f_copy(src, dst)
    -- 确保目标目录存在
    local dst_dir = dst:match("^(.*)[/\\]")
    if dst_dir then
        f_ensure_dir(dst_dir)
    end
    local src_file = io.open(src, "rb")
    if not src_file then return false, "无法打开源文件" end
    local dst_file = io.open(dst, "wb")
    if not dst_file then
        src_file:close()
        return false, "无法创建目标文件"
    end
    local data = src_file:read("*all")
    dst_file:write(data)
    src_file:close()
    dst_file:close()
    return true
end

local function f_read(path)
    local file = io.open(path, "r")
    if not file then return nil end
    return file:read("*a")
end

local function f_write(path, data)
    local dst_dir = path:match("^(.*)[/\\]")
    if dst_dir then
        f_ensure_dir(dst_dir)
    end
    io.open(path, "w"):write(data)
end



aspect.loader = function(name)
    local file_path = "templates/" .. name .. ".html"
    local file = io.open(file_path, "r")
    if not file then
        print("file not found: " .. file_path)
        return nil
    end
    return file:read("*a")
end

-- 解析文件元数据
-- 返回元数据table、移除元数据后的content
local function parse_meta_data(content)
    -- 将文件内容按行分割（兼容 CR, LF, CRLF）
    local lines = {}
    for line in content:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end

    local metadata = {}
    local i = #lines

    -- 跳过末尾的空行（只包含空白字符的行）
    while i >= 1 and lines[i]:match("^%s*$") do
        i = i - 1
    end

    -- 从后向前收集连续的 @ 开头的元数据行
    while i >= 1 and lines[i]:match("^@") do
        -- 提取 key 和 value：@key value（value 直到行尾，允许包含空格）
        local key, value = lines[i]:match("^@(%w+)%s+(.+)$")
        if key and value then
            metadata[key] = value
        else local flag = lines[i]:match("^@(%w+)$")
            if flag then
                meta_data[flag] = true
            end
        end
        i = i - 1
    end

    return metadata, table.concat(lines, "\n", 1, i)
end

local input_root_directory = ".."
local output_root_directory = "../.build"
local function traverse(directory, doc_root)
    local post_list = {}
    for file_name in lfs.dir(directory) do
        if not s_startswith(file_name, ".") then
            local input_file_path = directory .. "/" .. file_name
            local attr = lfs.attributes(input_file_path)
            if attr.mode == "file" then
                if s_endswith(file_name, ".md") then
                    local content = f_read(input_file_path)
                    local first_line = string.match(content, "^[^\n]+")
                    local title
                    if s_startswith(first_line, "# ") then
                        title = string.sub(first_line, 3)
                        content = string.sub(content, string.len(first_line) + 2)
                    end
                    local meta_data, rest_content = parse_meta_data(content)
                   
                    local date = meta_data.date or ""
                    local author = meta_data.author or ""
                    content = rest_content

                    post_list[#post_list + 1] = {
                        input_file_path = input_file_path,
                        title = title,
                        file_name = file_name:gsub(".md$", ".html"),
                        content = content,
                        doc_root = doc_root,
                        markdown_html = markdown(content),
                        meta_data = meta_data
                    }
                end
            elseif attr.mode == "directory" then
                traverse(input_file_path, doc_root .. "../")
            end
        end
    end
    if #post_list > 0 then
        table.sort(post_list, function(a, b)
            if a.date == b.date then
                return a.file_name > b.file_name
            end
            return a.date > b.date
        end)

        local post_list_count = #post_list
        for _, post in ipairs(post_list) do
            local markdown_html = markdown(post.content)
            local result, error = aspect:render("post", post)
            if error then
                print(error)
            else
                local output_file_path
                if post_list_count == 1 then
                    output_file_path = directory:gsub("^" .. input_root_directory, output_root_directory) .. "/index.html"
                else
                    output_file_path = post.input_file_path
                        :gsub("^" .. input_root_directory, output_root_directory)
                        :gsub(".md$", ".html")
                end
                print("write post", output_file_path, post.meta_data.author, post.meta_data.date)

                -- io.open(output_file_path, "w"):write(html):close()
                f_write(output_file_path, tostring(result))
            end
        end


        if post_list_count > 1 then
            local result, error = aspect:render("index", { post_list = post_list, doc_root = doc_root })
            if error then
                print(error)
            else
                local output_file_path = directory:gsub("^" .. input_root_directory, output_root_directory) .. "/index.html"
                print("write index", output_file_path)
                -- io.open(output_file_path, "w"):write(html):close()
                f_write(output_file_path, tostring(result))
            end
        end
    end
end

traverse(input_root_directory, "./")
f_copy("css/style.css", "../.build/css/style.css")
