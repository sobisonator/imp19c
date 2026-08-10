Includes = {
	"clouds_def.fxh"
}
Code
[[
	// Get water cubemap intensity based on shadow mask
	float GetWaterCubemapIntensity( float ShadowMask )
	{
		return lerp( WATER_SUNNY_IBL_SCALE, WATER_OVERCAST_IBL_SCALE, ShadowMask );
	}
	// Get water sun direction based on shadow mask
	float3 GetWaterToSunDirection( float ShadowMask )
	{
		float3 SunnyDir = ToWaterSunnySunDir;
		float3 ShadowDir = ToWaterOvercastSunDir;
		return normalize( lerp( SunnyDir, ShadowDir, ShadowMask ) );
	}
	// Get water gloss scale based on shadow mask
	float GetWaterGlossScale( float ShadowMask )
	{
		return lerp( WATER_SUNNY_GLOSS_SCALE, WATER_OVERCAST_GLOSS_SCALE, ShadowMask );
	}
	// Get water specular factor based on shadow mask
	float GetWaterSpecularFactor( float ShadowMask )
	{
		return lerp( WATER_SUNNY_SPECULAR_FACTOR, WATER_OVERCAST_SPECULAR_FACTOR, ShadowMask );
	}
	// Get water sun intensity based on shadow mask
	float GetWaterSunIntensity( float ShadowMask )
	{
		return lerp( WATER_SUNNY_SUN_INTENSITY_MULTIPLIER, WATER_OVERCAST_SUN_INTENSITY_MULTIPLIER, ShadowMask );
	}

	float GetZoomedInZoomedOutFactor()
	{
		return saturate( ( CameraPosition.y - ZoomInHeight ) / ( ZoomOutHeight - ZoomInHeight + 1e-5 ) );
	}

	float GetCloud( float2 p )
	{
		float f;
		f  = 0.50000 * CalcNoise( p ); p = p * 2.01f;
		f += 0.25000 * CalcNoise( p ); p = p * 2.02f;
		f += 0.12500 * CalcNoise( p ); p = p * 2.03f;
		f += 0.06250 * CalcNoise( p ); p = p * 2.04f;
		f += 0.03125 * CalcNoise( p );

		return f;
	}
	float GetCloudShadowMask( in float2 Coordinate, float FogOfWarAlphaValue )
	{
		#ifdef LOW_SPEC_SHADERS
			return 0.0f;
		#endif

		if ( HasCloudShadowEnabled != 1 )
		{
			return 0.0f;
		}

		// Skip cloud calculations if in fog of war
		if ( FogOfWarAlphaValue < 0.1f )
		{
			return 0.0f;
		}
		float ZoomedInZoomedOutFactor = GetZoomedInZoomedOutFactor();
		// Apply zoom-based fading - clouds fade out when zooming out
		float ZoomFadeFactor = min( 1.0f, pow( 1.0f - ZoomedInZoomedOutFactor + 0.24f, 6.0f ) );

		// Skip cloud rendering when ZoomFadeFactor is near zero to optimize performance
		if ( ZoomFadeFactor < 0.01f )
		{
			return 0.0f;
		}

		float2 Uv00 = Coordinate * InverseWorldSize * float2( 2.0f, 1.0f );
		float2 CloudMovement = CloudDirection * AdjustedTime;
		float2 Uv01 = Uv00;
		float2 AnimationValue01 = CloudMovement * CloudMainSpeed;
		Uv01 *= CloudMainTiling;
		Uv01 += AnimationValue01;

		float2 Uv02 = Uv00;
		Uv02 *= CloudMainTiling * CloudSecondaryTiling;
		float2 AnimationValue02 = CloudMovement * CloudSecondarySpeed;
		Uv02 += AnimationValue02;

		float2 Uv03 = Uv00;
		Uv03 *= CloudMainTiling * CloudDetailTiling;
		float2 AnimationValue03 = CloudMovement * CloudDetailSpeed;
		Uv03 += AnimationValue03;

		float Clouds01 = GetCloud( Uv01 );
		float Clouds02 = GetCloud( Uv02 );
		float Clouds03 = GetCloud( Uv03 );

		Clouds01 = LevelsScan( Clouds01, CloudMainPosition, CloudMainContrast );
		Clouds02 = LevelsScan( Clouds02, CloudMainPosition + CloudSecondaryPosition, CloudMainContrast + CloudSecondaryContrast );
		Clouds03 = LevelsScan( Clouds03, CloudMainPosition + CloudDetailPosition, CloudMainContrast + CloudDetailContrast );

		float Cloud = Overlay( Clouds01, Clouds02 );
		Cloud = Overlay( Cloud, Clouds03 );

		return Cloud * CloudOpacity * FogOfWarAlphaValue * ZoomFadeFactor;
	}


	float3 ApplyOvercastContrast( float3 Color, float BlendAmount )
	{
		if ( BlendAmount < 0.0001f )
		{
			return Color;
		}
		float CurrentLuminance = dot( Color, float3( 0.299f, 0.587f, 0.114f ) );
		float MinLuminance = 0.008f; // Minimum brightness floor to prevent clipping

		// Soft toe using power curve - asymptotically approaches minimum
		float LuminanceRange = CurrentLuminance - MinLuminance;
		float DarkenedRange = LuminanceRange * ( 1.0f - BlendAmount );
		float TargetLuminance = MinLuminance + DarkenedRange;

		// Scale RGB proportionally to achieve target luminance (preserves hue/saturation)
		return Color * ( TargetLuminance / max( CurrentLuminance, 0.001f ) );
	}


	struct SShadowTintData
	{
		float2 _NoiseUV;
		float4 _TintColor;
		float _MapSadowTintStrengthValue;
	};

	SShadowTintData GetShadowTintData( float2 Coordinate )
	{
		SShadowTintData ShadowTintData;
		ShadowTintData._NoiseUV = Coordinate * MapSadowTintNoiseUVTiling;
		ShadowTintData._TintColor = PdxTex2D( ShadowNoiseTexture, ShadowTintData._NoiseUV );
		ShadowTintData._MapSadowTintStrengthValue = MapSadowTintStrength * ShadowTintData._TintColor.a;
		return ShadowTintData;
	}
	float GetTerrainShadowTintMask( SShadowTintData ShadowTintData, float3 ToLightDir, float ShadowTerm, float3 TerrainNormal )
	{
		float TerrainNdotL = saturate( dot( TerrainNormal, ToLightDir ) ) + 1e-5;
		float TerrainShadowTerm = smoothstep( MapSadowTintThresholdMin, MapSadowTintThresholdMax, TerrainNdotL );
		float FinalShadowTerm = saturate( 2 - TerrainShadowTerm - ShadowTerm );
		return ShadowTintData._MapSadowTintStrengthValue * FinalShadowTerm;
	}
	float3 ApplySunnyShadowTintWithClouds( float3 Color, float3 ShadowTintColor, float CloudMask, float ShadowTintMask, float SunnyMultiplier )
	{
		// Apply shadow tint
		float ShadowOutsideClouds = saturate( ShadowTintMask - CloudMask );
		Color = lerp( Color, ShadowTintColor, ShadowOutsideClouds * SunnyMultiplier );
		return Color;
	}

	float GetShadowTintMask( SShadowTintData ShadowTintData, float3 ToLightDir, float ShadowTerm, float3 TerrainNormal, float3 Normal )
	{
		float TerrainNdotL = saturate( dot( TerrainNormal, ToLightDir ) ) + 1e-5;
		float NdotL = saturate( dot( Normal, ToLightDir ) ) + 1e-5;

		float TerrainShadowTerm = smoothstep( MapSadowTintThresholdMin, MapSadowTintThresholdMax, TerrainNdotL );
		float ObjectShadowTerm = NdotL;
		float FinalShadowTerm = saturate( 3 - TerrainShadowTerm - ShadowTerm - ObjectShadowTerm);
		return ShadowTintData._MapSadowTintStrengthValue * FinalShadowTerm;
	}
]]