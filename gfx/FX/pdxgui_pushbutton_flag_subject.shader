Includes = {
	"cw/pdxgui.fxh"
	"cw/pdxgui_sprite.fxh"
	"standardfuncsgfx.fxh"
	"gui_flags.fxh"
}


ConstantBuffer( PdxConstantBuffer2 )
{
	float3 HighlightColor;
};


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
	TextureSampler Texture
	{
		Ref = PdxTexture0
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
	}
	
	MainCode PixelShader
	{
		Input = "VS_OUTPUT_PDX_GUI"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				float Time = GlobalTime * -1 * 0.5;
				float WaveSize = 12.0;
				float2 UV = Input.UV0;

				UV *= 2.0;
				UV.y-= 0.05;
				float2 Wave = sin((Input.UV0.x + Time * 0.1) * WaveSize) * 0.03 * 2;
				float4 OutColor = SampleSpriteTexture( Texture, float3(UV.x, UV.y + Wave), 0 );

				float2 UV2 = Input.UV0;
				UV2.x *= 0.5;
				UV2.x += 1.5 - SpriteFramesTypeBlendMode[3].x;
				UV2.y*=1.1;
				UV2.y-= 0.05;
				Wave = sin((Input.UV0.x + Time * 0.1) * WaveSize) * 0.03;

				float4 AlphaColor = SampleSpriteTexture( ModifyTexture0, float3(UV2.x, UV2.y + Wave), 1);
				OutColor = float4(OutColor.rgb, AlphaColor.a);

				float4 StyleColor = SampleSpriteTexture( ModifyTexture1, float3(UV2.x, UV2.y + Wave), 1 );
				OutColor = CreateStyleToFlag( OutColor, AlphaColor.a, StyleColor, Input.UV0, Input.Position, GlobalTime);
				OutColor = float4(OutColor.rgb, AlphaColor.a);

				#ifndef NO_HIGHLIGHT
					OutColor.rgb += HighlightColor;
				#endif
				
				#ifdef DISABLED
					OutColor.rgb = DisableColor( OutColor.rgb );
				#endif
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

DepthStencilState DepthStencilState
{
	DepthEnable = no
}


Effect Up
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
}

Effect Over
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
}

Effect Down
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
}

Effect Disabled
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	
	Defines = { "DISABLED" }
}


Effect NoHighlightUp
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	
	Defines = { "NO_HIGHLIGHT" }
}

Effect NoHighlightOver
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	
	Defines = { "NO_HIGHLIGHT" }
}

Effect NoHighlightDown
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	
	Defines = { "NO_HIGHLIGHT" }
}

Effect NoHighlightDisabled
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	
	Defines = { "DISABLED" "NO_HIGHLIGHT" }
}

Effect GreyedOutUp
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	Defines = { "DISABLED" }
}

Effect GreyedOutOver
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	Defines = { "DISABLED" }
}

Effect GreyedOutDown
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	Defines = { "DISABLED" }
}

Effect GreyedOutDisabled
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	
	Defines = { "DISABLED" "NO_HIGHLIGHT" }
}
