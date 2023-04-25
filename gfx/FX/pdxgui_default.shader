Includes = {
	"cw/pdxgui.fxh"
	"cw/pdxgui_sprite.fxh"
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

	MainCode ProfilerGraphVertexShader
	{
		Input = "VS_INPUT_PDX_GUI_PROFILER"
		Output = "VS_OUTPUT_PDX_GUI"
		Code
		[[
			PDX_MAIN
			{
				VS_OUTPUT_PDX_GUI Out;
				float2 PixelPos = WidgetLeftTop + Input.LeftTop_WidthHeight.xy + Input.Position * Input.LeftTop_WidthHeight.zw;
				Out.Position = PixelToScreenSpace( PixelPos );

				float2 UV = float2( 0.0, 0.0 );
				if ( Input.VertexID == 0 )
				{
					UV = float2( 1.0, 0.0 );
				}
				else if ( Input.VertexID == 1 )
				{
					UV = float2( 1.0, 1.0 );
				}
				else if ( Input.VertexID == 2 )
				{
					UV = float2( 0.0, 0.0 );
				}
				else if ( Input.VertexID == 3 )
				{
					UV = float2( 0.0, 1.0 );
				}

				Out.UV0 = Input.UVLeftTop_WidthHeight.xy + UV * Input.UVLeftTop_WidthHeight.zw;
				Out.Color = Input.Color;
				return Out;
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

				#ifdef gui_zero_seven 
					OutColor.rgb *= 0.7;
				#endif

				#ifdef gui_zero_eight
					OutColor.rgb *= 0.8;
				#endif

				#ifdef gui_zero_nine 
					OutColor.rgb *= 0.9;
				#endif

				#ifdef gui_one_one 
					OutColor.rgb *= 1.1;
				#endif

				#ifdef gui_one_two 
					OutColor.rgb *= 1.2;
				#endif

			    return OutColor;
			}
		]]
	}

	MainCode ProfilerGraphPixelShader
	{
		TextureSampler Texture
		{
			Ref = PdxTexture0
			MagFilter = "Point"
			MinFilter = "Point"
			MipFilter = "Point"
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

Effect PdxGuiDefaultNoAlpha
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	BlendState = BlendStateNoAlpha
}
Effect PdxGuiDefaultNoAlphaDisabled
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	BlendState = BlendStateNoAlpha
	
	Defines = { "DISABLED" }
}

Effect PdxGuiPreMultipliedAlpha
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	BlendState = PreMultipliedAlpha
}
Effect PdxGuiPreMultipliedAlphaDisabled
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	BlendState = PreMultipliedAlpha
	
	Defines = { "DISABLED" }
}

Effect PdxGuiProfileGraph
{
	VertexShader = "ProfilerGraphVertexShader"
	PixelShader = "ProfilerGraphPixelShader"
}
Effect PdxGuiProfileGraphDisabled
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	
	Defines = { "DISABLED" }
}
