global function MantleAnimation_ClientInit

bool am_started = false
float am_lastTriggerTime = 0.0
float am_recentFastTime = 0.0
float am_recentSpeed = 0.0
float am_maxRecentSpeed = 0.0

const float AM_COOLDOWN = 0.55
const float AM_SPEED_THRESHOLD = 300.0
const float AM_FAST_WINDOW = 0.30

void function MantleAnimation_ClientInit()
{
	if ( am_started )
		return

	am_started = true

	AddCreateCallback( "first_person_proxy", AccidentalMantle_SetupProxy )
	AddCreateCallback( "predicted_first_person_proxy", AccidentalMantle_SetupProxy )

	thread AccidentalMantle_Think()

	printl( "[AccidentalMantle] init" )
}

void function AccidentalMantle_SetupProxy( entity proxy )
{
	AddAnimEvent( proxy, "mantle_smallmantle", AccidentalMantle_OnMantle )
	AddAnimEvent( proxy, "mantle_mediummantle", AccidentalMantle_OnMantle )
	AddAnimEvent( proxy, "mantle_lowmantle", AccidentalMantle_OnMantle )
	AddAnimEvent( proxy, "mantle_extralowmantle", AccidentalMantle_OnMantle )

	printl( "[AccidentalMantle] hooked all mantle anim events" )
}

void function AccidentalMantle_Think()
{
	while ( true )
	{
		entity player = GetLocalViewPlayer()

		if ( player != null && IsValid( player ) )
		{
			vector vel = player.GetVelocity()
			float speed = sqrt( vel.x * vel.x + vel.y * vel.y )

			am_recentSpeed = speed

			if ( speed > am_maxRecentSpeed )
				am_maxRecentSpeed = speed

			if ( speed >= AM_SPEED_THRESHOLD )
				am_recentFastTime = Time()

			if ( Time() - am_recentFastTime > AM_FAST_WINDOW )
				am_maxRecentSpeed = 0.0
		}

		WaitFrame()
	}
}

void function AccidentalMantle_OnMantle( entity proxy )
{
	if ( Time() - am_lastTriggerTime < AM_COOLDOWN )
		return

	// Accidental only: recently fast, or had high recent approach speed.
	if ( Time() - am_recentFastTime > AM_FAST_WINDOW && am_maxRecentSpeed < AM_SPEED_THRESHOLD )
		return

	am_lastTriggerTime = Time()

	entity player = GetLocalViewPlayer()
	if ( player == null || !IsValid( player ) )
		return

	// Borrowed from SillyCatKills pattern: issue playvideo via player.ClientCommand.
	player.ClientCommand( "stopvideos" )
	player.ClientCommand( "playvideo mantle_animation 1 1" )

	thread AccidentalMantle_ShowPopup()
}

void function AccidentalMantle_ShowPopup()
{
	var glowRui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, 0 )
	var shadowRui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, 0 )
	var mainRui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, 0 )

	foreach ( rui in [ glowRui, shadowRui, mainRui ] )
	{
		RuiSetInt( rui, "maxLines", 1 )
		RuiSetInt( rui, "lineNum", 1 )
		RuiSetFloat( rui, "thicken", 0.35 )
		RuiSetString( rui, "msgText", "MANTLE ANIMATION" )
	}

	// tuned for this top-left template to look visually centered
	RuiSetFloat2( glowRui, "msgPos", <0.282, 0.432, 0> )
	RuiSetFloat2( shadowRui, "msgPos", <0.287, 0.439, 0> )
	RuiSetFloat2( mainRui, "msgPos", <0.283, 0.435, 0> )

	RuiSetFloat3( glowRui, "msgColor", <1.0, 0.76, 0.18> )
	RuiSetFloat3( shadowRui, "msgColor", <0.0, 0.0, 0.0> )
	RuiSetFloat3( mainRui, "msgColor", <1.0, 0.98, 0.92> )

	float start = Time()
	float total = 1.05

	while ( Time() < start + total )
	{
		float elapsed = Time() - start
		float alpha = 1.0
		float size = 112.0

		if ( elapsed < 0.10 )
		{
			float f = elapsed / 0.10
			alpha = f
			size = 52.0 + ( 82.0 * f )
		}
		else if ( elapsed < 0.22 )
		{
			float f = ( elapsed - 0.10 ) / 0.12
			alpha = 1.0
			size = 134.0 - ( 14.0 * f )
		}
		else if ( elapsed < 0.68 )
		{
			alpha = 1.0
			size = 120.0
		}
		else
		{
			float f = ( elapsed - 0.68 ) / 0.37
			alpha = 1.0 - f
			if ( alpha < 0.0 )
				alpha = 0.0
			size = 120.0
		}

		RuiSetFloat( glowRui, "msgFontSize", size + 4.0 )
		RuiSetFloat( shadowRui, "msgFontSize", size )
		RuiSetFloat( mainRui, "msgFontSize", size )

		RuiSetFloat( glowRui, "msgAlpha", alpha * 0.28 )
		RuiSetFloat( shadowRui, "msgAlpha", alpha * 0.88 )
		RuiSetFloat( mainRui, "msgAlpha", alpha )

		WaitFrame()
	}

	RuiDestroy( glowRui )
	RuiDestroy( shadowRui )
	RuiDestroy( mainRui )
}
