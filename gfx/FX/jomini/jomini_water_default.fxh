Includes = {
	"cw/heightmap.fxh"
	"cw/utility.fxh"
	"cw/camera.fxh"
	"jomini/jomini_fog.fxh"
	"jomini/jomini_lighting.fxh"
	"jomini/jomini_water.fxh"
	"clouds.fxh"
}

Code
[[
	#ifndef JOMINIWATER_MapSize
		#define JOMINIWATER_MapSize MapSize
	#endif
	
	#ifndef JOMINIWATER_BorderLerpSize
		#define JOMINIWATER_BorderLerpSize 0.008
	#endif
]]

VertexShader =
{
	MainCode JominiWaterVertexShader
	{
		Input = "VS_INPUT_WATER"
		Output = "VS_OUTPUT_WATER"
		Code
		[[
			PDX_MAIN
			{
				VS_OUTPUT_WATER VertexOut;
				VertexOut.WorldSpacePos = float3( Input.Position.x, WaterHeight, Input.Position.y );
				
				#ifdef JOMINIWATER_BORDER_LERP
					VertexOut.WorldSpacePos.x = JOMINIWATER_MapSize.x + Input.Position.x * JOMINIWATER_BorderLerpSize;
				#endif
				
				VertexOut.Position = FixProjectionAndMul( ViewProjectionMatrix, float4( VertexOut.WorldSpacePos.xyz, 1.0 ) );
				
				VertexOut.UV01 = float2( VertexOut.WorldSpacePos.x / JOMINIWATER_MapSize.x, 1.0 - VertexOut.WorldSpacePos.z / JOMINIWATER_MapSize.y );
				
				return VertexOut;
			}
		]]
	}
}

PixelShader =
{	
	TextureSampler WaterColorTexture
	{
		Ref = JominiWaterTexture0
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler AmbientNormalTexture
	{
		Ref = JominiWaterTexture1
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler FlowMapTexture
	{
		Ref = JominiWaterTexture2
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler FlowNormalTexture
	{
		Ref = JominiWaterTexture3
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler ReflectionCubeMap
	{
		Ref = JominiWaterTexture4
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		Type = "Cube"
	}
	TextureSampler FoamTexture
	{
		Ref = JominiWaterTexture5
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler FoamRampTexture
	{
		Ref = JominiWaterTexture6
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
	}
	TextureSampler FoamMapTexture
	{
		Ref = JominiWaterTexture7
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler FoamNoiseTexture
	{
		Ref = JominiWaterTexture8
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	
	TextureSampler RefractionTexture
	{
		Ref = JominiRefraction
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
	}

	Code
	[[
		#ifndef JOMINIWATER_GlobalTime
			#define JOMINIWATER_GlobalTime GlobalTime
		#endif
		
		struct SWaterParameters
		{
			float4 _ScreenSpacePos;
			float3 _WorldSpacePos;
			float2 _WorldUV;
			float  _Depth;
			float3 _FlowNormal;
			float  _FlowFoamMask;
			float  _NoiseScale;
			float  _WaveSpeedScale;
			float  _WaveNoiseFlattenMult;
			#ifdef WATER_LOCAL_SPACE_NORMALS
			float3 _Tangent;
			float3 _Bitangent;
			float3 _Normal;
			#endif
		};

		float CalcSingleWave( float3 WorldSpacePos, float Depth, float TimeOffset )
		{
			// Scale wave frequency to keep consistent width
			float WaveFrequency = 0.4f; // Wider waves in shallow water
			
			float WaveLines = ( 1.0f - Depth ) - GlobalTime * 0.15f + TimeOffset;
			WaveLines = frac( WaveLines * WaveFrequency );
			
			// return WaveLines;
			// Only create waves in a portion of the cycle (0.5 to 1.0), leaving gaps (0.0 to 0.5)

			// Remap to 0-1 range for the wave portion
			float WavePortion = ( WaveLines - 0.5f ) * 2.0f;
			
			// Sharp leading edge (front of wave toward shore) - at END of wave portion
			float SharpEdge = smoothstep( 0.8f, 1.0f, WavePortion );
			
			// Soft trailing edge - strongest near sharp edge, fades toward ocean
			float TrailingFade = ( smoothstep( 0.1, 0.8f, WavePortion ) ) * 0.4f;
			
			// Combine for asymmetric wave shape
			float WaveShape = max( SharpEdge, TrailingFade );
			
			WaveLines = WaveShape;
			
			// Add depth-based fade: opaque near shore, fade toward ocean
			float DepthFade = smoothstep( 3.0f, 1.0f, Depth );
			WaveLines *= DepthFade;
			
			return WaveLines;
		}

		float CalcApproachingWaves( float2 WorldUV, float3 WorldSpacePos, float Depth )
		{
			// Sample flow map including alpha channel
			float4 FlowData = PdxTex2D( FlowMapTexture, WorldUV );
			float ShoreWaveMask = FlowData.a; // Alpha channel controls where waves appear
			// Early out if no shore waves should appear 
			if ( ShoreWaveMask <= 0.0f )
			{
				return 0.0f;
			}
			
			// Create 3 wave layers with basic wave patterns
			float Wave1 = CalcSingleWave( WorldSpacePos, Depth, 0.0f );
			float Wave2 = Wave1;
			float Wave3 = CalcSingleWave( WorldSpacePos, Depth, 1.0f );
			
			// Large scale mask UV transforms - red channel (different for each wave)
			float2 BaseUV = WorldSpacePos.xz * 0.001f; // Large scale
			float2 LargeScaleMaskUV1A = BaseUV + GlobalTime * float2( 0.002f, 0.001f );
			float2 LargeScaleMaskUV2A = BaseUV * 1.3f + GlobalTime * float2( -0.0015f, 0.0025f );
			float2 LargeScaleMaskUV3A = BaseUV * 0.8f + GlobalTime * float2( 0.0018f, -0.002f );
			
			// Large scale mask UV transforms - blue channel (different scale and motion for variety)
			float2 BlueBaseUV = BaseUV; // Different base scale
			float2 LargeScaleMaskUV1B = BlueBaseUV * 0.7f + GlobalTime * float2(0.0015f, -0.001f);
			float2 LargeScaleMaskUV2B = BlueBaseUV * 1.8f + GlobalTime * float2(-0.0008f, 0.0032f);
			float2 LargeScaleMaskUV3B = BlueBaseUV * 1.1f + GlobalTime * float2(0.0015f, 0.0009f);
			
			// Sample large scale masks for each wave
			float LargeScaleMask1A = PdxTex2D( FoamTexture, LargeScaleMaskUV1A ).g;
			float LargeScaleMask1B = PdxTex2D( FoamTexture, LargeScaleMaskUV1B ).g;
			float LargeScaleMask2A = PdxTex2D( FoamTexture, LargeScaleMaskUV2A ).g;
			float LargeScaleMask2B = PdxTex2D( FoamTexture, LargeScaleMaskUV2B ).g;
			float LargeScaleMask3A = PdxTex2D( FoamTexture, LargeScaleMaskUV3A ).g;
			float LargeScaleMask3B = PdxTex2D( FoamTexture, LargeScaleMaskUV3B ).g;
			
			// Combine red and blue channels for each wave
			float LargeScaleMask1 = LargeScaleMask1A * LargeScaleMask1B;
			float LargeScaleMask2 = LargeScaleMask2A * LargeScaleMask2B;
			float LargeScaleMask3 = LargeScaleMask3A * LargeScaleMask3B;
			
			// Apply large scale masks to individual waves
			Wave1 *= LargeScaleMask1;
			Wave2 *= LargeScaleMask2;
			Wave3 *= LargeScaleMask3;
			
			// Recombine masked waves
			float ApproachingWaves = saturate( Wave1 + Wave2 + Wave3 );
			
			// Small-scale mask that affects all waves, with more opacity where waves are translucent 
			float2 SmallScaleMaskUV1 = WorldSpacePos.xz * 0.06f + GlobalTime * 0.2f * float2( 0.02f, 0.01f );
			float2 SmallScaleMaskUV2 = WorldSpacePos.xz * 0.5f + GlobalTime * float2( -0.08f, -0.06f );
			float SmallScaleMask1 = PdxTex2D( FoamTexture, SmallScaleMaskUV1 ).b;
			float SmallScaleMask2 = PdxTex2D( FoamNoiseTexture, SmallScaleMaskUV2 ).g;
			
			// Combine the two small scale masks with max for more complex patterns
			float SmallScaleMask = min(SmallScaleMask1, SmallScaleMask2);
			
			// Apply small scale mask with inverse relationship to wave opacity
			// Where waves are more translucent (lower ApproachingWaves), mask has more effect
			float MaskStrength = lerp( 0.3f, 1.0f, 1.0f - ApproachingWaves );
			SmallScaleMask = lerp( 1.0f, SmallScaleMask, MaskStrength );
			
			ApproachingWaves *= SmallScaleMask;
			
			// Apply foam map texture as a mask
			float FoamMap = PdxTex2D( FoamMapTexture, WorldUV ).g;
			ApproachingWaves *= FoamMap;

			return ApproachingWaves;
		}
		
		float CalcFoamFactor( float2 UV01, float2 WorldSpacePosXZ, float Depth, float FlowFoamMask, float3 FlowNormal )
		{
			// Foam calculation
			float2 NoiseUV = WorldSpacePosXZ * WaterFoamNoiseScale;
			float FoamNoise1 = PdxTex2D( FoamNoiseTexture, NoiseUV + float2(1,1) * JOMINIWATER_GlobalTime * WaterFoamNoiseSpeed ).r * 0.75;
			float FoamNoise2 = (PdxTex2D( FoamNoiseTexture, NoiseUV * 3 + float2(1,-1) * JOMINIWATER_GlobalTime * WaterFoamNoiseSpeed ).r - 0.5) * 0.5; // +/-0.25
			float FoamNoise3 = (PdxTex2D( FoamNoiseTexture, NoiseUV * 5 + float2(-1,0) * JOMINIWATER_GlobalTime * WaterFoamNoiseSpeed ).r - 0.5) * 0.25; // +/-0.125
			float FoamNoise = ( FoamNoise1 + FoamNoise2 + FoamNoise3 );

			float FoamMap = 1.0 - PdxTex2D( FoamMapTexture, UV01 ).r;
			float FoamBase = pow( FoamMap, 2.0 ) * 2.375 - 1.0;
			
			float NoiseCeiling = 2.0;
			float FoamFactor = smoothstep( FoamBase, FoamBase + NoiseCeiling, 1.0 - FoamNoise );
			//return FoamFactor;
			
			float FoamShoreMask = 1.0 - saturate( (WaterFoamShoreMaskDepth - Depth) * WaterFoamShoreMaskSharpness );
			//return FoamShoreMask;
			
			FoamFactor *= WaterFoamStrength * FoamShoreMask;
			//return FoamFactor;
			
			float3 Foam = PdxTex2D( FoamTexture, WorldSpacePosXZ * WaterFoamScale + FlowNormal.xz * WaterFoamDistortFactor ).rgb;
			//return Foam.r;
			float3 FoamRamp = PdxTex2DLod0( FoamRampTexture, float2( FoamFactor * FlowFoamMask, 0.5 ) ).rgb;
			//return FoamRamp.r;
			
			FoamFactor = saturate( dot( Foam, FoamRamp ) );
			
			return FoamFactor;
		}
		
		float3 CalcRefraction( float3 WorldSpacePos, float3 Normal, float2 ScreenPos, float3 WaterColor, float Depth )
		{
			float3 WaterColorMap = lerp( WaterColor, WaterColorMapTint, WaterColorMapTintFactor );
			//return WaterColorMap;
			
			#ifdef JOMINI_REFRACTION_ENABLED
				float4 RefractionSample = PdxTex2DLod0( RefractionTexture, ScreenPos / ScreenResolution );
				float3 RefractionWorldSpacePos = DecompressWorldSpace( WorldSpacePos, RefractionSample.a );
				float RefractionDepth = WorldSpacePos.y - RefractionWorldSpacePos.y;
		
				Depth = min( Depth, RefractionDepth );
				//return vec3(Depth);
				float RefractionShoreMask = 1.0 - saturate( (WaterRefractionShoreMaskDepth - Depth) * WaterRefractionShoreMaskSharpness );
				//return vec3( RefractionShoreMask );
				
				float2 RefractionOffset = mul( ViewMatrix, float4( Normal.x, 0, Normal.z, 0 ) ).xy * float2(-1, 1);
				RefractionOffset *= WaterRefractionScale * RefractionShoreMask * WaterRefractionFade;
				//return float3( saturate( RefractionOffset ), 0 );
			
				float4 OffsetRefractionSample = PdxTex2DLod0( RefractionTexture, ( ScreenPos + RefractionOffset ) / ScreenResolution );
				float3 OffsetRefractionWorldSpacePos = DecompressWorldSpace( WorldSpacePos, OffsetRefractionSample.a );
				
				float OffsetStep = step( WorldSpacePos.y, OffsetRefractionWorldSpacePos.y );
				//return vec3( 1.0 - OffsetStep );
				RefractionSample = lerp( OffsetRefractionSample, RefractionSample, OffsetStep );
				RefractionWorldSpacePos = lerp( OffsetRefractionWorldSpacePos, RefractionWorldSpacePos, OffsetStep );
				RefractionDepth = WorldSpacePos.y - RefractionWorldSpacePos.y;
				//return RefractionSample.rgb;
				
				float2 RefractionWaterColorUV = float2( RefractionWorldSpacePos.x / JOMINIWATER_MapSize.x, 1.0 - RefractionWorldSpacePos.z / JOMINIWATER_MapSize.y );
				float3 RefractionWaterColorMap = PdxTex2D( WaterColorTexture, RefractionWaterColorUV ).rgb;
				RefractionWaterColorMap = lerp( RefractionWaterColorMap, WaterColorMapTint, WaterColorMapTintFactor );
			
				float3 Refraction = CalcTerrainUnderwaterSeeThrough( RefractionDepth, RefractionWorldSpacePos, RefractionWaterColorMap, RefractionSample.rgb );
				//return Refraction;
				
				Refraction = lerp( WaterColorMap, Refraction, pow( 1.0 - WaterZoomedInZoomedOutFactor, 2.0 ) );
			#else
				float3 Refraction = WaterColorMap;
			#endif
			
			return Refraction;
		}
		
		float3 CalcReflection( float3 Normal, float3 ToCameraDir, float CloudShadowMask )
		{
			float3 ReflectionNormal = Normal;
			ReflectionNormal.y += WaterReflectionNormalFlatten; // TODO, decay with distance?
			ReflectionNormal = normalize( ReflectionNormal );
			float3 ReflectionVector = reflect( -ToCameraDir, ReflectionNormal );
			float3 Reflection = PdxTexCube( ReflectionCubeMap, ReflectionVector ).rgb * GetWaterCubemapIntensity( CloudShadowMask );
			
			return Reflection;
		}

		
		// This used to be the default lighting model, it has now been replaced
		// Moving it here because water is still using it and water shading is a bit special
		struct SWaterLightingProperties
		{
			float3 _WorldSpacePos;
			float3 _ToCameraDir;
			float3 _Normal;
			float3 _Diffuse;
		
			float3 _SpecularColor;
			float _Glossiness;
			float _NonLinearGlossiness;
		};
		
		#define PDX_GlossScale 11.0
		#define PDX_GlossBias 0.0
		#define PDX_MaxMipLevel 8.0
		float GetNonLinearGlossiness( float Glossiness )
		{
			return exp2( PDX_GlossScale * Glossiness + PDX_GlossBias );
		}
		
		float3 FresnelSchlick( float3 SpecularColor, float3 E, float3 H )
		{
			return SpecularColor + (vec3(1.0) - SpecularColor) * pow( 1.0 - saturate( dot(E, H) ), 5.0 );
		}
		
		SWaterLightingProperties GetLightingProperties( float3 WorldSpacePos, float3 Diffuse, float3 Normal, float4 Material )
		{
			float3 ToCameraDir = normalize( CameraPosition - WorldSpacePos );
			
			SWaterLightingProperties lightingProperties;
			lightingProperties._WorldSpacePos = WorldSpacePos;
			lightingProperties._ToCameraDir = ToCameraDir;
			lightingProperties._Normal = Normal;
			
			float SpecRemapped = Material.g * Material.g * 0.4;
			float Metalness = 1.0 - (1.0 - Material.b) * (1.0 - Material.b);
			float Glossiness = Material.a;
			lightingProperties._Diffuse = MetalnessToDiffuse( Metalness, Diffuse );
			lightingProperties._Glossiness = Glossiness;
			lightingProperties._SpecularColor = MetalnessToSpec( Metalness, Diffuse, SpecRemapped );
			lightingProperties._NonLinearGlossiness = GetNonLinearGlossiness( Glossiness );
			
			return lightingProperties;
		}
		
		float GetEnvmapMipLevel( float Glossiness )
		{
			return (1.0 - Glossiness) * (PDX_MaxMipLevel);
		}
		
		float3 FresnelGlossy( float3 SpecularColor, float3 E, float3 N, float Smoothness )
		{
			return SpecularColor + (max(vec3(Smoothness), SpecularColor) - SpecularColor) * pow(1.0 - saturate(dot(E, N)), 5.0);
		}
		
		float3 FresnelGlossy( SWaterLightingProperties Properties )
		{
			return FresnelGlossy( Properties._SpecularColor, Properties._ToCameraDir, Properties._Normal, Properties._Glossiness );
		}
		
		float3 GetReflectiveColor( SWaterLightingProperties Properties, PdxTextureSamplerCube EnvironmentMap, float EnvironmentMapIntensity )
		{		
			float3 ReflectionVector = reflect( -Properties._ToCameraDir, Properties._Normal );
			float MipmapIndex = GetEnvmapMipLevel( Properties._Glossiness );
			float3 ReflectiveColor = PdxTexCubeLod( EnvironmentMap, ReflectionVector, MipmapIndex ).rgb * EnvironmentMapIntensity;
			return ReflectiveColor * FresnelGlossy( Properties );
		}
		
		void ImprovedBlinnPhong( float3 LightColor, float3 ToLightDir, SWaterLightingProperties Properties, out float3 DiffuseLightOut, out float3 SpecularLightOut )
		{
			float3 H = normalize(Properties._ToCameraDir + ToLightDir);
			float NdotL = saturate(dot(Properties._Normal, ToLightDir));
			float NdotH = saturate(dot(Properties._Normal, H));
		
			float normalization = (Properties._NonLinearGlossiness + 2.0) / 8.0;
			float3 specColor = normalization * pow(NdotH, Properties._NonLinearGlossiness) * FresnelSchlick(Properties._SpecularColor, ToLightDir, H);
		
			DiffuseLightOut = LightColor * NdotL;
			SpecularLightOut = specColor * LightColor * NdotL;
		}

		void CalculateSunLight( SWaterLightingProperties Properties, float ShadowTerm, float3 ToSunDirection, float WaterSunIntensity, out float3 DiffuseLightOut, out float3 SpecularLightOut )
		{
			float3 sunIntensity = SunDiffuse * SunIntensity * ShadowTerm;
			ImprovedBlinnPhong( sunIntensity, ToSunDirection, Properties, DiffuseLightOut, SpecularLightOut );
		}

		float3 AmbientLight( float3 WorldNormal, float3 AmbientColors[6] )
		{
			// add more of bottom ambient below objects
			WorldNormal = normalize(WorldNormal - smoothstep(-0.6, 0.5, dot(WorldNormal, float3(0, -1, 0))) * float3(0, 0.9, 0));
		
			float3 Squared = WorldNormal * WorldNormal;
			int3 isNegative = int3(lessThan(WorldNormal, vec3(0.0)));
			float3 Color = Squared.x * AmbientColors[isNegative.x] + Squared.y * AmbientColors[isNegative.y+2] + Squared.z * AmbientColors[isNegative.z+4];
		
			return Color;
		}
		
		float3 AmbientLight( float3 WorldNormal, float ShadowTerm ) 
		{	
			float3 AmbientColors[6];
			ShadowTerm = smoothstep( SHADOW_AMBIENT_MIN_FACTOR, SHADOW_AMBIENT_MAX_FACTOR, ShadowTerm );
			AmbientColors[0] = lerp( ShadowAmbientPosX, AmbientPosX, ShadowTerm );
			AmbientColors[1] = lerp( ShadowAmbientNegX, AmbientNegX, ShadowTerm );
			AmbientColors[2] = lerp( ShadowAmbientPosY, AmbientPosY, ShadowTerm );
			AmbientColors[3] = lerp( ShadowAmbientNegY, AmbientNegY, ShadowTerm );
			AmbientColors[4] = lerp( ShadowAmbientPosZ, AmbientPosZ, ShadowTerm );
			AmbientColors[5] = lerp( ShadowAmbientNegZ, AmbientNegZ, ShadowTerm );
		
			return AmbientLight( WorldNormal, AmbientColors );
		}
		
		float3 ComposeLight( SWaterLightingProperties Properties, float3 AmbientLight, float3 DiffuseLight, float3 SpecularLight )
		{
			float3 diffuse = ((AmbientLight + DiffuseLight) * Properties._Diffuse);
			float3 specular = SpecularLight;

			return diffuse + specular;
		}
		
		float3 ComposeLight( SWaterLightingProperties Properties, float ShadowTerm, float3 ToSunDirection, float3 DiffuseLight, float3 SpecularLight )
		{
			float NdotL = saturate( dot(Properties._Normal, ToSunDirection) );
			float3 AmbientColor = AmbientLight( Properties._Normal, NdotL * ShadowTerm );
			return ComposeLight( Properties, AmbientColor, DiffuseLight, SpecularLight );
		}
		
		
		float4 CalcWater( in SWaterParameters Input )
		{
			float4 WaterColorAndSpec = PdxTex2D( WaterColorTexture, Input._WorldUV );
			float GlossMap = WaterColorAndSpec.a;

			float3 ToCamera = CameraPosition.xyz - Input._WorldSpacePos;
			float3 ToCameraDir = normalize( ToCamera );

			// "Noise" normals
			float2 UVCoord = Input._WorldSpacePos.xz * float2(1, -1) * Input._NoiseScale;
			float3 NormalMap1 = SampleNormalMapTexture( AmbientNormalTexture, UVCoord, WaterWave1Scale, WaterWave1Rotation, JOMINIWATER_GlobalTime * WaterWave1Speed * Input._WaveSpeedScale, WaterWave1NormalFlatten * Input._WaveNoiseFlattenMult );
			float3 NormalMap2 = SampleNormalMapTexture( AmbientNormalTexture, UVCoord, WaterWave2Scale, WaterWave2Rotation, JOMINIWATER_GlobalTime * WaterWave2Speed * Input._WaveSpeedScale, WaterWave2NormalFlatten * Input._WaveNoiseFlattenMult );
			float3 NormalMap3 = SampleNormalMapTexture( AmbientNormalTexture, UVCoord, WaterWave3Scale, WaterWave3Rotation, JOMINIWATER_GlobalTime * WaterWave3Speed * Input._WaveSpeedScale, WaterWave3NormalFlatten * Input._WaveNoiseFlattenMult );
			
			float3 Normal = NormalMap1 + NormalMap2 + NormalMap3 + Input._FlowNormal;
			#ifdef WATER_LOCAL_SPACE_NORMALS
				float3x3 TBN = Create3x3( Input._Tangent, Input._Bitangent, Input._Normal );
				Normal = normalize( mul( Normal.xzy, TBN ) );
			#else
				Normal = normalize( Normal );
			#endif
			
			float FoamFactor = CalcFoamFactor( Input._WorldUV, Input._WorldSpacePos.xz, Input._Depth, Input._FlowFoamMask, Input._FlowNormal );
			
			float Facing = 1.0 - max( dot( Normal, ToCameraDir ), 0 );
			float3 WaterDiffuse = lerp( WaterColorDeep, WaterColorShallow, Facing );
			WaterDiffuse *= WaterDiffuseMultiplier;

			float ShadowTerm = 1.0f;
			// float FogOfWarAlphaValue = PdxTex2D( FogOfWarAlpha, Input._WorldSpacePos.xz * WorldSpaceToTerrain0To1 ).r;
			float FogOfWarAlphaValue = 1.0;
			float CloudShadowMask = GetCloudShadowMask( Input._WorldSpacePos.xz, FogOfWarAlphaValue );
			CloudShadowMask = max( 1.0f - ShadowTerm, CloudShadowMask );

			SWaterLightingProperties lightingProperties;
			lightingProperties._WorldSpacePos = Input._WorldSpacePos;
			lightingProperties._ToCameraDir = ToCameraDir;
			lightingProperties._Normal = Normal;
			lightingProperties._Diffuse = WaterDiffuse + FoamFactor;
			lightingProperties._Glossiness = lerp( WaterGlossBase, GlossMap, WaterZoomedInZoomedOutFactor );
			lightingProperties._SpecularColor = vec3(WaterSpecular);
			lightingProperties._NonLinearGlossiness = GetNonLinearGlossiness( lightingProperties._Glossiness ) * GetWaterGlossScale( CloudShadowMask );
			
			float3 DiffuseLight = vec3(0.0);
			float3 SpecularLight = vec3(0.0);
			float3 WaterToSunDir = GetWaterToSunDirection( CloudShadowMask );
			float WaterSunIntensity = GetWaterSunIntensity( CloudShadowMask );
			float SunIntensityMask = smoothstep( 0.05f, 0.1f, GlossMap ); // We use very dark values in the gloss map to simular occlusion
			CalculateSunLight( lightingProperties, 1.0, WaterToSunDir, WaterSunIntensity * SunIntensityMask, DiffuseLight, SpecularLight );
			
			float3 FinalColor = ComposeLight( lightingProperties, 1.0, WaterToSunDir, DiffuseLight, SpecularLight * GetWaterSpecularFactor( CloudShadowMask ) );

			float3 Refraction = CalcRefraction( Input._WorldSpacePos, Normal, Input._ScreenSpacePos.xy, WaterColorAndSpec.rgb, Input._Depth );
		
			float3 Reflection = CalcReflection( Normal, ToCameraDir, CloudShadowMask );
			
			float FresnelFactor = Fresnel( abs( dot( lightingProperties._ToCameraDir, Normal ) ), WaterFresnelBias, WaterFresnelPow );

			FinalColor += lerp( Refraction, Reflection, FresnelFactor );

			float WaterFade = 1.0 - saturate( (WaterFadeShoreMaskDepth - Input._Depth) * WaterFadeShoreMaskSharpness );

			#ifdef JOMINIWATER_BORDER_LERP
				float ExtraFade = 1.0 - (Input._WorldUV.x - 1.0) / JOMINIWATER_BorderLerpSize;
				WaterFade *= ExtraFade;
			#endif

			// Calculate approaching waves
			float ApproachingWaves = CalcApproachingWaves( Input._WorldUV, Input._WorldSpacePos, Input._Depth );
			// Blend approaching waves with water color
			FinalColor = lerp( FinalColor, float3( 1.0f, 1.0f, 1.0f ), ApproachingWaves );

			return float4( FinalColor, WaterFade );
		}
		
		float4 CalcWater( VS_OUTPUT_WATER Input, out float Depth )
		{
			float Height = GetHeightMultisample( Input.WorldSpacePos.xz, 0.65 );
			Depth = Input.WorldSpacePos.y - Height;
			
			SWaterParameters Params;
			Params._ScreenSpacePos = Input.Position;
			Params._WorldSpacePos = Input.WorldSpacePos;
			Params._WorldUV = Input.UV01;
			Params._Depth = Depth;
			Params._NoiseScale = 0.05f;
			Params._WaveSpeedScale = 1.0f;
			Params._WaveNoiseFlattenMult = 1.0f;
			Params._FlowNormal = CalcFlow( FlowMapTexture, FlowNormalTexture, Params._WorldUV, Params._WorldSpacePos.xz, Params._FlowFoamMask );
			
			return CalcWater( Params );
		}
		
		float4 CalcWater( VS_OUTPUT_WATER Input )
		{
			float Depth;
			return CalcWater( Input, Depth );
		}
	]]
	
	MainCode JominiWaterPixelShader
	{
		Input = "VS_OUTPUT_WATER"
		Output = "PDX_COLOR"
		Code
		[[			
			PDX_MAIN
			{
				float4 Water = CalcWater( Input ); 
				Water.rgb = ApplyDistanceFog( Water.rgb, Input.WorldSpacePos );
				return Water;
			}
		]]
	}
}


BlendState BlendState
{
	BlendEnable = yes
	SourceBlend = "src_alpha"
	DestBlend = "inv_src_alpha"
	WriteMask = "RED|GREEN|BLUE"
}

RasterizerState RasterizerState
{
	DepthBias = -100
}
