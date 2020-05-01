-- @description Adjust normalized last touched parameter by X units (MIDI, OSC, mousewheel)
-- @version 1.01
-- @author MPL
-- @website http://forum.cockos.com/showthread.php?t=188335
-- @metapackage
-- @provides
--    [main] . > mpl_Adjust normalized last touched parameter by 0.01 units (MIDI, OSC, mousewheel).lua
--    [main] . > mpl_Adjust normalized last touched parameter by 0.001 units (MIDI, OSC, mousewheel).lua
--    [main] . > mpl_Adjust normalized last touched parameter by 0.0001 units (MIDI, OSC, mousewheel).lua
-- @changelog
--    # change name

  local is_new_value,filename,sectionID,cmdID,mode,resolution,val = reaper.get_action_context()
  
  
  function mainsub(val, dir)
    if not dir then return end
     retval, trackid, fxid, paramid = reaper.GetLastTouchedFX()
    if retval then
      local track = reaper.GetTrack(0, trackid-1)
      if trackid == 0 then track = reaper.GetMasterTrack( 0 ) end
      if track then
        local value0 = reaper.TrackFX_GetParamNormalized(track, fxid, paramid)
        local newval = math.max(0,math.min(value0 + val*dir,math.huge))
        reaper.TrackFX_SetParamNormalized(track, fxid, paramid, newval) 
      end  
    end
  end  

  function main()
    local unit = filename:match('([%d%p]+) units')
    if not unit or (unit and not tonumber(unit)) then return end
    unit = tonumber(unit)
    val = val / resolution
    if mode == 0 then
      if val > 0.5 then dir = 1 elseif val <0.5 then dir = -1 end
     elseif mode > 0 then 
      if val > 0 then dir = 1 elseif val <0 then dir = -1 end
    end
    mainsub(unit, dir) 
  end
  
  reaper.defer(main)