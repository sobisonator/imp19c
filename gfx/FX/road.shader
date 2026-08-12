Includes = {
	"cw/shadow.fxh"
	"cw/pdxterrain.fxh"
	"jomini/jomini_lighting.fxh"
	"jomini/jomini_fog.fxh"
	"constants.fxh"
	"standardfuncsgfx.fxh"
	"jomini/jomini_road.fxh"
	"fxhs/clouds.fxh"
	"fxhs/terrain_tint.fxh"
	"fxhs/gh_atmospheric.fxh"
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
	TextureSampler EnvironmentMap
	{
		Ref = JominiEnvironmentMap
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
		Type = "Cube"
	}
	TextureSampler ShadowTexture
	{
		Ref = PdxShadowmap
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
		CompareFunction = less_equal
		SamplerType = "Compare"
	}
	TextureSampler WinterMap
	{
		Ref = WinterMap
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}

	MainCode PixelShader
	{
		Input = "VS_OUTPUT"
		Output = "PDX_COLOR"
		Code
		[[	
			PDX_MAIN
			{	
				float4 Diffuse;
				float4 Material;
				float3 Normal;
				JominiRoadSampleTextures( Input, Diffuse, Material, Normal );

				float FogOfWarAlphaValue = 1.0;
				float CloudMask = GetCloudShadowMask( Input.WorldSpacePos.xz, FogOfWarAlphaValue );
				float3 TerrainNormal = CalculateNormal( Input.WorldSpacePos.xz );

				SMaterialProperties MaterialProps = GetMaterialProperties( Diffuse.rgb, Normal, Material.a, Material.g, Material.b );
				SLightingProperties LightingProps = GetSunLightingProperties( Input.WorldSpacePos, ShadowTexture );

				float3 Color = CalculateTerrainDualScenarioLighting( MaterialProps, LightingProps, CloudMask, EnvironmentMap );
				Color = ApplyTerrainShadowTintWithClouds( Color, Input.WorldSpacePos.xz, CloudMask, LightingProps._ShadowTerm, Normal, TerrainNormal );

				Color = GH_ApplyAtmosphericEffects( Color, Input.WorldSpacePos, FogOfWarAlpha );
				Color = ApplyDistanceFog( Color, Input.WorldSpacePos );

				DebugReturn( Color, MaterialProps, LightingProps, EnvironmentMap );

				return float4( Color.rgb, Diffuse.a * ( GlobalOpacity * 1.4 ) );
			}
		]]
	}
}

Effect default
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
}
