Code
[[
	// Apply shadow tint for terrain using terrain lighting directions
	float3 ApplyTerrainShadowTintWithClouds( float3 Color, float2 WorldPosition, float CloudMask, float ShadowTerm, float3 Normal, float3 TerrainNormal )
	{
		#ifdef LOW_SPEC_SHADERS
			return Color;
		#endif

		// Calculate terrain-specific values
		float3 ToLightDir = ToSunDir;
		float2 ColorMapCoords = WorldPosition * WorldSpaceToTerrain0To1;
		SShadowTintData ShadowTintData = GetShadowTintData( ColorMapCoords );

		// Calculate shadow tint mask for terrain
		float ShadowTintMask = GetTerrainShadowTintMask( ShadowTintData, ToLightDir, ShadowTerm, Normal );
		float DiffuseShadowTintMask = GetTerrainShadowTintMask( ShadowTintData, ToLightDir, ShadowTerm, TerrainNormal );

		Color = ApplySunnyShadowTintWithClouds( Color, ShadowTintData._TintColor.rgb, CloudMask, ShadowTintMask, 1.0f );

		float BlendAmount = DiffuseShadowTintMask * CloudMask;

		Color = ApplyOvercastContrast( Color, BlendAmount );

		return Color;
	}

	float3 ApplyTerrainShadowTintWithClouds( float3 Color, float2 WorldPosition, float CloudMask, float ShadowTerm )
	{
		#ifdef LOW_SPEC_SHADERS
			return Color;
		#endif

		float3 TerrainNormal = CalculateNormal( WorldPosition );
		return ApplyTerrainShadowTintWithClouds( Color, WorldPosition, CloudMask, ShadowTerm, TerrainNormal, TerrainNormal );
	}

	// Apply shadow tint for map objects using map objects lighting directions
	float3 ApplyMapObjectsShadowTintWithClouds( float3 Color, float2 ColorMapCoords, float CloudMask, float ShadowTerm, float3 ObjectNormal, float3 TerrainNormal )
	{
		#ifdef LOW_SPEC_SHADERS
			return Color;
		#endif

		// Calculate map objects-specific values
		float3 ToLightDir = ToSunDir;

		SShadowTintData ShadowTintData = GetShadowTintData( ColorMapCoords );
		// Calculate shadow tint mask for map objects (uses both terrain and object normals)
		float ShadowTintMask = GetShadowTintMask( ShadowTintData, ToLightDir, ShadowTerm, TerrainNormal, ObjectNormal );

		return ApplySunnyShadowTintWithClouds( Color, ShadowTintData._TintColor.rgb, CloudMask, ShadowTintMask, 1.0f );
	}

	float3 ApplyTreeShadowTintWithClouds( float3 Color, SShadowTintData ShadowTintData, float CloudMask, float ShadowTerm, float3 ObjectNormal, float3 TerrainNormal )
	{
		#ifdef LOW_SPEC_SHADERS
			return Color;
		#endif

		// Calculate terrain-specific values
		float3 ToLightDir = ToSunDir;
		// Calculate shadow tint mask for terrain
		float ShadowTintMask = GetShadowTintMask( ShadowTintData, ToLightDir, ShadowTerm, TerrainNormal, ObjectNormal );
		float DiffuseShadowTintMask = GetTerrainShadowTintMask( ShadowTintData, ToLightDir, ShadowTerm, TerrainNormal );

		Color = ApplySunnyShadowTintWithClouds( Color, ShadowTintData._TintColor.rgb, CloudMask, ShadowTintMask, 1.0f );

		float BlendAmount = DiffuseShadowTintMask * CloudMask;

		Color = ApplyOvercastContrast( Color, BlendAmount );

		return Color;
	}
]]
