-- @description VisualMixer
-- @version 1.09
-- @author MPL
-- @website https://forum.cockos.com/showthread.php?t=188335
-- @about Pretty same as what Izotope Neutron Visual mixer do, probably with some things act different. I built ReaScript prototype slightly before Izotope thing was released, but it was also inspired by Izotope stuff.
-- @provides
--    mpl_VisualMixer_functions/mpl_VisualMixer_GUI.lua
--    mpl_VisualMixer_functions/mpl_VisualMixer_MOUSE.lua
--    mpl_VisualMixer_functions/mpl_VisualMixer_data.lua
--    mpl_VisualMixer_functions/mpl_VisualMixer_obj.lua
-- @changelog
--    # fix color issue on Windows


  local vrs = 'v1.09'
  --NOT gfx NOT reaper
  
  
  --  INIT -------------------------------------------------
  for key in pairs(reaper) do _G[key]=reaper[key]  end  
  local conf = {}  
  local refresh = { GUI_onStart = true, 
                    GUI = false, 
                    GUI_minor = false,
                    data = false,
                    data_proj = true, 
                    conf = false}
   mouse = {}
  local data = {}
  local obj = {}
  local ext_path_name = 'VisualMixer'
  ---------------------------------------------------  
  
  function Main_RefreshExternalLibs()     -- lua example by Heda -- http://github.com/ReaTeam/ReaScripts-Templates/blob/master/Files/Require%20external%20files%20for%20the%20script.lua
    local info = debug.getinfo(1,'S');
    local script_path = info.source:match([[^@?(.*[\/])[^\/]-$]]) 
    dofile(script_path .. "mpl_"..ext_path_name.."_functions/mpl_"..ext_path_name.."_GUI.lua")
    dofile(script_path .. "mpl_"..ext_path_name.."_functions/mpl_"..ext_path_name.."_MOUSE.lua")  
    dofile(script_path .. "mpl_"..ext_path_name.."_functions/mpl_"..ext_path_name.."_obj.lua")  
    dofile(script_path .. "mpl_"..ext_path_name.."_functions/mpl_"..ext_path_name.."_data.lua")  
  end  

  ---------------------------------------------------
  function ExtState_Def()  
    local t= {
            -- globals
            mb_title = ext_path_name,
            ES_key = 'MPL_'..ext_path_name,
            wind_x =  50,
            wind_y =  50,
            wind_w =  500,
            wind_h =  500,
            dock =    0,
            
            -- mouse
            mouse_wheel_res = 960,
            
            }
    return t
  end  
  
  ---------------------------------------------------    
  function run()
    obj.clock = os.clock()
    
    MOUSE(conf, obj, data, refresh, mouse)
    CheckUpdates(obj, conf, refresh)
    
    if refresh.data == true then 
      data = {}
      Data_Update (conf, obj, data, refresh, mouse) 
      Data_Update_Snapshots (conf, obj, data, refresh, mouse) 
      refresh.data = nil 
    end    
    
    if refresh.save_data_proj == true then 
      local str = Data_Snapshot_FormStr(data)
      Data_Snapshot_SaveExtState(data, data.currentsnapshotID, str) 
      refresh.save_data_proj = nil
    end
    
    if refresh.conf == true then 
      ExtState_Save(conf)
      refresh.conf = nil 
    end
    
     
    OBJ_Update(conf, obj, data, refresh, mouse) 
    
    if refresh.GUI_minor == true then refresh.GUI = true end

    Data_Update2(conf, obj, data, refresh, mouse)
    GUI_draw    (conf, obj, data, refresh, mouse)    
                                               
 
    ShortCuts(conf, obj, data, refresh, mouse)
    if mouse.char >= 0 and mouse.char ~= 27 then defer(run) else atexit(gfx.quit) end
  end
    

  
---------------------------------------------------------------------
  function CheckFunctions(str_func)
    local SEfunc_path = reaper.GetResourcePath()..'/Scripts/MPL Scripts/Functions/mpl_Various_functions.lua'
    local f = io.open(SEfunc_path, 'r')
    if f then
      f:close()
      dofile(SEfunc_path)      
      if not _G[str_func] then 
        reaper.MB('Update '..SEfunc_path:gsub('%\\', '/')..' to newer version', '', 0)
       else
        return true
      end
      
     else
      reaper.MB(SEfunc_path:gsub('%\\', '/')..' missing', '', 0)
    end  
  end

--------------------------------------------------------------------
  function main()
        conf.dev_mode = 0
        conf.vrs = vrs
        Main_RefreshExternalLibs()
        ExtState_Load(conf)  
        gfx.init('MPL '..conf.mb_title..' '..conf.vrs,
                  conf.wind_w, 
                  conf.wind_h, 
                  conf.dock, conf.wind_x, conf.wind_y)
        OBJ_init(obj)
        OBJ_Update(conf, obj, data, refresh, mouse, data_ext) 
        run()  
  end
  ---------------------------------------------------------------------
  function VF_CheckFunctions(vrs) local SEfunc_path = reaper.GetResourcePath()..'/Scripts/MPL Scripts/Functions/mpl_Various_functions.lua'  if  reaper.file_exists( SEfunc_path ) then dofile(SEfunc_path) if not VF_version or VF_version < vrs then  reaper.MB('Update '..SEfunc_path:gsub('%\\', '/')..' to version '..vrs..' or newer', '', 0) else return true end  else  reaper.MB(SEfunc_path:gsub('%\\', '/')..' not found. You should have ReaPack installed. Right click on ReaPack package and click Install, then click Apply', '', 0)  if reaper.APIExists('ReaPack_BrowsePackages') then ReaPack_BrowsePackages( 'Various functions' ) else reaper.MB('ReaPack extension not found', '', 0) end end    end
  --------------------------------------------------------------------  
  local ret = VF_CheckFunctions(2.64) if ret then local ret2 = VF_CheckReaperVrs(5.975,true) if ret2 then 
    main()
  end end
