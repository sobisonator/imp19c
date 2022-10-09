Includes = {
	#"cw/debug_constants.fxh"
}

ConstantBuffer( GameFogOfWar )
{
	float4 	FoWColor1;
	float4 	FoWColor2;
	float	FoWColorBlendMidpoint;
	float	FoWColorBlendWidth;
}

Code
[[
	#define FOG_OF_WAR_BLEND_FUNCTION CalcFogOfWarBlend
	float4 CalcFogOfWarBlend( float Alpha )
	{
		Alpha = saturate(Alpha);
		
		const float SCALE = min(1.0f,(1.0f-Alpha)*1.6f);
		
		return float4( FoWColor2.rgb, SCALE );
	}
]]