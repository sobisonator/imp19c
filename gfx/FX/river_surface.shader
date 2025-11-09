Includes = {
	"jomini/jomini_river_surface.fxh"
	"standardfuncsgfx.fxh"
	"fog_of_war.fxh"
}

PixelShader =
{	
	TextureSampler FogOfWarAlpha
	{
		Ref = JominiFogOfWar
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	
	MainCode PS_surface
	{
		Input = "VS_OUTPUT"
		Output = "PDX_COLOR"
		Code
		[[				
			PDX_MAIN
			{		
				float4 Color = CalcRiverSurface( Input );
				
				Color.rgb = ApplyFogOfWar( Color.rgb, Input.WorldSpacePos, FogOfWarAlpha );

				float vFogFactor = min(CalculateDistanceFogFactor( Input.WorldSpacePos ),0.6);
				Color.rgb = ApplyDistanceFog( Color.rgb, vFogFactor );
				
				Color.a *= 1.0f - FlatMapLerp;
				return Color;
			}
		]]
	}
}

# MOD
#// Avoid rendering rivers under terrain
RasterizerState RasterizerState
{
	DepthBias = -2000
	SlopeScaleDepthBias = -10
}
# END MOD


Effect river_surface
{
	VertexShader = "VertexShader"
	PixelShader = "PS_surface"
	Defines = { "RIVER" }
}