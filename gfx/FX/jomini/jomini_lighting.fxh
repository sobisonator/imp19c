Includes = {
	"cw/lighting_util.fxh"
	"cw/shadow.fxh"
	"jomini/jomini.fxh"
	"constants.fxh"
	"standardfuncsgfx.fxh"
}

PixelShader = 
{
	TextureSampler lightMask
    {
        Index = 13
        MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Border"
		SampleModeV = "Border"
        File = "gfx/map/environment/nightLight.dds"
    }
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
			
			#ifdef eveningLight
				float2 tempUV = WorldSpacePos.xz / MapSize;
				tempUV.y = 1 - tempUV.y;
				LightingProps._LightIntensity *= PdxTex2D( lightMask, tempUV )*2;
			#endif
			// #ifdef morningLight
			// 	float2 tempUV = WorldSpacePos.xz / MapSize;
			// 	tempUV.y = 1 - tempUV.y;
			// 	LightingProps._LightIntensity *= PdxTex2D( morningMask, tempUV );
			// #endif
			#ifdef nightLight
				float2 tempUV = WorldSpacePos.xz / MapSize;
				tempUV.y = 1 - tempUV.y;
				LightingProps._LightIntensity *= PdxTex2D( lightMask, tempUV )*3;
			#endif
			// #ifdef dailyCycle
			// 	float2 tempUV = WorldSpacePos.xz / MapSize;
			// 	tempUV.y = 1 - tempUV.y;
			// 	float tempp = PdxTex2D( lightMask, tempUV );
				
			// 	float freq = 0.05f;
			// 	float4 weights = float4(sqrt(max(0,sin(freq*GlobalTime))), pow(max(0,sin(freq*GlobalTime-1.57)),5.0), sqrt(max(0,sin(freq*GlobalTime-3.14))), pow(max(0,sin(freq*GlobalTime-4.71)),5.0));
			// 	weights /= length(weights);
			// 	LightingProps._LightIntensity *= 0.25*weights.x+1.0*tempp*weights.y+1.5*tempp*weights.z+0.7*tempp*weights.w;
			// #endif

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
			
			float3 tempp = DiffuseLight + SpecularLight + DiffuseIBL + SpecularIBL;
			#ifdef eveningLight
				tempp.r *= 0.7;
				tempp.g *= 0.4;
				tempp.b *= 0.1;
			#endif
			#ifdef morningLight
				tempp.g *= 0.93;
				tempp.b *= 0.89;
				tempp *= 1.15; #0.95; too dark
			#endif
			#ifdef nightLight
				tempp *= 0.1;
			#endif
			// #ifdef dailyCycle
			// 	float freq = 0.05f;
			// 	float4 weights = float4(sqrt(max(0,sin(freq*GlobalTime))), pow(max(0,sin(freq*GlobalTime-1.57)),5.0), sqrt(max(0,sin(freq*GlobalTime-3.14))), pow(max(0,sin(freq*GlobalTime-4.71)),5.0));
			// 	weights /= length(weights);
			// 	tempp.r = min(1, tempp.r*(weights.x+0.7*weights.y+0.1*weights.z+weights.w));
			// 	tempp.g = min(1, tempp.g*(weights.x+0.4*weights.y+0.1*weights.z+0.93*weights.w));
			// 	tempp.b = min(1, tempp.b*(weights.x+0.1*weights.y+0.1*weights.z+0.89*weights.w));
			// #endif

			return tempp;
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
