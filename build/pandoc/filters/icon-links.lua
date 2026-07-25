--[[
  icon-links.lua — keep each inline icon glued to the identifier it labels.

  In the author block Manubot emits "<icon> <handle>" pairs (ORCID, GitHub,
  Twitter) separated by soft line breaks, so the PDF's narrow two-column author
  layout is free to break between an icon and its handle — or, because the base
  theme sets `overflow-wrap: break-word` on links, in the middle of the handle
  itself ("pr / obablybots"). This wraps each icon/handle pair in a
  <span class="nowrap"> so a long identifier line breaks only at the "·"
  separators, moving the whole pair to the next line.

  Styling for .nowrap lives in build/themes/pdf-styles.html; only wired into the
  PDF build via build/pandoc/defaults/pdf-weasyprint.yaml.
--]]

local nbsp = "\u{00A0}"

local function is_icon(el)
  if el.t ~= "Image" then return false end
  for _, class in ipairs(el.classes) do
    if class == "inline_icon" then return true end
  end
  return false
end

function Inlines(inlines)
  local out = pandoc.Inlines({})
  local i = 1
  while i <= #inlines do
    local icon, gap, handle = inlines[i], inlines[i + 1], inlines[i + 2]
    if is_icon(icon) and gap and (gap.t == "Space" or gap.t == "SoftBreak")
        and handle and handle.t == "Link" then
      out:insert(pandoc.Span({ icon, pandoc.Str(nbsp), handle },
        pandoc.Attr("", { "nowrap" }, {})))
      i = i + 3
    else
      out:insert(icon)
      i = i + 1
    end
  end
  return out
end
