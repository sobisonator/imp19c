Includes = {
	"jomini/jomini_gradient_borders.fxh"
	"fxhs/debug.fxh"
}

PixelShader =
{
	TextureSampler HeightmapToFlatmap
	{
		Index = 17
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		File = "gfx/map/flatmap/flatmap_heightmap.png"
		srgb = yes
	}
	TextureSampler RiversToFlatmap
	{
		Index = 18
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		File = "map_data/rivers.png"
		srgb = yes
	}
	TextureSampler LakesToFlatmap
	{
		Index = 19
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		File = "gfx/map/flatmap/flatmap_lakes.png"
		srgb = yes
	}
	TextureSampler BordersToFlatmap
	{
		Index = 20
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		File = "gfx/map/flatmap/flatmap_borders.png"
		srgb = yes
	}
	TextureSampler SymbolsToFlatmap
	{
		Index = 21
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		File = "gfx/map/flatmap/flatmap_decorations.png"
		srgb = yes
	}
	TextureSampler GroundToFlatmap
	{
		Index = 24
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		File = "gfx/map/flatmap/flatmap_ground.png"
		srgb = yes
	}
	TextureSampler WaterToFlatmap
	{
		Index = 25
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		File = "gfx/map/flatmap/flatmap_water.png"
		srgb = yes
	}
	TextureSampler BorderToFlatmap
	{
		Index = 26
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		File = "gfx/map/flatmap/flatmap_border.png"
		srgb = yes
	}


	Code
	[[
		float3 ApplyGradientBorderColor( in float3 BaseColor, inout float3 BorderColor, in float BlendAmount )
		{
			float Brightness = saturate( dot( BaseColor, float3( 0.2125, 0.7154, 0.0721 ) ) );
			float Mask = ( 1.0f - Brightness );
			
			BorderColor = RGBtoHSV( BorderColor );
			BorderColor.y *= 0.88f;
			BorderColor = HSVtoRGB( BorderColor );
			
			float3 Combined = lerp( BaseColor, BorderColor, Mask );
			float3 SoftLight = Combined + BaseColor * ( 1.0f - ((1.0f-BaseColor)*(1.0f-BorderColor)) - Combined );
			
			return lerp( BaseColor, SoftLight, BlendAmount );
		}

		void ApplyTerrainColor( inout float3 Diffuse, inout float3 FlatMap, inout float3 BorderColor, out float BorderPostLightingBlend, in float2 ColorMapCoords )
		{
			float BorderPreLightingBlend;
			GetBorderColorAndBlend( ColorMapCoords, BorderColor, BorderPreLightingBlend, BorderPostLightingBlend );
			if ( DEBUG != 1.0 )
			{
				Diffuse = ApplyGradientBorderColor( Diffuse, BorderColor, BorderPreLightingBlend );
			}
			#ifdef TERRAIN_FLAT_MAP_LERP
				FlatMap = lerp( FlatMap, BorderColor, saturate( BorderPreLightingBlend + BorderPostLightingBlend ) );
			#endif
		}

		float4 MixLayer(float Value, float Color)
		{
			float MinValue = Value;
			float MaxValue = MinValue + 1.0;
			float Min = (MinValue / 255.0) * 0.1;
			float Max = (MaxValue / 255.0) * 0.1;
			float Alpha = smoothstep(Min, Max, clamp(Color, Min, Max));
			return Alpha;
		}
		float4 MixLayerWater(float MinValue, float MaxValue, float Color)
		{
			float Min = (MinValue / 255.0) * 0.1;
			float Max = (MaxValue / 255.0) * 0.1;
			float Alpha = smoothstep(Min, Max, clamp(Color, Min, Max));
			return Alpha;
		}
		float4 FlatTerrainShader( in float3 WorldSpacePos, in float2 ColorMapCoords )
		{	
			// float3 FlatMap = PdxTex2D( FlatMapTex, float2( ColorMapCoords.x, 1.0 - ColorMapCoords.y ) ).rgb;

			float2 UV = float2( ColorMapCoords.x, 1.0 - ColorMapCoords.y );
			float4 Color = PdxTex2D( HeightmapToFlatmap, UV );

			// float3 GroundColor = float3( 0.824, 0.769, 0.663 );
			float3 GroundColor = PdxTex2D( GroundToFlatmap, UV ).rgb;
			// float3 WaterColor = float3( 0.761, 0.765, 0.682 );
			float3 WaterColor = PdxTex2D( WaterToFlatmap, UV ).rgb;
			// float3 BorderColor = float3( 0.239, 0.212, 0.169 );
			float3 BorderColor = PdxTex2D( BorderToFlatmap, UV ).rgb;

			float BaseValue = 42.0;

			float4 FinalColor = float4( 0.0, 0.0, 0.0, 1.0 );
			float BaseAlpha = MixLayer(BaseValue, Color.r);

			// Dots
			float DotsTile = 20000.0;
			float2 DotsUV = UV;
			DotsUV.x *= 2.0;
			float2 oo =  sin(DotsUV*DotsTile + float2(0.0,10.0))*0.5 + 0.5;
			float doo = smoothstep(0.2, 0.8, 1.0 - dot(oo, float2(1.0,1.0)));
			float3 DotsColor = PdxTex2D(GroundToFlatmap, DotsUV).rgb * doo;
			float DotsAlpha = DotsColor.r;

			// Ground Gradient
			float Step = 40.0;
			float StartStep = 2.0;
			float BaseAlphaLayer01 = 0.0;
			float BaseAlphaLayer02 = 0.0;
			float3 BaseAlphaLayer03 = (0.0, 0.0, 0.0);
			float3 BaseAlphaLayerFinish = GroundColor;

			for (float i = StartStep; i < 64; i++ ) {
				BaseAlphaLayer01 = MixLayer(i * Step, Color.r);
				BaseAlphaLayer02 = MixLayer( (i * Step) + (Step * 0.5), Color.r);
				BaseAlphaLayer03 = lerp(GroundColor * 1.75, BorderColor, BaseAlphaLayer01 - BaseAlphaLayer02);
				BaseAlphaLayerFinish = lerp(BaseAlphaLayerFinish, BaseAlphaLayer03, BaseAlphaLayer01 * 0.05);
			}
			float3 BaseGround = lerp(GroundColor, BaseAlphaLayerFinish, MixLayer(StartStep * Step, Color.r));

			// Lakes
			float LakeAlpha = PdxTex2D( LakesToFlatmap, UV ).r;
			BaseAlpha = BaseAlpha - LakeAlpha;

			// Rivers
			float3 RiverColor = PdxTex2D( RiversToFlatmap, UV ).rgb;
			float3 RiverBase = float3(1.0, 1.0, 1.0) - RiverColor;
			float RiverAlpha = (RiverBase.r + RiverBase.g + RiverBase.b) * 0.5;
			FinalColor = lerp(float4( BaseGround, 1.0 ), float4( lerp(GroundColor, BorderColor, 0.5), 1.0 ), (1.0 - BaseAlpha) + RiverAlpha );

			FinalColor = lerp(float4( GroundColor, 1.0 ), float4( FinalColor.rgb, 1.0 ), BaseAlpha );

			// Borders
			float4 Borders = PdxTex2D( BordersToFlatmap, UV );
			Borders.a = smoothstep(0.0, 1.0, Borders.r + Borders.g + Borders.b);
			Borders = float4( BorderColor, Borders.a );
			FinalColor = lerp(float4( FinalColor.rgb, 1.0 ), float4( Borders.rgb, 1.0 ), Borders.a );

			// Ground ColorOverlay
			#ifdef TERRAIN_COLOR_OVERLAY
				float3 ColorOverlay;
				float PreLightingBlend;
				float PostLightingBlend;
				GetBorderColorAndBlend( ColorMapCoords, ColorOverlay, PreLightingBlend, PostLightingBlend );
				FinalColor.rgb = lerp( FinalColor.rgb, ColorOverlay, saturate( PreLightingBlend + PostLightingBlend ) );

				float4 HighlightColor = BilinearColorSampleAtOffset( ColorMapCoords, IndirectionMapSize, InvIndirectionMapSize, ProvinceColorIndirectionTexture, ProvinceColorTexture, HighlightProvinceColorsOffset );
				FinalColor.rgb = lerp( FinalColor.rgb, HighlightColor.rgb, HighlightColor.a );
				FinalColor.rgb = lerp( FinalColor.rgb, BorderColor.rgb, Borders.a * 0.5 );
			#endif

			// Water
			float3 WaterBase = WaterColor;
			float WaterLayer01 = MixLayer(35.0, Color.r) * 0.02;
			float WaterLayer02 = MixLayer(20.0, Color.r) * 0.02;
			float WaterLayer03 = MixLayer(5.0, Color.r) * 0.02;
			WaterBase = WaterBase + WaterLayer01;
			WaterBase = WaterBase + WaterLayer02;
			WaterBase = WaterBase + WaterLayer03;

			// Water Gradient
			float WaterLayerGradient = MixLayerWater(5.0, BaseValue, Color.r); 
			WaterLayerGradient = lerp(float3(0.0,0.0,0.0), DotsAlpha, WaterLayerGradient);
			WaterBase = lerp(float4( WaterBase, 1.0 ), float4( WaterBase * 0.9, 1.0 ), lerp(WaterLayerGradient, WaterLayerGradient * 2.0, WaterLayerGradient) );

			// Water ColorOverlay
			#ifdef TERRAIN_COLOR_OVERLAY
				float3 WaterColorOverlay = lerp(WaterBase, ColorOverlay, saturate( PreLightingBlend + PostLightingBlend ) - MixLayerWater(0.0, BaseValue, Color.r) );
				WaterBase = lerp(WaterBase, WaterColorOverlay, (1.0 - MixLayerWater(0.0, BaseValue, Color.r)) * 0.5 );
			#endif

			// Water + Ground
			FinalColor = lerp(float4( WaterBase, 1.0 ), float4( FinalColor.rgb, 1.0 ), BaseAlpha );

			// Decorations
			float4 Symbols = PdxTex2D( SymbolsToFlatmap, UV );
			Symbols.a = smoothstep(0.0, 1.0, Symbols.r + Symbols.g + Symbols.b);
			Symbols = float4( BorderColor, Symbols.a );
			FinalColor = lerp(float4( FinalColor.rgb, 1.0 ), float4( Symbols.rgb, 1.0 ), Symbols.a );

			#ifdef TERRAIN_DEBUG
				TerrainDebug( FinalColor, WorldSpacePos );
			#endif

			// DebugReturn( FinalColor, lightingProperties, ShadowTerm );
			return float4( FinalColor.rgb, 1 );
		}
	]]
}
