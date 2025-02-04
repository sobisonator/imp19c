Includes = {
	"jomini/jomini_river.fxh"
}

PixelShader =
{
	TextureSampler BottomDiffuse
	{
		Ref = JominiRiver0
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler BottomNormal
	{
		Ref = JominiRiver1
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler BottomProperties
	{
		Ref = JominiRiver2
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

	TextureSampler ShadowTexture
	{
		Ref = PdxShadowmap
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
		CompareFunction = less_equal
		SamplerType = "Compare"
	}

	VertexStruct PS_RIVER_BOTTOM_OUT
	{
		float4 Color		: PDX_COLOR0;
		float4 Blend		: PDX_COLOR0_SRC1;
	};
	
	Code
	[[
		void CalcParallaxedUvs( in VS_OUTPUT Input, in float3x3 TBN, out float2 WorldUV, out float2 TangentUV )
		{
			float3 ToCameraDir = normalize( CameraPosition - Input.WorldSpacePos );
			
			float3x3 InvTBN = transpose( TBN );
			float3 TangentSpaceToCameraDir = mul( ToCameraDir, InvTBN );
			
			float ParallaxScale = Input.Width;
			
			float2 TangentSpaceParallax;
			float2 WorldSpaceParallax;
			CalculateParallaxOffsetSteep( TangentSpaceToCameraDir, ToCameraDir, Input.UV, TangentSpaceParallax, WorldSpaceParallax );
			
			WorldUV = Input.WorldSpacePos.xz + WorldSpaceParallax * ParallaxScale;
			TangentUV = Input.UV + TangentSpaceParallax;
		}
		
		PS_RIVER_BOTTOM_OUT CalcRiverBottom( in VS_OUTPUT Input )
		{
			float3 Normal = normalize(Input.Normal);
			float3 Tangent = normalize(Input.Tangent);
			float3 Bitangent = normalize( cross( Normal, Tangent ) );
			float3x3 TBN = Create3x3( Tangent, Bitangent, Normal );
			
			// Parallax
			float2 WorldUV;
			float2 TangentUV;
			CalcParallaxedUvs( Input, TBN, WorldUV, TangentUV );
			
			// Fake some depth
			float UnderOceanFade = 1.0f - saturate( ( WaterHeight - Input.WorldSpacePos.y ) * UnderOceanFadeRate );
			float FadeOut = min( UnderOceanFade, Input.Transparency );
			
			float Depth = CalcDepth( TangentUV );
			float3 WorldSpacePos;
			WorldSpacePos.xz = WorldUV;
			WorldSpacePos.y = Input.WorldSpacePos.y - Depth * Input.Width * FadeOut;
			
			// Sampling
			float4 Diffuse = PdxTex2D( BottomDiffuse, WorldUV * 0.4 );
			float4 Properties = PdxTex2D( BottomProperties, WorldUV * 0.4 );
			float3 NormalSample = UnpackRRxGNormal( PdxTex2D( BottomNormal, WorldUV * 0.4 ) );
			
			// normals
			float SampleWidth = 0.1f;
			float2 DepthSampleOffset = float2( 0.0f, SampleWidth * 0.5f );
			float DepthDelta = ( CalcDepth( TangentUV - DepthSampleOffset ) - CalcDepth( TangentUV + DepthSampleOffset ) ) * UnderOceanFade;
			float Slope = DepthDelta / SampleWidth;
			float Angle = atan( Slope );
			float3 ParallaxNormal = float3( 0, -sin(Angle), cos(Angle) );				
			ParallaxNormal.xy += NormalSample.xy;				
			Normal = normalize( mul( ParallaxNormal, TBN ) );
			
			// lighting
			SMaterialProperties MaterialProps = GetMaterialProperties( Diffuse.rgb, Normal, Properties.a, Properties.g, Properties.b );
			SLightingProperties LightingProps = GetSunLightingProperties( WorldSpacePos, ShadowTexture );

			float3 Color = CalculateSunLighting( MaterialProps, LightingProps, EnvironmentMap );
			
			float FadeToConnection = saturate( ( Input.DistanceToMain - 0.6f * abs(Input.UV.y-0.5f) ) * 5.0f );
			float EdgeFade = saturate( Depth * 13.0f );
			float Alpha = FadeOut * FadeToConnection * EdgeFade;
			
			DebugReturn( Color, MaterialProps, LightingProps, EnvironmentMap );
			
			WorldSpacePos.y -= pow( Depth / MaxDepth, 2 ) * RiverBottomFakeDepthFactor * FadeOut;
			
			PS_RIVER_BOTTOM_OUT Out;
			Out.Color.rgb = Color;
			Out.Color.a = CompressWorldSpace( WorldSpacePos );
			Out.Blend = vec4(Alpha);
			return Out;		
		}
	]]
}

BlendState BlendState
{
	BlendEnable = yes
	SourceBlend = "src1_alpha"
	DestBlend = "inv_src1_alpha"
	SourceAlpha = "src1_alpha"
	DestAlpha = "inv_src1_alpha"
	WriteMask = "RED|GREEN|BLUE|ALPHA"
}

RasterizerState RasterizerState
{
	DepthBias = -50000
	#fillmode = wireframe
	#CullMode = none
}

DepthStencilState DepthStencilState
{
	DepthWriteEnable = no
}