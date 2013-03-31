import XMonad
-- LAYOUTS
import XMonad.Layout.Spacing
import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.SimplestFloat
import XMonad.Layout.ThreeColumns
import XMonad.Layout.ResizableTile
import XMonad.Layout.Circle
import XMonad.Layout.Spiral

import XMonad.Actions.GridSelect
-- WINDOW RULES
import XMonad.ManageHook
-- KEYBOARD & MOUSE CONFIG
import XMonad.Util.EZConfig
import XMonad.Actions.FloatKeys
import Graphics.X11.ExtraTypes.XF86
-- STATUS BAR
import XMonad.Hooks.DynamicLog hiding (xmobar, xmobarPP, xmobarColor, sjanssenPP, byorgeyPP)
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Hooks.UrgencyHook
import XMonad.Util.Dmenu
--import XMonad.Hooks.FadeInactive
import XMonad.Hooks.EwmhDesktops hiding (fullscreenEventHook)
import System.IO (hPutStrLn)
--import XMonad.Operations
import XMonad.Util.Run (spawnPipe)
import XMonad.Actions.CycleWS           -- nextWS, prevWS
import Data.List                        -- clickable workspaces



defaultLayouts =          onWorkspace (myWorkspaces !! 0) (avoidStruts (Circle ||| tiled) ||| fullTile)
                        $ onWorkspace (myWorkspaces !! 1) (avoidStruts (Circle ||| noBorders (fullTile)) ||| fullScreen)
                        $ onWorkspace (myWorkspaces !! 2) (avoidStruts simplestFloat)
                        $ avoidStruts ( tiledSpace  ||| tiled ||| fullTile ) ||| fullScreen
        where
                tiled           = spacing 5 $ ResizableTall nmaster delta ratio []
                tiledSpace      = spacing 60 $ ResizableTall nmaster delta ratio []
                tile3           = spacing 5 $ ThreeColMid nmaster delta ratio
                fullScreen      = noBorders(fullscreenFull Full)
                fullTile        = ResizableTall nmaster delta ratio []
                fullTile3       =  ThreeColMid nmaster delta ratio
                borderlessTile  = noBorders(fullTile)
                fullGoldenSpiral        = spiral ratio
                goldenSpiral    = spacing 5 $ spiral ratio
                -- Default number of windows in master pane
                nmaster = 1
                -- Percent of the screen to increment when resizing
                delta   = 5/100
                -- Default proportion of the screen taken up by main pane
                ratio   = toRational (2/(1 + sqrt 5 :: Double))

-- Give some workspaces no borders
nobordersLayout = noBorders $ Full
myLayout = defaultLayouts

-- Declare workspaces and rules for applications

myWorkspaces = clickable $ ["^i(/home/genesis/.xmonad/icons/shell.xbm) 1"
                ,"^i(/home/genesis/.xmonad/icons/globe.xbm) 2"
                ,"^i(/home/genesis/.xmonad/icons/calc.xbm) 3"
                ,"^i(/home/genesis/.xmonad/icons/doc.xbm) 4"
                ,"^i(/home/genesis/.xmonad/icons/text.xbm) 5"
                ,"^i(/home/genesis/.xmonad/icons/movie.xbm) 6"
                ,"^i(/home/genesis/.xmonad/icons/mail.xbm) 7"
                ,"^i(/home/genesis/.xmonad/icons/monitor.xbm) 8"
                ,"^i(/home/genesis/.xmonad/icons/picture.xbm) 9"]

        where clickable l     = [ "^ca(1,xdotool key alt+" ++ show (n) ++ ")" ++ ws ++ "^ca()" |
                            (i,ws) <- zip [1..] l,
                            let n = i ]

myManageHook = composeAll       [ resource =? "dmenu"    --> doFloat
                                , resource =? "skype"    --> doFloat
                                , resource =? "mplayer"  --> doFloat
                                , resource =? "feh"      --> doFloat
                                , resource =? "chromium" --> doShift (myWorkspaces !! 1)
                                , resource =? "ario"     --> doShift (myWorkspaces !! 4)
                                , resource =? "lowriter" --> doShift (myWorkspaces !! 3)
                                , resource =? "zathura"  --> doShift (myWorkspaces !! 3)
                                , resource =? "localc"   --> doShift (myWorkspaces !! 3)
                                , resource =? "loimpress"--> doShift (myWorkspaces !! 3)
                                ]
newManageHook = myManageHook <+> manageHook defaultConfig <+> manageDocks

myLogHook h = dynamicLogWithPP ( defaultPP
        {
--                ppCurrent             = dzenColor white0 background . wrap "^fg(#916949).: ^fg()" "^fg(#916949) :.^fg()" . pad
                  ppCurrent             = dzenColor foreground background . pad
                , ppVisible             = dzenColor white0 background . pad
                , ppHidden              = dzenColor white0 background . pad
                , ppHiddenNoWindows     = dzenColor black0 background . pad
                , ppWsSep               = ""
                , ppSep                 = "    "
                , ppLayout              = wrap "^ca(1,xdotool key alt+space)" "^ca()" . dzenColor white1 background .
                                (\x -> case x of
                                        "Full"                           ->      "^i(/home/genesis/.xmonad/icons/monitor.xbm)"
                                        "Spacing 5 ResizableTall"        ->      "^i(/home/genesis/.xmonad/icons/layout.xbm)"
                                        "ResizableTall"                  ->      "^i(/home/genesis/.xmonad/icons/layout_tall.xbm)"
                                        "SimplestFloat"                  ->      "^i(/home/genesis/.xmonad/icons/layers.xbm)"
                                        "Circle"                         ->      "^i(/home/genesis/.xmonad/icons/circle.xbm)"
                                        _                                ->      "^i(/home/genesis/.xmonad/icons/grid3x3.xbm)"
                                )
--              , ppTitle       =   wrap "^ca(1,xdotool key alt+shift+x)^fg(#424242)^i(/home/genesis/.xmonad/dzen2/corner_left.xbm)^bg(#424242)^fg(#74637d)X" "^fg(#424242)^i(/home/genesis/.xmonad/dzen2/corner_right.xbm)^ca()" .  dzenColor background green0 . shorten 40 . pad		
                , ppOrder       =  \(ws:l:t:_) -> [ws,l]
                , ppOutput      =   hPutStrLn h
        } )

myXmonadBar = "dzen2 -x '1920' -y '0' -h '25' -w '700' -ta 'l' -fg '"++foreground++"' -bg '"++background++"' -fn "++myFont
myStatusBar = "conky -qc /home/genesis/.xmonad/.conky_dzen | dzen2 -x '2620' -w '1220' -h '25' -ta 'r' -bg '"++background++"' -fg '"++foreground++"' -y '0' -fn "++myFont
--myConky = "conky -c /home/genesis/conkyrc"
--myStartMenu = "/home/genesis/.xmonad/start /home/genesis/.xmonad/start_apps"

main = do
        dzenLeftBar     <- spawnPipe myXmonadBar
        dzenRightBar    <- spawnPipe myStatusBar
--      xmproc          <- spawnPipe "/usr/bin/docky"
        xmproc          <- spawnPipe "GTK2_RC_FILES=/home/genesis/.gtkdocky /usr/bin/docky"
--      conky           <- spawn myConky
--      dzenStartMenu   <- spawnPipe myStartMenu
        xmonad $ ewmh defaultConfig
                { terminal              = myTerminal
                , borderWidth           = 1
                , normalBorderColor     = black0
                , focusedBorderColor    = magenta0
                , modMask               = mod4Mask
                , layoutHook            = smartBorders(myLayout)
--              , layoutHook            = avoidStruts  $  layoutHook defaultConfig
                , workspaces            = myWorkspaces
                , manageHook            = newManageHook
--              , manageHook            = manageDocks <+> manageHook defaultConfig
                , handleEventHook       = fullscreenEventHook <+> docksEventHook
                , startupHook           = setWMName "LG3D"
                , logHook               = myLogHook dzenLeftBar -- >> fadeInactiveLogHook 0xdddddddd
                }
                `additionalKeys`
                [((mod4Mask .|. shiftMask       , xK_b), spawn "chromium")
                ,((mod4Mask                     , xK_b), spawn "dwb")
                ,((mod4Mask .|. shiftMask       , xK_n), spawn "urxvt -fn '-*-terminus-medium-r-normal-*-12-*-*-*-*-*-*-*' -fb '-*-terminus-bold-r-normal-*-12-*-*-*-*-*-*-*' -fi '-*-terminus-medium-r-normal-*-12-*-*-*-*-*-*-*'")
                ,((mod4Mask .|. shiftMask       , xK_t), spawn "urxvt -e tmux")
--              ,((mod4Mask                     , xK_z), spawn "zathura")
--              ,((mod4Mask                     , xK_r), spawn "/home/genesis/.scripts/lens")
--              ,((mod4Mask .|. shiftMask       , xK_r), spawn "dmenu_run -nb '#000000' -nf '#404040' -sb '#000000' -sf '#FFFFFF' -fn '-*-lime-*-*-*-*-*-*-*-*-*-*-*-*'")
                ,((mod4Mask .|. shiftMask       , xK_r), spawn "dmenu_run")
--                ,((mod4Mask .|. shiftMask       , xK_r), spawn "/home/genesis/.scripts/dmenu/spotlight")
                ,((mod4Mask                     , xK_q), spawn "killall dzen2; killall conky; cd ~/.xmonad; ghc -threaded xmonad.hs; mv xmonad xmonad-x86_64-linux; xmonad --restart" )
                ,((mod4Mask .|. shiftMask       , xK_i), spawn "xcalib -invert -alter")
                ,((mod4Mask .|. shiftMask       , xK_x), kill)
                ,((mod4Mask .|. shiftMask       , xK_c), return())
                ,((mod4Mask                     , xK_p), moveTo Prev NonEmptyWS)
                ,((mod4Mask                     , xK_n), moveTo Next NonEmptyWS)
                ,((mod4Mask                     , xK_c), moveTo Next EmptyWS)
                ,((mod4Mask .|. shiftMask       , xK_l), sendMessage MirrorShrink)
                ,((mod4Mask .|. shiftMask       , xK_h), sendMessage MirrorExpand)
--              ,((mod4Mask .|. shiftMask       , xK_q), sendMessage MirrorExpand)
--                ,((mod4Mask                     , xK_v), screenWorkspace sc >>= flip whenJust (windows . f))
                ,((mod4Mask                     , xK_a), withFocused (keysMoveWindow (-20,0)))
                ,((mod4Mask                     , xK_comma), withFocused (keysMoveWindow (0,-20)))
                ,((mod4Mask                     , xK_o), withFocused (keysMoveWindow (0,20)))
                ,((mod4Mask                     , xK_e), withFocused (keysMoveWindow (20,0)))
                ,((mod4Mask .|. shiftMask       , xK_a), withFocused (keysResizeWindow (-20,0) (0,0)))
                ,((mod4Mask .|. shiftMask       , xK_comma), withFocused (keysResizeWindow (0,-20) (0,0)))
                ,((mod4Mask .|. shiftMask       , xK_o), withFocused (keysResizeWindow (0,20) (0,0)))
                ,((mod4Mask .|. shiftMask       , xK_e), withFocused (keysResizeWindow (20,0) (0,0)))
--              ,((0                            , xK_Super_L), spawn "menu ~/.xmonad/apps")
--              ,((mod4Mask                     , xK_Super_L), spawn "menu ~/.xmonad/configs")
                ,((mod4Mask                     , xK_F1), spawn "~/.xmonad/sc ~/.scripts/dzen_music.sh")
                ,((mod4Mask                     , xK_F2), spawn "~/.xmonad/sc ~/.scripts/dzen_vol.sh")
                ,((mod4Mask                     , xK_F3), spawn "~/.xmonad/sc ~/.scripts/dzen_network.sh")
                ,((mod4Mask                     , xK_F4), spawn "~/.xmonad/sc ~/.scripts/dzen_battery.sh")
                ,((mod4Mask                     , xK_F5), spawn "~/.xmonad/sc ~/.scripts/dzen_hardware.sh")
                ,((mod4Mask                     , xK_F6), spawn "~/.xmonad/sc ~/.scripts/dzen_pacman.sh")
                ,((mod4Mask                     , xK_F7), spawn "~/.xmonad/sc ~/.scripts/dzen_date.sh")
                ,((mod4Mask                     , xK_F8), spawn "~/.xmonad/sc ~/.scripts/dzen_log.sh")
                ,((0                            , xK_Print), spawn "scrot & mplayer /usr/share/sounds/freedesktop/stereo/screen-capture.oga")
                ,((mod4Mask                     , xK_Print), spawn "scrot -s & mplayer /usr/share/sounds/freedesktop/stereo/screen-capture.oga")
                ,((0                            , xF86XK_AudioLowerVolume), spawn "amixer set Master 2- & mplayer /usr/share/sounds/freedesktop/stereo/audio-volume-change.oga")
                ,((0                            , xF86XK_AudioRaiseVolume), spawn "amixer set Master 2+ & mplayer /usr/share/sounds/freedesktop/stereo/audio-volume-change.oga")
                ,((0                            , xF86XK_AudioMute), spawn "amixer set Master toggle")
--              ,((0                            , xF86XK_Display), spawn "xrandr --output VGA1 --mode 1366x768")
                ,((0                            , xF86XK_Sleep), spawn "sudo suspend")
                ,((0                            , xF86XK_AudioPlay), spawn "ncmpcpp toggle")
                ,((0                            , xF86XK_AudioNext), spawn "ncmpcpp next")
                ,((0                            , xF86XK_AudioPrev), spawn "ncmpcpp prev")
                ]
                `additionalMouseBindings`
                [((mod4Mask                     , 6), (\_ -> moveTo Next NonEmptyWS))
                ,((mod4Mask                     , 7), (\_ -> moveTo Prev NonEmptyWS))
                ,((mod4Mask                     , 5), (\_ -> moveTo Prev NonEmptyWS))
                ,((mod4Mask                     , 4), (\_ -> moveTo Next NonEmptyWS))
                ]

myTerminal      = "urxvt"
myBitmapsDir    = "~/.xmonad/dzen2/"
myFont          = "xft:PragmataPro:style=Regular:pixelsize=14"
--myFont                = "-*-tamsyn-medium-*-normal-*-10-*-*-*-*-*-*-*"
--myFont                = "-*-terminus-medium-*-normal-*-9-*-*-*-*-*-*-*"
--myFont                = "-*-lime-*-*-*-*-*-*-*-*-*-*-*-*"
--myFont                = "-*-drift-*-*-*-*-*-*-*-*-*-*-*-*"
--myFont                = "xft:inconsolata:size=10"
--myFont                = "xft:droid sans mono:size=9"
--myFont                = "-*-cure-*-*-*-*-*-*-*-*-*-*-*-*"

background= "#000000"
foreground= "#ffffff"

black0= "#343638"
black1= "#404040"

red0=  "#2f468e"
red1=  "#7791e0"

green0= "#424242"
green1= "#828a8c"

yellow0=  "#6b8ba3"
yellow1= "#8ebdde"

blue0=  "#1c4582"
blue1= "#5365a6"

magenta0=  "#74636d"
magenta1= "#927d9e"

cyan0=  "#556c85"
cyan1= "#6e98b8"

white0=  "#b2b2b2"
white1= "#bdbdbd"
