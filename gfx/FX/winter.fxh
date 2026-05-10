Includes = {
	"cw/utility.fxh"
	"standardfuncsgfx.fxh"
	"constants.fxh"
}

ConstantBuffer( WinterConstants )
{
	float2 	TerrainSnowMinMaxCosAngles;
	float2 	MeshSnowMinMaxCosAngles;
	float2 	TreeSnowMinMaxCosAngles;
	float2 	InvSnowTextureSize;
	float2	SnowTextureSize;
	float2	SnowNoiseTextureSize;
	float3	SnowLevelLimits;
	
	int		SnowTerrainTextureArrayIndex;
	int		IceTerrainTextureArrayIndex;
	float 	SnowNoiseFactor;
	float	SnowNoiseScale;
	float	SnowThinStrength;
	
	float IceTiling;
	float IceTilingLarge;
	float IceDepthScale;
	float WinternessDepthOffset;
	float ConstantDepthOffset;
}

PixelShader =
{
	Code
	[[
		float loc_BlendSnow( float Lower, float Upper, float Value )
		{
			//return smoothstep( Lower, Upper, Value );
			//return Remap( Value, Lower, Upper, 0.0f, 1.0f );
			return RemapClamped( Value, Lower, Upper, 0.0f, 1.0f );
		}
		float loc_GetSnowAmount( float3 Normal, float3 WorldSpacePos, float2 SnowMinMaxCosAngles, in PdxTextureSampler2D SnowMask )
		{
			if( EnableSnow > 0.5f )
			{
				float Winterness = SnowLevelLimits.z * PdxTex2D( SnowMask, WorldSpacePos.xz / MapSize ).r;
				float Noise = PdxTex2D( SnowMask, WorldSpacePos.xz * SnowNoiseScale / MapSize).g;
				float InvWinterness = 1.0f - Winterness;
				
				//Same blending as EU4 but with tweakable parameters
				float ThinSnow = saturate( loc_BlendSnow( SnowLevelLimits.x, SnowLevelLimits.y, Noise ) - InvWinterness );
				float ThickSnow = loc_BlendSnow( 0.0, 0.1, Noise - InvWinterness );
				
				float Snow = saturate( ThickSnow + ThinSnow * SnowThinStrength * 3.0f );
				float NdotUp = Normal.y;
				float AngleMask = smoothstep( SnowMinMaxCosAngles.y, SnowMinMaxCosAngles.x, NdotUp );
	
				return AngleMask * Snow;
			}
			return 0.0f;
		}
		
		void loc_ApplySnow( inout float3 Diffuse, inout float3 Normal, inout float4 Properties, float3 WorldSpacePos, in PdxTextureSampler2D ColorMap, float2 SnowMinMaxCosAngles, in PdxTextureSampler2D SnowMask, in PdxTextureSampler2DArray SnowDiffuseMap, in PdxTextureSampler2DArray SnowNormalMap, in PdxTextureSampler2DArray SnowPropertiesMap )
		{
			float Snow = loc_GetSnowAmount( Normal, WorldSpacePos, SnowMinMaxCosAngles, SnowMask );
			if( Snow > 0.0f )
			{
				float3 UV = float3( WorldSpacePos.xz * 0.1f, SnowTerrainTextureArrayIndex );
				float4 SnowDiffuse = PdxTex2D( SnowDiffuseMap, UV );
				float4 SnowProperties = PdxTex2D( SnowPropertiesMap, UV );
				float4 SnowNormal = PdxTex2D( SnowNormalMap, UV );
				SnowDiffuse.rgb *= float3( 0.6, 0.6, 0.6 );
				//float Blend = Snow * SnowDiffuse.a;
				float Blend = smoothstep( 0.0f, 0.5f, Snow );
				//float Blend = Snow;
				
				float2 ColorMapUV = WorldSpacePos.xz / ( MapSize - vec2(1) );
				ColorMapUV.y = 1.0f - ColorMapUV.y;
				float3 ColorMapSample = PdxTex2D( ColorMap, ColorMapUV ).rgb;
				SnowDiffuse.rgb = GetOverlay( SnowDiffuse.rgb, ColorMapSample, COLORMAP_OVERLAY_STRENGTH );
				
				Diffuse.rgb = lerp( Diffuse, SnowDiffuse.rgb, Blend );
				Properties = lerp( Properties, SnowProperties, Blend );
				Normal = lerp ( Normal, SnowNormal, Blend );
				//TODO(maybe) normals
			}
		}
		
		//Helpers
		float GetSnowAmountForWater( float3 Normal, float3 WorldSpacePos, in PdxTextureSampler2D SnowMask )
		{
			if( EnableSnow > 0.5f )
			{
				float Snow = PdxTex2D( SnowMask, WorldSpacePos.xz / MapSize ).r;
				float AngleMask = smoothstep( 0.0f, 1.0f, Normal.y );
				return AngleMask * Snow;
			}
			return 0.0f;
		}
		float GetSnowAmountForTerrain( float3 Normal, float3 WorldSpacePos, in PdxTextureSampler2D SnowMask )
		{
			return loc_GetSnowAmount( Normal, WorldSpacePos, TerrainSnowMinMaxCosAngles, SnowMask );
		}
		
		void ApplySnowMesh( inout float3 Diffuse, inout float3 Normal, inout float4 Properties, float3 WorldSpacePos, in PdxTextureSampler2D ColorMap, in PdxTextureSampler2D SnowMask, in PdxTextureSampler2DArray SnowDiffuse, in PdxTextureSampler2DArray SnowNormal, in PdxTextureSampler2DArray SnowProperties )
		{
			loc_ApplySnow( Diffuse, Normal, Properties, WorldSpacePos, ColorMap, MeshSnowMinMaxCosAngles, SnowMask, SnowDiffuse, SnowNormal, SnowProperties );
		}
		void ApplySnowTree( inout float3 Diffuse, inout float3 Normal, inout float4 Properties, float3 WorldSpacePos, in PdxTextureSampler2D ColorMap, in PdxTextureSampler2D SnowMask, in PdxTextureSampler2DArray SnowDiffuse, in PdxTextureSampler2DArray SnowNormal, in PdxTextureSampler2DArray SnowProperties )
		{
			loc_ApplySnow( Diffuse, Normal, Properties, WorldSpacePos, ColorMap, TreeSnowMinMaxCosAngles, SnowMask, SnowDiffuse, SnowNormal, SnowProperties );
		}
	]]
}