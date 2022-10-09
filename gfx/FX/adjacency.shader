Includes = {
	"cw/shadow.fxh"
	"cw/water.fxh"
	"cw/camera.fxh"
	"cw/utility.fxh"
	"jomini/jomini_fog.fxh"
	"jomini/jomini_lighting.fxh"
	"fog_of_war.fxh"
	"constants.fxh"
	"standardfuncsgfx.fxh"
	"winter.fxh"
	"skybox.fxh"
}

PixelShader =
{
	TextureSampler DiffuseMap
	{
		Ref = PdxTexture0
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler NormalMap
	{
		Ref = PdxTexture1
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler MaterialMap
	{
		Ref = PdxTexture2
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
}


VertexStruct VS_INPUT
{
    float3  Position   		: POSITION;
	float	Opacity 		: TEXCOORD0;
	float2  UV				: TEXCOORD1;
	float3	Tangent 		: TEXCOORD2;
	float3	Normal			: TEXCOORD3;
};

VertexStruct VS_OUTPUT
{
    float4 Position	    	: PDX_POSITION;
	float2 UV			    : TEXCOORD0;
	float3 Tangent			: TEXCOORD1;
	float3 Normal			: TEXCOORD2;
	float3 WorldSpacePos	: TEXCOORD3;
	float  Opacity			: TEXCOORD4;
};


ConstantBuffer( 2 )
{
	float GlobalOpacity;
};

VertexShader =
{
	MainCode VertexShader
	{
		Input = "VS_INPUT"
		Output = "VS_OUTPUT"
		Code
		[[
			PDX_MAIN
			{
				VS_OUTPUT Out;

				Out.UV 				= Input.UV;
				Out.Tangent 		= Input.Tangent;
				Out.Normal			= Input.Normal;
				Out.WorldSpacePos 	= Input.Position;
				Out.Opacity 	= Input.Opacity;

				Out.Position = FixProjectionAndMul( ViewProjectionMatrix, float4( Input.Position, 1.0f ) );

				return Out;
			}
		]]
	}
}

PixelShader =
{
	MainCode PixelShader
	{
		Input = "VS_OUTPUT"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				float4 Diffuse = PdxTex2D( DiffuseMap, Input.UV );
				float4 Material = PdxTex2D( MaterialMap, Input.UV );
				float3 NormalSample = UnpackRRxGNormal( PdxTex2D( NormalMap, Input.UV ) );

				float3 Normal = normalize(Input.Normal);
				float3 Tangent = normalize(Input.Tangent);
				float3 Bitangent = normalize( cross( Normal, Tangent ) );
				float3x3 TBN = Create3x3( Tangent, Bitangent, Normal );
				Normal = normalize( mul( NormalSample, TBN ) );

				SMaterialProperties MaterialProps = GetMaterialProperties( Diffuse.rgb, Normal, Material.a, Material.g, Material.b );
				SLightingProperties LightingProps = GetSunLightingProperties( Input.WorldSpacePos, ShadowTexture );

				float3 Color = CalculateSunLighting( MaterialProps, LightingProps, EnvironmentMap );

				Color = ApplyFogOfWar( Color, Input.WorldSpacePos, FogOfWarAlpha );
				Color = ApplyDistanceFog( Color, Input.WorldSpacePos );

				DebugReturn( Color, MaterialProps, LightingProps, EnvironmentMap );

				Diffuse.a *= SKY_IsCameraTilted() ? 0.0f : Diffuse.a;

				float Opacity = Diffuse.a * Input.Opacity * GlobalOpacity;
				return float4( Color.rgb, Opacity );
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
	DepthBias = -50000
	#fillmode = wireframe
	#CullMode = none
}

DepthStencilState DepthStencilState
{
	DepthWriteEnable = no
}


Effect default
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
}
