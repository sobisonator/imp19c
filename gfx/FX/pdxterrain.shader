Includes = {
	"cw/pdxterrain.fxh"
	"cw/heightmap.fxh"
	"cw/shadow.fxh"
	"cw/utility.fxh"
	"cw/camera.fxh"
	"jomini/jomini_fog.fxh"
	"jomini/jomini_lighting.fxh"
	"jomini/jomini_water.fxh"
	"standardfuncsgfx.fxh"
	"terrain.fxh"
	"fog_of_war.fxh"
	"winter.fxh"
}

VertexStruct VS_OUTPUT_PDX_TERRAIN
{
	float4 Position			: PDX_POSITION;
	float3 WorldSpacePos	: TEXCOORD1;
	float4 ShadowProj		: TEXCOORD2;
};


VertexShader =
{
	Code
	[[
		VS_OUTPUT_PDX_TERRAIN TerrainVertex( float2 WithinNodePos, float2 NodeOffset, float NodeScale, float2 LodDirection, float LodLerpFactor )
		{
			STerrainVertex Vertex = CalcTerrainVertex( WithinNodePos, NodeOffset, NodeScale, LodDirection, LodLerpFactor );

			#ifdef TERRAIN_FLAT_MAP_LERP
				Vertex.WorldSpacePos.y = lerp( Vertex.WorldSpacePos.y, FlatMapHeight, FlatMapLerp );
			#endif
			#ifdef TERRAIN_FLAT_MAP
				Vertex.WorldSpacePos.y = FlatMapHeight;
			#endif
			
			VS_OUTPUT_PDX_TERRAIN Out;
			Out.WorldSpacePos = Vertex.WorldSpacePos;
			
			Out.Position = FixProjectionAndMul( ViewProjectionMatrix, float4( Vertex.WorldSpacePos, 1.0 ) );
			Out.ShadowProj = mul( ShadowMapTextureMatrix, float4( Vertex.WorldSpacePos, 1.0 ) );
			
			return Out;
		}
	]]
	
	MainCode VertexShader
	{
		Input = "VS_INPUT_PDX_TERRAIN"
		Output = "VS_OUTPUT_PDX_TERRAIN"
		Code
		[[			
			PDX_MAIN
			{
				return TerrainVertex( Input.UV, Input.NodeOffset_Scale_Lerp.xy, Input.NodeOffset_Scale_Lerp.z, Input.LodDirection, Input.NodeOffset_Scale_Lerp.w );
			}
		]]
	}
	
	MainCode VertexShaderSkirt
	{
		Input = "VS_INPUT_PDX_TERRAIN_SKIRT"
		Output = "VS_OUTPUT_PDX_TERRAIN"
		Code
		[[			
			PDX_MAIN
			{
				VS_OUTPUT_PDX_TERRAIN Out = TerrainVertex( Input.UV, Input.NodeOffset_Scale_Lerp.xy, Input.NodeOffset_Scale_Lerp.z, Input.LodDirection, Input.NodeOffset_Scale_Lerp.w );
				
				float3 Position = FixPositionForSkirt( Out.WorldSpacePos, Input.VertexID );
				Out.Position = FixProjectionAndMul( ViewProjectionMatrix, float4( Position, 1.0 ) );

				return Out;
			}
		]]
	}
}


PixelShader =
{
	# PdxTerrain uses texture index 0 - 6

	# Jomini specific
	TextureSampler ShadowMap
	{
		Ref = PdxShadowmap
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		CompareFunction = less_equal
		SamplerType = "Compare"
	}
	
	# Game specific
	TextureSampler FogOfWarAlpha
	{
		Ref = JominiFogOfWar
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
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
	
	
	Code
	[[
		void ApplySnow( inout float3 Diffuse, inout float3 Normal, inout float4 Material, float3 TerrainNormal, float3 WorldSpacePos, in PdxTextureSampler2D WinterMap, in PdxTextureSampler2DArray DetailTextures, in PdxTextureSampler2DArray NormalTextures, in PdxTextureSampler2DArray MaterialTextures )
		{
			float Snow = GetSnowAmountForTerrain( TerrainNormal, WorldSpacePos, WinterMap );
			if( Snow > 0.0f )
			{
				float3 SnowUV = float3( CalcDetailUV( WorldSpacePos.xz ), SnowTerrainTextureArrayIndex );
				float4 SnowDiffuse = PdxTex2D( DetailTextures, SnowUV );
				float3 SnowNormal = UnpackRRxGNormal( PdxTex2D( NormalTextures, SnowUV ) );
				float4 SnowMaterial = PdxTex2D( MaterialTextures, SnowUV );
				
				float SnowNoiseFactor = 0.1;
				float SnowBlend = saturate( Snow * (1.0f+SnowNoiseFactor) - SnowNoiseFactor + ( SnowDiffuse.a * SnowNoiseFactor ) );
				//return vec4(SnowBlend);
				Diffuse = lerp( Diffuse, SnowDiffuse.rgb, SnowBlend );
				Material = lerp( Material, SnowMaterial, SnowBlend );
				
				//SnowNormal.xy *= SnowBlend;
				//SnowNormal.z = sqrt( 1.0f - dot(SnowNormal.xy,SnowNormal.xy) );
				//
				//Normal.xy += SnowNormal.xy;
				//Normal.z *= SnowNormal.z;
				//normalize( Normal );
				Normal = normalize( lerp( Normal, SnowNormal, SnowBlend ) );
			}	
		}
		
		float4 TerrainShader( VS_OUTPUT_PDX_TERRAIN Input )
		{
			clip( vec2(1.0) - Input.WorldSpacePos.xz * WorldSpaceToTerrain0To1 );
			
			float3 DetailDiffuse;
			float3 DetailNormal;
			float4 DetailMaterial;
			CalculateDetails( Input.WorldSpacePos.xz, DetailDiffuse, DetailNormal, DetailMaterial );
			
			float2 ColorMapCoords = Input.WorldSpacePos.xz * WorldSpaceToTerrain0To1;
			float3 ColorMap = PdxTex2D( ColorTexture, float2( ColorMapCoords.x, 1.0 - ColorMapCoords.y ) ).rgb;
			
			float ColorMapOverlayStrength = COLORMAP_OVERLAY_STRENGTH;

			#ifdef TERRAIN_FLAT_MAP_LERP
				float3 FlatMap = PdxTex2D( FlatMapTexture, float2( ColorMapCoords.x, 1.0 - ColorMapCoords.y ) ).rgb;
			#endif

			float3 Normal = CalculateNormal( Input.WorldSpacePos.xz );
			
			//#ifdef ENABLE_SNOW
			ApplySnow( DetailDiffuse.rgb, DetailNormal, DetailMaterial, Normal, Input.WorldSpacePos, WinterMap, DetailTextures, NormalTextures, MaterialTextures );							
			//#endif
			
			float3 Diffuse = GetOverlay( DetailDiffuse.rgb, ColorMap, ColorMapOverlayStrength );
			
			
			float3 ReorientedNormal = ReorientNormal( Normal, DetailNormal );

			#ifdef TERRAIN_COLOR_OVERLAY
				float3 BorderColor;
				float BorderPostLightingBlend;
				#ifndef TERRAIN_FLAT_MAP_LERP
					float3 FlatMap = vec3( 0.0f ); // Dummy
				#endif
				ApplyTerrainColor( Diffuse, FlatMap, BorderColor, BorderPostLightingBlend, ColorMapCoords );
			#endif
			
			float ShadowTerm = 1.0;
			
			#ifdef SHADOWS_ENABLED
			ShadowTerm = CalculateShadow( Input.ShadowProj, ShadowMap );
			#endif
	
			SMaterialProperties MaterialProps = GetMaterialProperties( Diffuse, ReorientedNormal, DetailMaterial.a, DetailMaterial.g, DetailMaterial.b );
			SLightingProperties LightingProps = GetSunLightingProperties( Input.WorldSpacePos, ShadowTerm );

			float3 FinalColor = CalculateSunLighting( MaterialProps, LightingProps, EnvironmentMap );

			#ifdef TERRAIN_COLOR_OVERLAY
				FinalColor = lerp( FinalColor, BorderColor, BorderPostLightingBlend );
			#endif
			
			#ifndef TERRAIN_UNDERWATER
				FinalColor = ApplyFogOfWar( FinalColor, Input.WorldSpacePos, FogOfWarAlpha );
				
				float vFogFactor = min(CalculateDistanceFogFactor( Input.WorldSpacePos ),0.6);
				#if defined(nightLight)
					vFogFactor *= 0.05;
				#endif
				FinalColor = ApplyDistanceFog( FinalColor, vFogFactor );
			#endif

			#ifdef TERRAIN_FLAT_MAP_LERP
				FinalColor = lerp( FinalColor, FlatMap, FlatMapLerp );
			#endif
			
			#ifdef TERRAIN_COLOR_OVERLAY
				float4 HighlightColor = BilinearColorSampleAtOffset( ColorMapCoords, IndirectionMapSize, InvIndirectionMapSize, ProvinceColorIndirectionTexture, ProvinceColorTexture, HighlightProvinceColorsOffset );
				FinalColor.rgb = lerp( FinalColor.rgb, HighlightColor.rgb, HighlightColor.a );
			#endif

			
			float Alpha = 1.0;
			#ifdef TERRAIN_UNDERWATER					
				Alpha = CompressWorldSpace( Input.WorldSpacePos );
			#endif
				
			#ifdef TERRAIN_DEBUG
				TerrainDebug( FinalColor, Input.WorldSpacePos );
			#endif

			DebugReturn( FinalColor, MaterialProps, LightingProps, EnvironmentMap );
			return float4( FinalColor, Alpha );
		}
	]]
	
	MainCode PixelShader
	{
		TextureSampler FlatMapTexture
		{
			Ref = TerrainFlatMap
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			SampleModeU = "Clamp"
			SampleModeV = "Clamp"
			File = "gfx/map/textures/flatmap.png"
			srgb = yes
		}
	
		Input = "VS_OUTPUT_PDX_TERRAIN"
		Output = "PDX_COLOR"
		Code
		[[			
			PDX_MAIN
			{
				return TerrainShader( Input );
			}
		]]
	}
	
	MainCode PixelShaderUnderwater
	{
		Input = "VS_OUTPUT_PDX_TERRAIN"
		Output = "PDX_COLOR"
		Code
		[[			
			PDX_MAIN
			{
				return TerrainShader( Input );
			}
		]]
	}
	
	MainCode PixelShaderFlatMap
	{
		TextureSampler FlatMapTexture
		{
			Ref = TerrainFlatMap
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			SampleModeU = "Clamp"
			SampleModeV = "Clamp"
			File = "gfx/map/textures/flatmap.png"
			srgb = yes
		}
		
		Input = "VS_OUTPUT_PDX_TERRAIN"
		Output = "PDX_COLOR"
		Code
		[[			
			PDX_MAIN
			{
				clip( vec2(1.0) - Input.WorldSpacePos.xz * WorldSpaceToTerrain0To1 );
				float2 ColorMapCoords = Input.WorldSpacePos.xz * WorldSpaceToTerrain0To1;
				return FlatTerrainShader( Input.WorldSpacePos, ColorMapCoords, FlatMapTexture );
			}
		]]
	}
}


Effect PdxTerrain
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
}
Effect PdxTerrainSkirt
{
	VertexShader = "VertexShaderSkirt"
	PixelShader = "PixelShader"
}


Effect PdxTerrainUnderwater
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShaderUnderwater"
	
	Defines = { "TERRAIN_UNDERWATER" }
}
Effect PdxTerrainUnderwaterSkirt
{
	VertexShader = "VertexShaderSkirt"
	PixelShader = "PixelShaderUnderwater"
	
	Defines = { "TERRAIN_UNDERWATER" }
}


Effect PdxTerrainFlat
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShaderFlatMap"
	
	Defines = { "TERRAIN_FLAT_MAP" }
}
Effect PdxTerrainFlatSkirt
{
	VertexShader = "VertexShaderSkirt"
	PixelShader = "PixelShaderFlatMap"
	
	Defines = { "TERRAIN_FLAT_MAP" }
}