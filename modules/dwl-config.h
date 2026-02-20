/* Taken from https://github.com/djpohly/dwl/issues/466 */
#define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \
                        ((hex >> 16) & 0xFF) / 255.0f, \
                        ((hex >> 8) & 0xFF) / 255.0f, \
                        (hex & 0xFF) / 255.0f }
/* appearance */
static const int sloppyfocus               = 1;  /* focus follows mouse */
static const int bypass_surface_visibility = 0;  /* 1 means idle inhibitors will disable idle tracking even if it's surface isn't visible  */
static const unsigned int borderpx         = 2;  /* border pixel of windows */
static const float rootcolor[]             = COLOR(0x1e1e2eff);
static const float bordercolor[]           = COLOR(0x313244ff);
static const float focuscolor[]            = COLOR(0x89b4faff);
static const float urgentcolor[]           = COLOR(0xf38ba8ff);
/* This conforms to the xdg-protocol. Set the alpha to zero to restore the old behavior */
static const float fullscreen_bg[]         = {0.1f, 0.1f, 0.1f, 1.0f}; /* You can also use glsl colors */

/* tagging - TAGCOUNT must be no greater than 31 */
#define TAGCOUNT (9)

/* logging */
static int log_level = WLR_ERROR;

/* NOTE: ALWAYS keep a rule declared even if you don't use rules (e.g leave at least one example) */
static const Rule rules[] = {
	/* app_id             title       tags mask     isfloating   monitor */
	/* examples: */
	{ "Gimp_EXAMPLE",     NULL,       0,            1,           -1 }, /* Start on currently visible tags floating, not tiled */
	{ "firefox_EXAMPLE",  NULL,       1 << 8,       0,           -1 }, /* Start on ONLY tag "9" */
};

/* layout(s) */
static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },
	{ "><>",      NULL },    /* no layout function means floating behavior */
	{ "[M]",      monocle },
};

/* monitors */
/* (x=-1, y=-1) is reserved as an "autoconfigure" monitor position indicator
 * WARNING: negative values other than (-1, -1) cause problems with Xwayland clients
 * https://gitlab.freedesktop.org/xorg/xserver/-/issues/899
*/
/* NOTE: ALWAYS add a fallback rule, even if you are completely sure it won't be used */
static const MonitorRule monrules[] = {
	/* name       mfact  nmaster scale layout       rotate/reflect                x    y */
	/* example of a HiDPI laptop monitor:
	{ "eDP-1",    0.5f,  1,      2,    &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL,   -1,  -1 },
	*/
	/* defaults — scale set to 2 for HiDPI */
	{ NULL,       0.55f, 1,      2,    &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL,   -1,  -1 },
};

/* keyboard */
static const struct xkb_rule_names xkb_rules = {
	/* can specify fields: rules, model, layout, variant, options */
	/* example:
	.options = "ctrl:nocaps",
	*/
	.options = NULL,
};

static const int repeat_rate = 50;
static const int repeat_delay = 300;

/* Trackpad */
static const int tap_to_click = 1;
static const int tap_and_drag = 1;
static const int drag_lock = 1;
static const int natural_scrolling = 0;
static const int disable_while_typing = 1;
static const int left_handed = 0;
static const int middle_button_emulation = 0;
/* You can choose between:
LIBINPUT_CONFIG_SCROLL_NO_SCROLL
LIBINPUT_CONFIG_SCROLL_2FG
LIBINPUT_CONFIG_SCROLL_EDGE
LIBINPUT_CONFIG_SCROLL_ON_BUTTON_DOWN
*/
static const enum libinput_config_scroll_method scroll_method = LIBINPUT_CONFIG_SCROLL_2FG;

/* You can choose between:
LIBINPUT_CONFIG_CLICK_METHOD_NONE
LIBINPUT_CONFIG_CLICK_METHOD_BUTTON_AREAS
LIBINPUT_CONFIG_CLICK_METHOD_CLICKFINGER
*/
static const enum libinput_config_click_method click_method = LIBINPUT_CONFIG_CLICK_METHOD_BUTTON_AREAS;

/* You can choose between:
LIBINPUT_CONFIG_SEND_EVENTS_ENABLED
LIBINPUT_CONFIG_SEND_EVENTS_DISABLED
LIBINPUT_CONFIG_SEND_EVENTS_DISABLED_ON_EXTERNAL_MOUSE
*/
static const uint32_t send_events_mode = LIBINPUT_CONFIG_SEND_EVENTS_ENABLED;

/* You can choose between:
LIBINPUT_CONFIG_ACCEL_PROFILE_FLAT
LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE
*/
static const enum libinput_config_accel_profile accel_profile = LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE;
static const double accel_speed = 0.0;

/* You can choose between:
LIBINPUT_CONFIG_TAP_MAP_LRM -- 1/2/3 finger tap maps to left/right/middle
LIBINPUT_CONFIG_TAP_MAP_LMR -- 1/2/3 finger tap maps to left/middle/right
*/
static const enum libinput_config_tap_button_map button_map = LIBINPUT_CONFIG_TAP_MAP_LRM;

/* i3wm uses Super (Logo) key as modifier */
#define MODKEY WLR_MODIFIER_LOGO

#define TAGKEYS(KEY,SKEY,TAG) \
	{ MODKEY,                    KEY,            view,            {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_CTRL,  KEY,            toggleview,      {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_SHIFT, SKEY,           tag,             {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_CTRL|WLR_MODIFIER_SHIFT,SKEY,toggletag, {.ui = 1 << TAG} }

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static const char *termcmd[] = { "kitty", NULL };
static const char *menucmd[] = { "wmenu-run", NULL };

static const Key keys[] = {
	/* Note that Shift changes certain key codes: c -> C, 2 -> at, etc. */
	/* ── i3wm-style keybindings ─────────────────────────────────── */

	/* $mod+Return = open terminal */
	{ MODKEY,                    XKB_KEY_Return,     spawn,          {.v = termcmd} },
	/* $mod+d = app launcher (dmenu_run equivalent) */
	{ MODKEY,                    XKB_KEY_d,          spawn,          {.v = menucmd} },
	/* $mod+Shift+q = kill focused window */
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Q,          killclient,     {0} },

	/* ── Focus navigation ($mod+j/k/arrows) ─────────────────────── */
	{ MODKEY,                    XKB_KEY_j,          focusstack,     {.i = +1} },
	{ MODKEY,                    XKB_KEY_k,          focusstack,     {.i = -1} },
	{ MODKEY,                    XKB_KEY_Down,       focusstack,     {.i = +1} },
	{ MODKEY,                    XKB_KEY_Up,         focusstack,     {.i = -1} },

	/* ── Resize master area ($mod+h/l/arrows) ────────────────────── */
	{ MODKEY,                    XKB_KEY_h,          setmfact,       {.f = -0.05f} },
	{ MODKEY,                    XKB_KEY_l,          setmfact,       {.f = +0.05f} },
	{ MODKEY,                    XKB_KEY_Left,       setmfact,       {.f = -0.05f} },
	{ MODKEY,                    XKB_KEY_Right,      setmfact,       {.f = +0.05f} },

	/* ── Move window in stack ($mod+Shift+j/k) ──────────────────── */
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_J,          movestack,      {.i = +1} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_K,          movestack,      {.i = -1} },

	/* ── Promote to master ($mod+Shift+Return) ──────────────────── */
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Return,     zoom,           {0} },

	/* ── Layouts (i3 equivalents) ────────────────────────────────── */
	/* $mod+e = tiled (i3: toggle split) */
	{ MODKEY,                    XKB_KEY_e,          setlayout,      {.v = &layouts[0]} },
	/* $mod+s = monocle (i3: stacking) */
	{ MODKEY,                    XKB_KEY_s,          setlayout,      {.v = &layouts[2]} },
	/* $mod+w = floating layout (i3: tabbed) */
	{ MODKEY,                    XKB_KEY_w,          setlayout,      {.v = &layouts[1]} },

	/* $mod+f = toggle fullscreen */
	{ MODKEY,                    XKB_KEY_f,          togglefullscreen, {0} },
	/* $mod+Shift+Space = toggle floating */
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_space,      togglefloating, {0} },
	/* $mod+Space = cycle layouts */
	{ MODKEY,                    XKB_KEY_space,      setlayout,      {0} },

	/* ── Master count ────────────────────────────────────────────── */
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_plus,       incnmaster,     {.i = +1} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_underscore, incnmaster,     {.i = -1} },

	/* ── Workspace back-and-forth ($mod+Tab) ─────────────────────── */
	{ MODKEY,                    XKB_KEY_Tab,        view,           {0} },

	/* ── View all tags ($mod+0) ──────────────────────────────────── */
	{ MODKEY,                    XKB_KEY_0,          view,           {.ui = ~0} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_parenright, tag,            {.ui = ~0} },

	/* ── Multi-monitor ───────────────────────────────────────────── */
	{ MODKEY,                    XKB_KEY_comma,      focusmon,       {.i = WLR_DIRECTION_LEFT} },
	{ MODKEY,                    XKB_KEY_period,     focusmon,       {.i = WLR_DIRECTION_RIGHT} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_less,       tagmon,         {.i = WLR_DIRECTION_LEFT} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_greater,    tagmon,         {.i = WLR_DIRECTION_RIGHT} },

	/* ── Workspaces 1-9 ($mod+N / $mod+Shift+N) ─────────────────── */
	TAGKEYS(          XKB_KEY_1, XKB_KEY_exclam,                     0),
	TAGKEYS(          XKB_KEY_2, XKB_KEY_at,                         1),
	TAGKEYS(          XKB_KEY_3, XKB_KEY_numbersign,                 2),
	TAGKEYS(          XKB_KEY_4, XKB_KEY_dollar,                     3),
	TAGKEYS(          XKB_KEY_5, XKB_KEY_percent,                    4),
	TAGKEYS(          XKB_KEY_6, XKB_KEY_asciicircum,                5),
	TAGKEYS(          XKB_KEY_7, XKB_KEY_ampersand,                  6),
	TAGKEYS(          XKB_KEY_8, XKB_KEY_asterisk,                   7),
	TAGKEYS(          XKB_KEY_9, XKB_KEY_parenleft,                  8),

	/* ── Exit ($mod+Shift+e, i3 style) ───────────────────────────── */
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_E,          quit,           {0} },

	/* ── Volume keys ─────────────────────────────────────────────── */
	{ 0, XKB_KEY_XF86AudioRaiseVolume,  spawn, SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+") },
	{ 0, XKB_KEY_XF86AudioLowerVolume,  spawn, SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-") },
	{ 0, XKB_KEY_XF86AudioMute,         spawn, SHCMD("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle") },

	/* ── Brightness keys ─────────────────────────────────────────── */
	{ 0, XKB_KEY_XF86MonBrightnessUp,   spawn, SHCMD("brightnessctl set +5%") },
	{ 0, XKB_KEY_XF86MonBrightnessDown, spawn, SHCMD("brightnessctl set 5%-") },

	/* ── Media keys ──────────────────────────────────────────────── */
	{ 0, XKB_KEY_XF86AudioPlay,         spawn, SHCMD("playerctl play-pause") },
	{ 0, XKB_KEY_XF86AudioNext,         spawn, SHCMD("playerctl next") },
	{ 0, XKB_KEY_XF86AudioPrev,         spawn, SHCMD("playerctl previous") },

	/* ── Screenshots ─────────────────────────────────────────────── */
	/* Print = full screenshot to clipboard */
	{ 0,                         XKB_KEY_Print,      spawn, SHCMD("grim - | wl-copy") },
	/* $mod+Shift+S = region screenshot + edit */
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_S,          spawn, SHCMD("grim -g \"$(slurp)\" - | swappy -f -") },

	/* ── Lock screen ($mod+x) ────────────────────────────────────── */
	{ MODKEY,                    XKB_KEY_x,          spawn, SHCMD("swaylock -f") },

	/* ── Clipboard picker ($mod+v) ───────────────────────────────── */
	{ MODKEY,                    XKB_KEY_v,          spawn, SHCMD("cliphist list | wmenu -l 10 | cliphist decode | wl-copy") },

	/* ── File manager ($mod+n) ───────────────────────────────────── */
	{ MODKEY,                    XKB_KEY_n,          spawn, SHCMD("thunar") },

	/* Ctrl-Alt-Backspace and Ctrl-Alt-Fx used to be handled by X server */
	{ WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_Terminate_Server, quit, {0} },
	/* Ctrl-Alt-Fx is used to switch to another VT, if you don't know what a VT is
	 * do not remove them.
	 */
#define CHVT(n) { WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_XF86Switch_VT_##n, chvt, {.ui = (n)} }
	CHVT(1), CHVT(2), CHVT(3), CHVT(4), CHVT(5), CHVT(6),
	CHVT(7), CHVT(8), CHVT(9), CHVT(10), CHVT(11), CHVT(12),
};

static const Button buttons[] = {
	{ MODKEY, BTN_LEFT,   moveresize,     {.ui = CurMove} },
	{ MODKEY, BTN_MIDDLE, togglefloating, {0} },
	{ MODKEY, BTN_RIGHT,  moveresize,     {.ui = CurResize} },
};
