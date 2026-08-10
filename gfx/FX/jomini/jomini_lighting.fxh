Includes = {
	"cw/lighting_util.fxh"
	"cw/shadow.fxh"
	"jomini/jomini.fxh"
	"constants.fxh"
	"clouds_def.fxh"
}

PixelShader = 
{
	Code
	[[
		//-------------------------------
		// Common lighting functions ----
		//-------------------------------
		SLightingProperties GetSunLightingProperties( float3 WorldSpacePos, float ShadowTerm )
		{
			SLightingProperties LightingProps;
			LightingProps._ToCameraDir = normalize( CameraPosition - WorldSpacePos );
			LightingProps._ToLightDir = ToSunDir;
			LightingProps._LightIntensity = SunDiffuse * SunIntensity;
			LightingProps._ShadowTerm = ShadowTerm;
			LightingProps._CubemapIntensity = CubemapIntensity;
			
			return LightingProps;
		}
		
		SLightingProperties GetSunLightingProperties( float3 WorldSpacePos, PdxTextureSampler2DCmp ShadowMap )
		{
			float4 ShadowProj = mul( ShadowMapTextureMatrix, float4( WorldSpacePos, 1.0 ) );
			float ShadowTerm = CalculateShadow( ShadowProj, ShadowMap );
			
			return GetSunLightingProperties( WorldSpacePos, ShadowTerm );
		}
		
		float3 CalculateSunLighting( SMaterialProperties MaterialProps, SLightingProperties LightingProps, PdxTextureSamplerCube EnvironmentMap )
		{
			float3 DiffuseLight;
			float3 SpecularLight;
			CalculateLightingFromLight( MaterialProps, LightingProps, DiffuseLight, SpecularLight );
			
			float3 DiffuseIBL;
			float3 SpecularIBL;
			CalculateLightingFromIBL( MaterialProps, LightingProps, EnvironmentMap, DiffuseIBL, SpecularIBL );
			
			return DiffuseLight + SpecularLight + DiffuseIBL + SpecularIBL;
		}
		
		//-------------------------------
		// Unified lighting system ------
		//-------------------------------

		float3 CalculateMapLighting( SMaterialProperties MaterialProps, SLightingProperties LightingProps, PdxTextureSamplerCube EnvironmentMap, float SpecularFactor )
		{
			float3 DiffuseLight;
			float3 SpecularLight;
			CalculateLightingFromLight( MaterialProps, LightingProps, DiffuseLight, SpecularLight );

			float3 DiffuseIBL;
			float3 SpecularIBL;
			CalculateLightingFromIBL( MaterialProps, LightingProps, EnvironmentMap, DiffuseIBL, SpecularIBL );

			return DiffuseLight + DiffuseIBL + ( SpecularIBL + SpecularLight ) * SpecularFactor;
		}

		// Scenario-specific lighting functions using separate cubemap files
		float3 CalculateTerrainSunnyLighting( SMaterialProperties MaterialProps, SLightingProperties LightingProps, PdxTextureSamplerCube EnvironmentMap )
		{
			#ifndef TERRAIN_FLAT_MAP_LERP
				LightingProps._ToLightDir = ToSunDir;
				LightingProps._LightIntensity = TERRAIN_SUNNY_SUN_COLOR * TERRAIN_SUNNY_SUN_INTENSITY;
				LightingProps._CubemapIntensity = CubemapIntensity * TERRAIN_SUNNY_IBL_SCALE;
			#endif
			return CalculateMapLighting( MaterialProps, LightingProps, EnvironmentMap, TERRAIN_SUNNY_SPECULAR_FACTOR );
		}

		float3 CalculateTerrainShadowLighting( SMaterialProperties MaterialProps, SLightingProperties LightingProps, PdxTextureSamplerCube EnvironmentMap )
		{
			LightingProps._ToLightDir = ToSunDir;
			LightingProps._LightIntensity = TERRAIN_OVERCAST_SUN_COLOR * TERRAIN_OVERCAST_SUN_INTENSITY;
			LightingProps._CubemapIntensity = CubemapIntensity * TERRAIN_OVERCAST_IBL_SCALE;
			return CalculateMapLighting( MaterialProps, LightingProps, EnvironmentMap, TERRAIN_OVERCAST_SPECULAR_FACTOR );
		}

		// Terrain dual scenario lighting - uses IBL for both sunny and shadow scenarios
		float3 CalculateTerrainDualScenarioLighting( SMaterialProperties MaterialProps, SLightingProperties LightingProps, float ShadowMask, PdxTextureSamplerCube EnvironmentMap )
		{
			if ( ShadowMask > 0.99f )
			{
				return CalculateTerrainShadowLighting( MaterialProps, LightingProps, EnvironmentMap );
			}
			if ( ShadowMask > 0.0f )
			{
				// Calculate both lighting scenarios
				float3 SunnyLighting = CalculateTerrainSunnyLighting( MaterialProps, LightingProps, EnvironmentMap );
				float3 ShadowLighting = CalculateTerrainShadowLighting( MaterialProps, LightingProps, EnvironmentMap );

				// Blend between scenarios based on shadow mask
				return lerp( SunnyLighting, ShadowLighting, ShadowMask );
			}

			return CalculateTerrainSunnyLighting( MaterialProps, LightingProps, EnvironmentMap );
		}

		float3 CalculateMapObjectsSunnyLighting( SMaterialProperties MaterialProps, SLightingProperties LightingProps, PdxTextureSamplerCube EnvironmentMap )
		{
			LightingProps._ToLightDir = ToSunDir;
			LightingProps._LightIntensity = MAP_OBJECTS_SUNNY_SUN_COLOR * MAP_OBJECTS_SUNNY_SUN_INTENSITY;
			LightingProps._CubemapIntensity = CubemapIntensity * MAP_OBJECTS_SUNNY_IBL_SCALE;
			return CalculateMapLighting( MaterialProps, LightingProps, EnvironmentMap, MAP_OBJECTS_SUNNY_SPECULAR_FACTOR );
		}
		float3 CalculateMapObjectsShadowLighting( SMaterialProperties MaterialProps, SLightingProperties LightingProps, PdxTextureSamplerCube EnvironmentMap )
		{
			LightingProps._ToLightDir = ToSunDir;
			LightingProps._LightIntensity = MAP_OBJECTS_OVERCAST_SUN_COLOR * MAP_OBJECTS_OVERCAST_SUN_INTENSITY;
			LightingProps._CubemapIntensity = CubemapIntensity * MAP_OBJECTS_OVERCAST_IBL_SCALE;
			return CalculateMapLighting( MaterialProps, LightingProps, EnvironmentMap, MAP_OBJECTS_OVERCAST_SPECULAR_FACTOR );
		}
		// Map objects dual scenario lighting - uses IBL for both sunny and shadow scenarios
		float3 CalculateMapObjectsDualScenarioLighting( SMaterialProperties MaterialProps, SLightingProperties LightingProps, float ShadowMask, PdxTextureSamplerCube EnvironmentMap )
		{
			if ( ShadowMask > 0.99f )
			{
				return CalculateMapObjectsShadowLighting( MaterialProps, LightingProps, EnvironmentMap );
			}
			if ( ShadowMask > 0.0f )
			{
				// Calculate both lighting scenarios
				float3 SunnyLighting = CalculateMapObjectsSunnyLighting( MaterialProps, LightingProps, EnvironmentMap );
				float3 ShadowLighting = CalculateMapObjectsShadowLighting( MaterialProps, LightingProps, EnvironmentMap );

				// Blend between scenarios based on shadow masks
				return lerp( SunnyLighting, ShadowLighting, ShadowMask );
			}

			return CalculateMapObjectsSunnyLighting( MaterialProps, LightingProps, EnvironmentMap );
		}



		//-------------------------------
		// Debugging --------------------
		//-------------------------------
		//#define PDX_DEBUG_NORMAL
		//#define PDX_DEBUG_DIFFUSE
		//#define PDX_DEBUG_SPEC
		//#define PDX_DEBUG_ROUGHNESS
		//#define PDX_DEBUG_METALNESS
		//#define PDX_DEBUG_SHADOW
		//#define PDX_DEBUG_SUN_LIGHT_SIMPLE_DIFFUSE // AKA Daniel mode
		//#define PDX_DEBUG_SUN_LIGHT_ONLY_SPECULAR
		//#define PDX_DEBUG_SUN_LIGHT
		//#define PDX_DEBUG_SUN_LIGHT_WITH_SHADOW
		//#define PDX_DEBUG_IBL_SIMPLE_DIFFUSE
		//#define PDX_DEBUG_IBL_DIFFUSE
		//#define PDX_DEBUG_IBL_SPECULAR
		//#define PDX_DEBUG_IBL

		void DebugReturn( inout float3 Out, SMaterialProperties MaterialProps, SLightingProperties LightingProps )
		{
		#ifdef PDX_DEBUG_NORMAL
			Out = saturate( MaterialProps._Normal );
		#endif
		
		#ifdef PDX_DEBUG_DIFFUSE
			Out = MaterialProps._DiffuseColor;
		#endif
		
		#ifdef PDX_DEBUG_SPEC
			Out = MaterialProps._SpecularColor;
		#endif
		
		#ifdef PDX_DEBUG_ROUGHNESS
			Out = vec3( MaterialProps._PerceptualRoughness );
		#endif
		
		#ifdef PDX_DEBUG_METALNESS
			Out = vec3( MaterialProps._Metalness );
		#endif
		
		#ifdef PDX_DEBUG_SHADOW
			Out = vec3( LightingProps._ShadowTerm );
		#endif
		
		#ifdef PDX_DEBUG_SUN_LIGHT_SIMPLE_DIFFUSE
			SMaterialProperties MaterialPropsCopy = MaterialProps;
			MaterialPropsCopy._DiffuseColor = vec3( 1.0 );
			MaterialPropsCopy._SpecularColor = vec3( 0.0 );
			
			float3 SpecularLight;
			CalculateLightingFromLight( MaterialPropsCopy, LightingProps, Out, SpecularLight );
		#endif
		
		#ifdef PDX_DEBUG_SUN_LIGHT_ONLY_SPECULAR			
			float3 DiffuseLight;			
			CalculateLightingFromLight( MaterialProps, LightingProps, DiffuseLight, Out );
		#endif
		
		#if defined( PDX_DEBUG_SUN_LIGHT ) || defined( PDX_DEBUG_SUN_LIGHT_WITH_SHADOW )
			float3 DiffuseLight;
			float3 SpecularLight;

			#ifdef PDX_DEBUG_SUN_LIGHT_WITH_SHADOW
				CalculateLightingFromLight( MaterialProps, LightingProps, DiffuseLight, SpecularLight );
			#else
				SLightingProperties LightingPropsNoShadow = LightingProps;
				LightingPropsNoShadow._ShadowTerm = 1.0;
				CalculateLightingFromLight( MaterialProps, LightingPropsNoShadow, DiffuseLight, SpecularLight );
			#endif
			
			Out = DiffuseLight + SpecularLight;
		#endif
		}

		void DebugReturn( inout float3 Out, SMaterialProperties MaterialProps, SLightingProperties LightingProps, PdxTextureSamplerCube EnvironmentMap )
		{
			DebugReturn( Out, MaterialProps, LightingProps );
		
		#if defined( PDX_DEBUG_IBL ) || defined( PDX_DEBUG_IBL_DIFFUSE ) || defined( PDX_DEBUG_IBL_SPECULAR ) || defined( PDX_DEBUG_IBL_SIMPLE_DIFFUSE )
			float3 DiffuseIBL;
			float3 SpecularIBL;
			
			SMaterialProperties MaterialPropsCopy = MaterialProps;
			#ifdef PDX_DEBUG_IBL_SIMPLE_DIFFUSE
				MaterialPropsCopy._DiffuseColor = vec3( 1.0 );
			#endif
			
			CalculateLightingFromIBL( MaterialPropsCopy, LightingProps, EnvironmentMap, DiffuseIBL, SpecularIBL );
			
			#if defined( PDX_DEBUG_IBL_DIFFUSE ) || defined( PDX_DEBUG_IBL_SIMPLE_DIFFUSE )
				Out = DiffuseIBL;
			#endif
			#ifdef PDX_DEBUG_IBL_SPECULAR
				Out = SpecularIBL;
			#endif
			#ifdef PDX_DEBUG_IBL
				Out = DiffuseIBL + SpecularIBL;
			#endif
		#endif
		}
	]]
}
