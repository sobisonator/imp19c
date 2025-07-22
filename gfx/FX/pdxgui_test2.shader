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
		Input = "VS_OUTPUT_PDX_GUI"
		Output = "PDX_COLOR"

		Code
		[[
			// float4 testfloat( PdxTextureSampler2D NewTexture, in float2 UV )
			// {
			// 	float4 Color = SampleImageSprite( NewTexture, UV );
			// 	return Color;
			// }
		]]

		Code
		[[
			PDX_MAIN
			{
				float2 UV = Input.UV0;
				float3 Position = Input.Position;
				float4 BaseColor = SampleImageSprite( Texture, UV );
				BaseColor *= Input.Color;
				float4 OutColor = BaseColor;
				float4 Noise = SampleImageSprite( ModifyTexture0, UV * 0.5 );
				Noise.a = lerp(0.0, 1.0, Noise.r);
				OutColor.a *= Noise.a;
				OutColor.a = lerp(OutColor.a, BaseColor.a, 0.7);
				// BaseColor.a = sm(0.0, 1.0, Noise.r);
				// UV *= ScreenDimension;
				// UV.x += WidgetSize.x;
				// OutColor = SampleImageSprite( ModifyTexture0, UV );
				float2 UV0 = UV;
				float2 UV1 = UV;
				float2 UV2 = UV;
				float2 UV3 = UV;

				float Test = SpriteSize.x / SpriteSize.y;
				float Test2 = SpriteSize.y / SpriteSize.x;

				float AR = SpriteSize.x / SpriteSize.y;
				float FixedSize = 1000 / SpriteSize.y;
			    float Offset = 0.5;

				UV0.x *= 1 + ((Offset/AR * 0.01 * FixedSize) * 2);
				UV0.y *= 1 + ((Offset * 0.01 * FixedSize) * 2);
				UV0.x -= (Offset/AR) * 0.01 * FixedSize;
				UV0.y -= Offset * 0.01 * FixedSize;
				float4 Color0 = SampleImageSprite( Texture, UV0 );

				// Color0.rgb = float3(0.0,0.5,0.0);
				Color0.rgb = BaseColor.rgb;
				Color0.a *= 0.9;
				OutColor = lerp(OutColor, Color0, lerp(OutColor.a, Color0.a, BaseColor.a));
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