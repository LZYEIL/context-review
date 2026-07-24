--[[
  toc.lua — insert a printed table of contents after the author list.

  Pandoc's built-in --toc can only place the ToC at the top of the document
  (before the front matter). This filter instead builds a Contents block from
  the level-1/level-2 section headers and inserts it just before the Abstract,
  so it follows the title and author list. PDF styling (dot leaders, resolved
  page numbers, page break) lives in build/themes/toc.html and is applied by
  WeasyPrint. Only wired into the PDF build via build/pandoc/defaults/pdf-weasyprint.yaml.

  Note: this reaches into Manubot's pandoc pipeline; revisit if a Manubot
  template update changes how the front matter or headers are emitted.
--]]

local max_level = 2
-- Front-matter headers that sit above the ToC and should not list themselves.
local skip_ids = { authors = true }

-- Content sections get a number (in both the body and this ToC); front/back
-- matter (abstract, references, appendices) is listed but left unnumbered.
local function is_numbered(id)
  if id == "abstract" or id == "references" then return false end
  if id:match("^appendix") then return false end
  return true
end

function Pandoc(doc)
  local items = {}
  for _, blk in ipairs(doc.blocks) do
    if blk.t == "Header" and blk.level <= max_level and not skip_ids[blk.identifier] then
      local classes = is_numbered(blk.identifier) and { "numbered" } or {}
      local link = pandoc.Link(blk.content:clone(), "#" .. blk.identifier, "",
        pandoc.Attr("", classes, {}))
      table.insert(items, { pandoc.Plain({ link }) })
    end
  end

  if #items == 0 then
    return doc
  end

  local toc = pandoc.Div({ pandoc.BulletList(items) }, pandoc.Attr("TOC", {}, {}))

  -- Insert before the Abstract; fall back to the top if no Abstract exists.
  local insert_at = 1
  for i, blk in ipairs(doc.blocks) do
    if blk.t == "Header" and blk.identifier == "abstract" then
      insert_at = i
      break
    end
  end

  table.insert(doc.blocks, insert_at, toc)
  return doc
end
