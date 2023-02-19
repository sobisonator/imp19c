Includes = {
	#"cw/utility.fxh"
}

ConstantBuffer( JominiFogOfWar )
{
	float2	FogOfWarAlphaMapSize;
	float2	InverseWorldSize;
	float2	FogOfWarPatternSpeed;
	float	FogOfWarPatternStrength;
	float	FogOfWarPatternTiling;
	float	FogOfWarTime;
	float	FogOfWarAlphaMin;
}

PixelShader =
{
	Code
	[[
		#ifndef FOG_OF_WAR_BLEND_FUNCTION
			#define FOG_OF_WAR_BLEND_FUNCTION loc_BlendFogOfWar
			float4 loc_BlendFogOfWar( float Alpha )
			{
				return float4( vec3(0.0), 1.0 - Alpha );
			}
		#endif

		void loc_ApplyFogOfWarPattern( inout float Alpha, in float3 Coordinate, PdxTextureSampler2D FogOfWarAlphaMask )
		{
			if( FogOfWarPatternStrength > 0.0f )
			{
				float2 UV = Coordinate.xz * InverseWorldSize * FogOfWarPatternTiling;
				float Noise1 = 1.0f - PdxTex2D( FogOfWarAlphaMask, UV ).g;
				float Noise2 = 1.0f - PdxTex2D( FogOfWarAlphaMask, UV * -0.13 ).g;
				float Detail = 0.5f;

				float Noise = saturate( Noise2 * (1.0f-Detail) + Detail * 0.5f + (Noise1-0.5f) * Detail );

				Noise *= 1.0f - Alpha;
				Alpha = smoothstep( 0.0, 1.0, Alpha + Noise * FogOfWarPatternStrength );
			}
		}
		float GetFogOfWarAlpha( in float3 Coordinate, PdxTextureSampler2D FogOfWarAlphaMask )
		{
			float Alpha = PdxTex2D( FogOfWarAlphaMask, Coordinate.xz * InverseWorldSize ).r;

			return FogOfWarAlphaMin + Alpha * (1.0f - FogOfWarAlphaMin);
		}
		float GetFogOfWarAlphaMultiSampled( in float3 Coordinate, PdxTextureSampler2D FogOfWarAlphaMask )
		{
			float Alpha = PdxTex2D( FogOfWarAlphaMask, Coordinate.xz * InverseWorldSize ).r;

			return FogOfWarAlphaMin + Alpha * (1.0f - FogOfWarAlphaMin);
		}

		float3 FogOfWarBlend( float3 Color, float Alpha )
		{
			float4 ColorAndAlpha = FOG_OF_WAR_BLEND_FUNCTION( Alpha );
			//if ( ColorAndAlpha.a > 0.1 ) {
			//	float tempp = 0.4;
			//	float gray = 0.2989*Color.r + 0.5870*Color.g + 0.1140*Color.b;
			//	Color.r = max(0,gray*tempp+Color.r*(1-tempp));
			//	Color.g = max(0,gray*tempp+Color.g*(1-tempp));
			//	Color.b = max(0,gray*tempp+Color.b*(1-tempp));
			//}
			//return Color;
			return lerp( Color, ColorAndAlpha.rgb, ColorAndAlpha.a );
		}

		// Immediate mode
		float3 ApplyFogOfWar( in float3 Color, in float3 Coordinate, PdxTextureSampler2D FogOfWarAlphaMask )
		{
			float Alpha = GetFogOfWarAlpha( Coordinate, FogOfWarAlphaMask );
			Alpha *= 0.8; // darker FOW
			return FogOfWarBlend( Color, Alpha );
		}
		float3 ApplyFogOfWarMultiSampled( in float3 Color, in float3 Coordinate, PdxTextureSampler2D FogOfWarAlphaMask )
		{
			float Alpha = GetFogOfWarAlphaMultiSampled( Coordinate, FogOfWarAlphaMask );
			return FogOfWarBlend( Color, Alpha );
		}

		// Post process
		float4 ApplyFogOfWar( in float3 WorldSpacePos, PdxTextureSampler2D FogOfWarAlphaMask )
		{
			return FOG_OF_WAR_BLEND_FUNCTION( GetFogOfWarAlpha( WorldSpacePos, FogOfWarAlphaMask ) );
		}
	]]
}
