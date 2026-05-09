Includes = {
	"coat_of_arms/coat_of_arms.fxh"
}

ConstantBuffer( CoatOfArmsTexturedEmblemConstants )
{
	float2	EmblemOffset;
	float2	EmblemSize;
	float3	MaskColor;
	float	Rotation;
	float	Depth;
}

ConstantBuffer( CoatOfArmsColoredEmblemConstants )
{
	float4 Color1;
	float4 Color2;
	float4 Color3;
}

VertexShader = {
	MainCode VertexShaderCOAEmblem
	{
		Input = "VS_INPUT_COA_ATLAS"
		Output = "VS_OUTPUT_COA_ATLAS"
		Code
		[[
			PDX_MAIN
			{
				return COAEmblemVertexShader( Input );
			}
		]]
	}
}

VertexStruct VS_OUTPUT_COA_ATLAS
{
    float4 position			: PDX_POSITION;
	float2 uvEmblem			: TEXCOORD0;
	float2 uvPattern		: TEXCOORD1;
};

VertexShader = {
	VertexStruct VS_INPUT_COA_ATLAS
	{
		float2 position	: POSITION;
	};

	Code
	[[
		VS_OUTPUT_COA_ATLAS COAEmblemVertexShader( VS_INPUT_COA_ATLAS Input )
		{
			VS_OUTPUT_COA_ATLAS VertexOut;
			VertexOut.position = float4( Input.position, Depth, 1.0 );
			VertexOut.uvEmblem.x = VertexOut.position.x > -1 ? 1 : 0;
			VertexOut.uvEmblem.y = VertexOut.position.y < 1 ? 1 : 0;
			
			
			if ( EmblemSize.x < 0 )
				VertexOut.uvEmblem.x *= -1;
			if ( EmblemSize.y < 0 )
				VertexOut.uvEmblem.y *= -1;

			// Rotate
			float2 vSinCos;
			sincos( Rotation, vSinCos.x, vSinCos.y );
			VertexOut.position.xy = float2( vSinCos.y * VertexOut.position.x - vSinCos.x * VertexOut.position.y, 
												vSinCos.x * VertexOut.position.x + vSinCos.y * VertexOut.position.y	);
			// Convert to [0,1]
			VertexOut.position.x = VertexOut.position.x * 0.5 + 0.5;
			VertexOut.position.y = 1 - (VertexOut.position.y * 0.5 + 0.5);
			float EmblemWidth = abs( EmblemSize.x );
			float EmblemHeight = abs( EmblemSize.y );
			// Resize
			VertexOut.position.x *= EmblemWidth;
			VertexOut.position.y *= EmblemHeight;
			// Offset
			VertexOut.position.x += ( EmblemOffset.x - EmblemWidth / 2 );
			VertexOut.position.y += ( EmblemOffset.y - EmblemHeight / 2 );
			
			VertexOut.uvPattern.x = VertexOut.position.x;
			VertexOut.uvPattern.y = VertexOut.position.y;
		
			// Convert back to [-1,1]
			VertexOut.position.x = VertexOut.position.x * 2 - 1;
			VertexOut.position.y = -1 * (VertexOut.position.y * 2 - 1);

		
			// VertexOut.position.xy += TileOffset;

			return VertexOut;
		}
	]]
}

TextureSampler PatternMap
{
	Ref = JominiPatternMap
	MagFilter = "Linear"
	MinFilter = "Linear"
	MipFilter = "Linear"
	SampleModeU = "Wrap"
	SampleModeV = "Wrap"
}

PixelShader =
{
	TextureSampler EmblemMap
	{
		Ref = JominiEmblemTexture
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	Code
	[[
		float4 Emblem( VS_OUTPUT_COA_ATLAS Input, float4 EmblemTex )
		{
			float4 OutColor = EmblemTex;
			
		#ifdef USE_PATTERN_MASK
			
			// Mask using the pattern
			float4 PatternColor = PdxTex2D( PatternMap, Input.uvPattern );
			PatternColor.r = clamp( PatternColor.r - PatternColor.g - PatternColor.b, 0.0, 1.0 );
			PatternColor.g = clamp( PatternColor.g - PatternColor.b, 0.0, 1.0 );
			float3 masked = PatternColor.rgb * MaskColor.xyz;
			float t = saturate( masked.r + masked.g + masked.b );

			OutColor.a *= t;
		
		#endif
			
		#ifdef COLORED_EMBLEM		

			OutColor.rgb = Color1.rgb;     
			OutColor.rgb = lerp( OutColor.rgb, Color2.rgb, EmblemTex.g );
			OutColor.rgb = lerp( OutColor.rgb, Color3.rgb, EmblemTex.r );

			// Use overlay to get some values variation
			OutColor.rgb = GetOverlay( OutColor.rgb, EmblemTex.bbb, 1.0 );

		#endif
		
			return OutColor;
		}
		float4 Emblem( VS_OUTPUT_COA_ATLAS Input )
		{
			return Emblem( Input, PdxTex2D( EmblemMap, Input.uvEmblem ) );
		}
	]]
}

BlendState BlendState
{
	BlendEnable = yes
	SourceBlend = "src_alpha"
	DestBlend = "inv_src_alpha"
	WriteMask = "RED|GREEN|BLUE"
}