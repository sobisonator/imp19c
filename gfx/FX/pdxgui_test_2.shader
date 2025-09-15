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
				float2 UV = Input.UV0;
				// float4 BaseColor = SampleImageSprite( Texture, UV );
				// float4 OutColor = BaseColor;
				// OutColor *= Input.Color;

			    //Screen resolution
			    float2 res = float2(1.0, 0.8);
			    //Pixel coordinates centered in the middle of the screen
			    // float2 pos = Input.UV0;
			    float2 pos = Input.UV0 - res*0.5;
			    //Perspective ratio
			    float ratio = -0.085;
			    //Compute uv coordinates with perspective ratio
			    UV = pos / (res - pos * ratio).y + 0.5;
			    // float coeff = -0.02;
			    
			    // UV *= 1.1;
			    // UV -= 0.05;
				// UV.x /= (1.0 - UV.y * coeff);
			    // UV.y /= (1.0 - UV.y * coeff);

			    float4 OutColor = SampleImageSprite(Texture, UV);
			    // float4 OutColor2 = SampleSpriteTexture(ModifyTexture0, UV, 1);
			    // OutColor.a = OutColor2.a;
			    OutColor *= Input.Color;
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