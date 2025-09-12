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
				float2 UV = SettingsUV0ToFlag( Input.UV0 );
				float4 OutColor = SampleSpriteTexture( Texture, UV, 0 );
				float2 UV1 = SettingsUV1ToFlag( Input.UV0 );

				float4 AlphaColor = SampleSpriteTexture( ModifyTexture0, UV1, 1);
				OutColor = float4(OutColor.rgb, AlphaColor.a);

				float4 ShadowColor = SampleSpriteTexture( ModifyTexture1, UV1, 1 );
				OutColor = lerp(ShadowColor, OutColor, lerp(ShadowColor.a, OutColor.a, 1.0));

				float4 StyleColor = SampleSpriteTexture( ModifyTexture2, UV1, 1 );
				OutColor = CreateStyleToFlag( OutColor, AlphaColor.a, StyleColor, Input.UV0, Input.Position, GlobalTime);

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
