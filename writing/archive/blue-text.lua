-- blue-text.lua
--
-- Convert <span style="color: blue">…</span> markup (or its bracketed-span
-- markdown form `[text]{style="color: blue"}`) into colored runs in the docx
-- output. Pandoc's docx writer ignores the `style` attribute on spans by
-- default; this filter wraps the span contents in raw OOXML that sets the
-- character color to a chosen hex value.
--
-- The color "2271B2" is a readable bright blue. Change BLUE_HEX below to
-- recolour all flagged passages.

local BLUE_HEX = "2271B2"

local function color_open()
  return pandoc.RawInline("openxml",
    string.format(
      '<w:r><w:rPr><w:color w:val="%s"/></w:rPr><w:t xml:space="preserve">',
      BLUE_HEX))
end

local function color_close()
  return pandoc.RawInline("openxml", '</w:t></w:r>')
end

-- Escape characters that aren't legal inside a <w:t> OOXML run.
local function xml_escape(s)
  return (s:gsub("&", "&amp;")
           :gsub("<", "&lt;")
           :gsub(">", "&gt;"))
end

local function styles_blue(el)
  local style = el.attributes and el.attributes.style
  return style and style:match("color%s*:%s*blue") ~= nil
end

function Span(el)
  if not styles_blue(el) then return nil end
  -- Walk the inline content; emit each segment inside its own colored
  -- OOXML run so that w:r is never nested. Most content is plain text or
  -- citations, which after citeproc are also plain text.
  local out = {}
  for _, item in ipairs(el.content) do
    local t = pandoc.utils.stringify(item)
    if t and #t > 0 then
      table.insert(out, pandoc.RawInline("openxml",
        string.format(
          '<w:r><w:rPr><w:color w:val="%s"/></w:rPr><w:t xml:space="preserve">%s</w:t></w:r>',
          BLUE_HEX, xml_escape(t))))
    end
  end
  if #out == 0 then return {} end
  return out
end
