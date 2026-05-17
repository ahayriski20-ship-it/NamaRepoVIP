-- Esp Rainbow (Center-Top) by AndhikaYT
script_name("Esp Rainbow")
script_author("AndhikaYT")
script_version("1.3")
script_description("Esp Rainbow by AndhikaYT")

local ffi = require('ffi')
local gta = ffi.load('GTASA')

ffi.cdef[[
typedef struct RwV3d {
  float x, y, z;
} RwV3d;
void _ZN4CPed15GetBonePositionER5RwV3djb(void* thiz, RwV3d* posn, uint32_t bone, bool calledFromCam);
]]

function getBonePosition(ped, bone)
  local pedptr = ffi.cast("void*", getCharPointer(ped))
  local pos = ffi.new("RwV3d[1]")
  gta._ZN4CPed15GetBonePositionER5RwV3djb(pedptr, pos, bone, false)
  return pos[0].x, pos[0].y, pos[0].z
end

local bones = { 3, 4, 5, 51, 52, 41, 42, 31, 32, 33, 21, 22, 23, 2 }
local font = renderCreateFont("Arial", 12, 5)

function getRainbowColor(speed)
  local t = os.clock() * speed
  local r = math.floor(math.sin(t) * 127 + 128)
  local g = math.floor(math.sin(t + 2) * 127 + 128)
  local b = math.floor(math.sin(t + 4) * 127 + 128)
  return bit.bor(0xFF000000, bit.lshift(r, 16), bit.lshift(g, 8), b)
end

function main()
  while not isSampAvailable() do wait(0) end
  while true do
    wait(0)
    for _, ped in ipairs(getAllChars()) do
      local found, id = sampGetPlayerIdByCharHandle(ped)
      if found and isCharOnScreen(ped) then
        -- Tracer dari tengah atas screen
        local resX, resY = getScreenResolution()
        local x, y, z = getBonePosition(ped, 5)
        local r, px, py = convert3DCoordsToScreenEx(x, y, z)
        if r then
          renderDrawLine(resX / 2, 0, px, py, 2, getRainbowColor(10)) -- laju tukar warna
        end

        -- Body ESP
        for _, bone in ipairs(bones) do
          local x1, y1, z1 = getBonePosition(ped, bone)
          local x2, y2, z2 = getBonePosition(ped, bone + 1)
          local r1, sx1, sy1 = convert3DCoordsToScreenEx(x1, y1, z1)
          local r2, sx2, sy2 = convert3DCoordsToScreenEx(x2, y2, z2)
          if r1 and r2 then
            renderDrawLine(sx1, sy1, sx2, sy2, 1, 0xFF00FF00)
          end
        end

        -- Nametag
        local hx, hy, hz = getBonePosition(ped, 5)
        local r, x, y = convert3DCoordsToScreenEx(hx, hy, hz + 0.25)
        if r then
          local name = sampGetPlayerNickname(id)
          local hp = string.format("%.0f", sampGetPlayerHealth(id))
          local ap = string.format("%.0f", sampGetPlayerArmor(id))
          local text = name.." ["..id.."] - "..hp.."hp "..ap.."ap"
          renderFontDrawText(font, text, x - renderGetFontDrawTextLength(font, text)/2, y - 10, 0xFFFFFFFF)
        end
      end
    end
  end
end