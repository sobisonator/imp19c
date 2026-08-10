Includes = {
	"cw/shadow.fxh"
	"cw/utility.fxh"
	"cw/camera.fxh"
	"jomini/jomini_lighting.fxh"
	"jomini/jomini_water.fxh"
	"jomini/jomini_river_bottom.fxh"
	#"constants.fxh"
	"standardfuncsgfx.fxh"
}

ConstantBuffer( JominiFogOfWar )
{
	float2	InverseWorldSize;
}
ConstantBuffer( PdxTerrainConstants )
{
	float2		WorldSpaceToTerrain0To1;
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

	MainCode PS_underwater
	{
		Input = "VS_OUTPUT"
		Output = "PS_RIVER_BOTTOM_OUT"
		Code
		[[	
			
			
			PDX_MAIN
			{				
				PS_RIVER_BOTTOM_OUT Out = CalcRiverBottom( Input );
				
				return Out;
			}
		]]
	}
}

Effect river_underwater
{
	VertexShader = "VertexShader"
	PixelShader = "PS_underwater"
}