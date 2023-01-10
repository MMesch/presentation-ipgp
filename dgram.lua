--[[
--inspired by https://github.com/pandoc/lua-filters/tree/master/diagram-generator
dgram

-- classes: pandoc, graphviz, plantuml, mermaid, vegalite, vega, svgbob
-- attributes:
     filetype="svg"|"png"|"pdf"  <-- supported formats
     caption=String <-- adds a figure caption
     showcode=True|False  <-- prints the code as code block in addition to the image
     extraOptions=String <-- these are passed to each runner
]]

-- Module pandoc.system is required and was added in version 2.7.3
PANDOC_VERSION:must_be_at_least '2.7.3'


local system = require 'pandoc.system'
local utils = require 'pandoc.utils'
local paths = require 'pandoc.path'
local with_temporary_directory = system.with_temporary_directory
local with_working_directory = system.with_working_directory

local function convert(infile, convert_to)
  if infile:match "[^.]+$" == "svg" then
      filetype = convert_to:match "[^.]+$"
      pandoc.pipe("rsvg-convert", {infile, "-f", filetype, "-o", convert_to}, '')
  else
     print("conversion of " .. infile .. " to " .. outfile .. " not implemented")
  end
end

local function dump_to_file(content, infile)
  local f = io.open(infile, 'w')
  f:write(content)
  f:close()
end

local function read_from_file(fname)
  local r = io.open(fname, 'rb')
  img_data = r:read("*all")
  r:close()
  return img_data
end

local function with_tmp_file(content, infile, outfile, exec, args,
                convert_to)
  return with_temporary_directory("pandoc_diagram", function (tmpdir)
    return with_working_directory(tmpdir, function ()
      dump_to_file(content, infile)
      pandoc.pipe(exec, args, '')
      if convert_to then
          convert(outfile, convert_to)
      end
      return read_from_file(convert_to or outfile)
    end)
  end)
end
local stringify = function (s)
  return type(s) == 'string' and s or utils.stringify(s)
end

local format_extensions = {
        latex = "pdf",
        pdf = "pdf",
        docx = "png",
        pptx = "png",
        rtf = "png",
        html = "svg"}

local default_filetype = format_extensions[FORMAT] or "svg"
local default_mimetype = "image/" .. default_filetype

local function plantuml(content, filetype, attributes)
  infile = "diag.puml"
  outfile = "diag.svg"
  convert_to = "diag." .. filetype
  local args = {infile, "-tsvg", "-charset", "UTF8"}
  if attributes.extraOptions then
          args[#args+1] = attributes.extraOptions
  end
  return with_tmp_file(content, infile, outfile, "plantuml", args,
          convert_to)
end

local function graphviz(content, filetype, attributes) 
  local args = {"-T" .. filetype}
  if attributes.extraOptions then
          args[#args+1] = attributes.extraOptions
  end

  return pandoc.pipe("dot", args, content)
end

local function mermaid(content, filetype, attributes)
  infile = "diag.mmd"
  outfile = "diag." .. filetype
  local args = {"-i", infile, "-o", outfile}
  if attributes.extraOptions then
          args[#args+1] = attributes.extraOptions
  end
  return with_tmp_file(content, infile, outfile, "mmdc", args)
end

local function vegalite(content, filetype, attributes)
  executable = "vl2" .. filetype
  local args = {}
  if attributes.extraOptions then
          args[#args+1] = attributes.extraOptions
  end
  return pandoc.pipe(executable, args, content)
end

local function vega(content, filetype, attributes)
  executable = "vg2" .. filetype
  local args = {}
  if attributes.extraOptions then
          args[#args+1] = attributes.extraOptions
  end
  return pandoc.pipe(executable, args, content)
end

local function svgbob(content, filetype, attributes)
  infile = "diag.txt"
  outfile = "diag.svg"
  convert_to = "diag." .. filetype
  local args = {infile, "-o", outfile}
  if attributes.extraOptions then
          args[#args+1] = attributes.extraOptions
  end
  return with_tmp_file(content, infile, outfile, "svgbob",
          args, convert_to)
end

local converters = {
  plantuml = plantuml,
  graphviz = graphviz,
  mermaid = mermaid,
  vegalite = vegalite,
  vega = vega,
  svgbob = svgbob
}

function Meta(meta)
  save_diagrams = meta.save_diagrams
  print(save_diagrams)
end

-- This function is executed on every codeblock in the document:
function CodeBlock(block)
  local img_converter = converters[block.classes[1]]

  -- do nothing if no converter exists
  if not img_converter then
    return nil
  end

  local filetype = block.attributes.filetype or default_filetype
  local mimetype = "image/" .. filetype
  print("filetype is " .. filetype)

  -- Call the correct converter which belongs to the used class:
  local success, img = pcall(
          img_converter, block.text, filetype, block.attributes)

  if not (success and img) then
    io.stderr:write(tostring(img or "no image data has been returned."))
    io.stderr:write('\n')
    error 'Image conversion failed. Aborting.'
  end

  -- Create figure name by hashing the image content
  local fname = pandoc.sha1(img) .. "." .. filetype

  if save_diagrams then
    if PANDOC_STATE.output_file ~= nil then
      local output_dir = paths.directory(PANDOC_STATE.output_file)
      local f = io.open(paths.join({output_dir, fname}), "w")
      f:write(img)
      f:close()
    end
  end

  pandoc.mediabag.insert(fname, mimetype, img)

  local enable_caption = nil

  -- If the user defines a caption, read it as Markdown.
  local caption = block.attributes.caption
    and pandoc.read(block.attributes.caption).blocks[1].content
    or {}

  -- A non-empty caption means that this image is a figure. We have to
  -- set the image title to "fig:" for pandoc to treat it as such.
  local title = #caption > 0 and "fig:" or ""

  -- Transfer identifier and other relevant attributes from the code
  -- block to the image. Currently, only `name` is kept as an attribute.
  -- This allows a figure block starting with:
  --
  --     ```{#fig:example .plantuml caption="Image created by **PlantUML**."}
  --
  -- to be referenced as @fig:example outside of the figure when used
  -- with `pandoc-crossref`.
  local img_attr = {
    id = block.identifier,
    name = block.attributes.name,
    width = block.attributes.width
  }

  -- Create a new image for the document's structure. Attach the user's
  -- caption. Also use a hack (fig:) to enforce pandoc to create a
  -- figure i.e. attach a caption to the image.
  local img_obj = pandoc.Image(caption, fname, title, img_attr)

  -- Finally, put the image inside an empty paragraph. By returning the
  -- resulting paragraph object, the source code block gets replaced by
  -- the image:
  if block.attributes.showcode then
    return {block, pandoc.Para{ img_obj}}
  else
    return pandoc.Para{ img_obj}
  end
end

-- this is the actual filter that is returned to pandoc
return {
  {Meta = Meta},
  {CodeBlock = CodeBlock},
}
