-- Repair table caption numbering in papaja's apa6_docx output.
--
-- Pandoc DOES auto-number table captions, emitting inlines shaped like
--     [1]=Span(empty anchor)  [2]=Str"Table"  [3]=Space  [4]=Str"N:"
--     [5]=Space               [6..]=caption inlines
--
-- papaja's docx_fixes.lua assumes there is no leading anchor Span and indexes
-- from "Table" at position 1:
--     caption[3] = strip ":" from the number
--     caption[4] = LineBreak
--     caption[5..] = Emph
--
-- Because of the off-by-one, papaja writes the LineBreak over the number
-- itself. The caption then renders as a bare "Table" with the number gone,
-- while the body text still says "see Table 1".
--
-- This filter runs before papaja's (rmarkdown places pandoc_args ahead of the
-- format's own filters) and simply removes the leading empty Span, restoring
-- the index alignment papaja expects. papaja's filter then produces the
-- intended "Table N" + line break + italic caption.
--
-- The Span is a caption anchor only; docx has no table cross-reference field
-- pointing at it, so dropping it costs nothing.

function Table (tbl)
  if tbl.caption == nil or tbl.caption.long == nil then return tbl end
  if tbl.caption.long[1] == nil then return tbl end

  local c = tbl.caption.long[1].content
  if c == nil or c[1] == nil then return tbl end

  -- Only act on a leading Span that carries no visible text.
  if c[1].t == "Span" and pandoc.utils.stringify(c[1]) == "" then
    local rebuilt = {}
    for i = 2, #c do table.insert(rebuilt, c[i]) end
    tbl.caption.long[1].content = rebuilt
  end

  return tbl
end
