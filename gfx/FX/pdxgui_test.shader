Includes = {
	"cw/pdxgui.fxh"
	"cw/pdxgui_sprite.fxh"
	"standardfuncsgfx.fxh"
}


VertexShader =
{
	MainCode VertexShader
	{
		Input = "VS_INPUT_PDX_GUI"
		Output = "VS_OUTPUT_PDX_GUI"
		Code
		[[
			PDX_MAIN
			{
				return PdxGuiDefaultVertexShader( Input );
			}
		]]
	}
}


PixelShader =
{
	MainCode PixelShader
	{
		TextureSampler Texture
		{
			Ref = PdxTexture0
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			SampleModeU = "Clamp"
			SampleModeV = "Clamp"
		}
	
		Input = "VS_OUTPUT_PDX_GUI"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				float4 OutColor = SampleImageSprite( Texture, Input.UV0 );
				OutColor *= Input.Color;
				
				#ifdef DISABLED
					OutColor.rgb = DisableColor( OutColor.rgb );
				#endif

			    return OutColor;
			}
		]]
	}

	MainCode test_PixelShader
	{
		TextureSampler Texture
		{
			Ref = PdxTexture0
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			SampleModeU = "Clamp"
			SampleModeV = "Clamp"
		}
		TextureSampler BarqueTexture
		{
			Ref = PdxTexture1
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			SampleModeU = "Clamp"
			SampleModeV = "Clamp"
			File = "gfx/interface/images/test/barque.png"
			srgb = yes
		}
		TextureSampler WaterAlphaTexture
		{
			Ref = PdxTexture2
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			SampleModeU = "Clamp"
			SampleModeV = "Clamp"
			File = "gfx/interface/images/test/water_alpha.png"
			srgb = yes
		}
		TextureSampler FogAlphaTexture
		{
			Ref = PdxTexture3
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			SampleModeU = "Clamp"
			SampleModeV = "Clamp"
			File = "gfx/interface/images/test/fog_alpha.png"
			srgb = yes
		}
		TextureSampler NoiseTexture
		{
			Ref = PdxTexture4
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			SampleModeU = "Wrap"
			SampleModeV = "Wrap"
			File = "gfx/interface/images/test/noise.png"
			srgb = yes
		}
		Input = "VS_OUTPUT_PDX_GUI"
		Output = "PDX_COLOR"

		Code
		[[
			// float4 testfloat( PdxTextureSampler2D NewTexture, in float2 UV )
			// {
			// 	float4 Color = SampleImageSprite( NewTexture, UV );
			// 	return Color;
			// }
			float4 MixImages( in float4 Texture01, in float4 Texture02 )
			{
				float4 Color = lerp(Texture01, Texture02, lerp(Texture01.a, Texture02.a, 1.0));
				return Color;
			}
			float2 rotateUV(float2 uv, float rotation)
			{
			    return float2(
			        cos(rotation) * uv.x + sin(rotation) * uv.y,
			        cos(rotation) * uv.y - sin(rotation) * uv.x
			    );
			}

		]]

		Code
		[[
			PDX_MAIN
			{
				float2 UV = Input.UV0;
				float4 BaseColor = SampleImageSprite( Texture, UV );
				float4 OutColor = BaseColor;
				// OutColor = float4( OutColor.rgb, 1.0f );
				// BaseColor = float4( BaseColor.rgb, 1.0f );
				OutColor *= Input.Color;

			    float iTime = GlobalTime * -2.0;
			    float WaveSize = 12.0;
			    float Scale = 1.2;
			    float2 Wave = sin((UV.x+iTime*0.1) * WaveSize) * 0.02;
				float2 UV0 = UV;
				UV0.x *= 2 * Scale;
				UV0.y += -0.02 * Scale;
				UV0.x += -0.5 * Scale;
				UV0.y += sin((iTime*0.1) * WaveSize) * 0.02;

				float2 halfSize = float2( UV0.x * 1.0, UV0.y * 0.5 );
				UV0 -= halfSize;

				UV0 = rotateUV(UV0, sin((iTime*0.1) * WaveSize) * 0.02);
				UV0 += halfSize;

				float4 Barque = SampleImageSprite( BarqueTexture, UV0 );

				OutColor = MixImages( OutColor, Barque );

				float4 DownFogAlpha = SampleImageSprite( FogAlphaTexture, float3(UV.x, (UV.y - 0.45) + Wave) );
				float4 DownFogColor = float4( 1.0f, 1.0f, 1.0f, DownFogAlpha.a * 0.5 );

				OutColor = MixImages( OutColor, DownFogColor );

				float2 UV1 = UV;
				// UV1 *= 0.1;
				UV1.x += iTime * 0.01;
				float4 UpFog = SampleImageSprite( NoiseTexture, UV1 );
				UpFog.a = lerp(0.0, 1.0, UpFog.r);
				UpFog.a *= 0.5;
				float4 UpFogColor = float4( 1.0f, 1.0f, 1.0f, UpFog.a );

				OutColor = MixImages( OutColor, UpFogColor );

				float4 WaterAlpha = SampleImageSprite( WaterAlphaTexture, float3(UV.x, (UV.y - 0.45) + Wave) );
				float4 WaterColor = float4( 1.0f, 1.0f, 1.0f, WaterAlpha.a );

				OutColor = MixImages( OutColor, WaterColor );

				// OutColor = float4( OutColor.rgb, 1.0f );
				OutColor = float4( OutColor.rgb, BaseColor.a );
			    return OutColor;
			}
		]]
	}
}


BlendState BlendState
{
	BlendEnable = yes
	SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
}

BlendState BlendStateNoAlpha
{
	BlendEnable = no
}

BlendState PreMultipliedAlpha
{
	BlendEnable = yes
	SourceBlend = "ONE"
	DestBlend = "INV_SRC_ALPHA"
}

DepthStencilState DepthStencilState
{
	DepthEnable = no
}


Effect PdxGuiDefault
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
}
Effect PdxGuiDefaultDisabled
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	
	Defines = { "DISABLED" }
}

Effect test_PixelShader
{
	VertexShader = "VertexShader"
	PixelShader = "test_PixelShader"
}
Effect test_PixelShaderDisabled
{
	VertexShader = "VertexShader"
	PixelShader = "test_PixelShader"
	
	Defines = { "DISABLED" }
}