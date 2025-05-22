Includes = {
	"jomini/jomini_water_default.fxh"
	"jomini/jomini_water_pdxmesh.fxh"
	"jomini/jomini_mapobject.fxh"
	"fog_of_war.fxh"
	"standardfuncsgfx.fxh"
	"winter.fxh"
	"terrain.fxh"
}

PixelShader =
{
	TextureSampler FogOfWarAlpha
	{
		Ref = JominiFogOfWar
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		// MagFilter = "Point"
		// MinFilter = "Point"
		// MipFilter = "Point"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler FlatMapTexture
	{
		Ref = TerrainFlatMap
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
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
	TextureSampler TerrainDiffuseArray
	{
		Ref = PdxTerrainTextures0
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		type = "2darray"
	}
	TextureSampler TerrainNormalsArray
	{
		Ref = PdxTerrainTextures1
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		type = "2darray"
	}
	TextureSampler TerrainMaterialArray
	{
		Ref = PdxTerrainTextures2
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		type = "2darray"
	}
	TextureSampler TerrainColorMapTexture	#This is used to tint the ice to match the snow on the shore
	{
		Ref = PdxTerrainColorMap
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
	}

	MainCode PixelShader
	{
		Input = "VS_OUTPUT_WATER"
		Output = "PDX_COLOR"
		Code
		[[
		
			#ifndef PDX_OSX // [ED] Note: Definitely exceeds the limit of 16 samplers on mac
				float4 CalcIce( float3 WorldSpacePos, float Depth )
				{
					float4 Color = vec4(0.0f);
					float Ice = GetSnowAmountForWater( float3(0,1,0), WorldSpacePos, WinterMap );
					if( Ice > 0.0f )
					{
						float3 UV = float3( WorldSpacePos.xz * IceTiling, IceTerrainTextureArrayIndex );
						float4 Diffuse = PdxTex2D( TerrainDiffuseArray, UV );
						float4 Material = PdxTex2D( TerrainMaterialArray, UV );
						float3 Normal = UnpackRRxGNormal( PdxTex2D( TerrainNormalsArray, UV ) ).rbg;

						//Use the the ice-sheet pattern in the diffuse in a larger tiling to create groups of ice sheets
						//Fake shallower water underneath these groups
						float GroupAlpha = PdxTex2D( TerrainDiffuseArray, UV * float3( vec2(IceTilingLarge), 1 ) ).a;
						Depth -= ConstantDepthOffset * saturate( Ice * 5.0f );
						Depth -= GroupAlpha * ( WinternessDepthOffset * Ice );

						float Alpha = 1.0f - saturate( Depth * IceDepthScale / Ice );					
						Alpha = lerp( Alpha, saturate( saturate( Alpha - 0.25f ) * 5.0f + Diffuse.a * Alpha * 5.0f ), 1.0f - Alpha );
						Alpha = smoothstep( 0.2f, 0.3f, Alpha );

						float3 ColorMapSample = PdxTex2D( TerrainColorMapTexture, WorldSpacePos.xz / ( MapSize - vec2(1) ) ).rgb;
						Diffuse.rgb = GetOverlay( Diffuse.rgb, ColorMapSample, COLORMAP_OVERLAY_STRENGTH );

						SWaterLightingProperties lightingProperties = GetLightingProperties( WorldSpacePos, Diffuse.rgb, Normal, Material );				
						float3 DiffuseLight = vec3(0.0);
						float3 SpecularLight = vec3(0.0);
						float ShadowTerm = 1.0f;
						CalculateSunLight( lightingProperties, ShadowTerm, WaterToSunDir, DiffuseLight, SpecularLight );
						//CalculatePointLights( lightingProperties, LightDataMap, LightIndexMap, DiffuseLight, SpecularLight );
						SpecularLight += GetReflectiveColor( lightingProperties, ReflectionCubeMap, WaterCubemapIntensity );

						Color.rgb = ComposeLight( lightingProperties, ShadowTerm, WaterToSunDir, DiffuseLight, SpecularLight );
						Color.a = Alpha;				
					}
					return Color;
				}
			#endif

			PDX_MAIN
			{
				float Depth;
				float4 Water = CalcWater( Input, Depth );

				// Ice
				#ifndef PDX_OSX // [ED] Note: Definitely exceeds the limit of 16 samplers on mac
					#ifdef ENABLE_SNOW
						float4 Ice = CalcIce( Input.WorldSpacePos, Depth );
						Ice.rgb *= float3( 0.6, 0.6, 1.0 );
						Water.rgb = lerp( Water.rgb, Ice.rgb, Ice.a );
					#endif
				#endif

				// Province colors
				#ifndef PDX_OSX // [ED] Note: Definitely exceeds the limit of 16 samplers on mac
					float2 ColorMapCoords = float2( Input.UV01.x, 1.0f - Input.UV01.y ) + ( 1.0f / MapSize ) * 0.5f;
					#ifdef TERRAIN_COLOR_OVERLAY						
						float3 BorderColor = float3(0,0,0);
						float3 FlatMap = float3(0,0,0);
						float BorderPostLightingBlend;
						
						ApplyTerrainColor( Water.rgb, FlatMap, BorderColor, BorderPostLightingBlend, ColorMapCoords );
					#endif
				#endif

				// FoW and Fog
				Water.rgb = ApplyFogOfWarMultiSampled( Water.rgb, Input.WorldSpacePos, FogOfWarAlpha );

				float vFogFactor = min(CalculateDistanceFogFactor( Input.WorldSpacePos ),0.6);
				#if defined(nightLight)
					vFogFactor *= 0.05;
				#endif
				Water.rgb = ApplyDistanceFog( Water.rgb, vFogFactor );

				// Lerp to flat map terrain for smooth transition. When FlatMapLerp >= 1.0 this shader is not called at all!
				#ifdef TERRAIN_FLAT_MAP_LERP
					#ifndef PDX_OPENGL // [TK] Note: Definitely exceeds the limit of 16 samplers on anything but windows
						float4 FlatTerrainColor = FlatTerrainShader( Input.WorldSpacePos, ColorMapCoords, FlatMapTexture );
						Water.rgb = lerp( Water.rgb, FlatTerrainColor.rgb, FlatMapLerp );
					#endif
				#endif

				return Water;
			}
		]]
	}
}

Effect water
{
	VertexShader = "JominiWaterVertexShader"
	PixelShader = "PixelShader"
}

Effect lake
{
	VertexShader = "VS_jomini_water_mesh"
	PixelShader = "PixelShader"
}

Effect lake_mapobject
{
	VertexShader = "VS_jomini_water_mapobject"
	PixelShader = "PixelShader"
}
