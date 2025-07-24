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

	MainCode blur_PixelShader
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

		]]

		Code
		[[
			PDX_MAIN
			{
				float2 UV = Input.UV0;
				float4 OutColor = SampleImageSprite( Texture, UV );
				OutColor *= Input.Color;

				float Pi = 6.28318530718; // Pi*2
			    float Directions = 16.0; // BLUR DIRECTIONS (Default 16.0 - More is better but slower)
			    float Quality = 3.0; // BLUR QUALITY (Default 4.0 - More is better but slower)
			    float Size = 8.0; // BLUR SIZE (Radius)

			    float2 Radius = Size/SpriteSize.xy;

			    OutColor = SampleImageSprite(Texture, UV);

			    // Blur calculations
			    for( float d=0.0; d<Pi; d+=Pi/Directions)
			    {
					for(float i=1.0/Quality; i<=1.0; i+=1.0/Quality)
			        {
						OutColor += SampleImageSprite( Texture, UV+float2(cos(d),sin(d))*Radius*i);		
			        }
			    }
			    
			    // Output to screen
			    OutColor /= Quality * Directions - 15.0;
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

Effect blur_PixelShader
{
	VertexShader = "VertexShader"
	PixelShader = "blur_PixelShader"
}
Effect blur_PixelShaderDisabled
{
	VertexShader = "VertexShader"
	PixelShader = "blur_PixelShader"
	
	Defines = { "DISABLED" }
}