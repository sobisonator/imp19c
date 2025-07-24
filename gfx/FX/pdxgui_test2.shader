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
				// float4 Noise = SampleImageSprite( ModifyTexture0, UV * 0.5 );
				// Noise.a = lerp(0.0, 1.0, Noise.r);
				// OutColor.a *= Noise.a;
				// OutColor.a = lerp(OutColor.a, BaseColor.a, 0.7);
				// float2 UV0 = UV;
				// float2 UV1 = UV;
				// float2 UV2 = UV;
				// float2 UV3 = UV;

				// float Test = SpriteSize.x / SpriteSize.y;
				// float Test2 = SpriteSize.y / SpriteSize.x;

				// float AR = SpriteSize.x / SpriteSize.y;
				// float FixedSize = 1000 / SpriteSize.y;
			    // float Offset = 0.5;

				// UV0.x *= 1 + ((Offset/AR * 0.01 * FixedSize) * 2);
				// UV0.y *= 1 + ((Offset * 0.01 * FixedSize) * 2);
				// UV0.x -= (Offset/AR) * 0.01 * FixedSize;
				// UV0.y -= Offset * 0.01 * FixedSize;
				// float4 Color0 = SampleImageSprite( Texture, UV0 );

				// // Color0.rgb = float3(0.0,0.5,0.0);
				// Color0.rgb = BaseColor.rgb;
				// Color0.a *= 0.9;
				// OutColor = lerp(OutColor, Color0, lerp(OutColor.a, Color0.a, BaseColor.a));
			    return OutColor;
			}
		]]
	}

	MainCode test2_PixelShader
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
			float4 CreateShadow( PdxTextureSampler2D NewTexture, in float2 UV, in float Directions, in float Quality, in float2 Radius )
			{
				float4 Color = SampleImageSprite( NewTexture, UV );

				float Pi = 6.28318530718; // Pi*2

			    for( float d=0.0; d<Pi; d+=Pi/Directions)
			    {
					for(float i=1.0/Quality; i<=1.0; i+=1.0/Quality)
			        {
						Color += SampleImageSprite( Texture, UV+float2(cos(d),sin(d))*Radius*i);		
			        }
			    }

			    Color /= Quality * Directions - 15.0;
				return Color;
			}
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

			    float Directions = 16.0; // BLUR DIRECTIONS (Default 16.0 - More is better but slower)
			    float Quality = 3.0; // BLUR QUALITY (Default 4.0 - More is better but slower)
			    float Size = 8.0; // BLUR SIZE (Radius)
			    float2 Radius = Size/SpriteSize.xy;
			    float3 ShadowColor = float3(0.0, 0.0, 0.0);

			    float4 ShadowOutline = CreateShadow(Texture, UV0, Directions, Quality, Radius);
			    ShadowOutline = float4(ShadowColor, ShadowOutline.a);

			    // OutColor *= Input.Color;
			    OutColor.rgb *= 0.9;
				Color0 = lerp(ShadowOutline, Color0, lerp(ShadowOutline.a, Color0.a, BaseColor.a));
				OutColor = lerp(OutColor, Color0, lerp(OutColor.a, Color0.a, BaseColor.a));
				OutColor.a = BaseColor.a;
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

Effect test2_PixelShader
{
	VertexShader = "VertexShader"
	PixelShader = "test2_PixelShader"
}
Effect test2_PixelShaderDisabled
{
	VertexShader = "VertexShader"
	PixelShader = "test2_PixelShader"
	
	Defines = { "DISABLED" }
}