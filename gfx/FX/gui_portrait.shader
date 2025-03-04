Includes = {
	"cw/pdxgui.fxh"
	"cw/pdxgui_sprite.fxh"
}

VertexStruct VS_OUTPUT_PORTRAIT
{
	float4 Position		: PDX_POSITION;
	float2 UV0			: TEXCOORD0;
	float2 UV1			: TEXCOORD1;
	float4 Color		: COLOR;
	float  Lod			: TEXCOORD2;
};

ConstantBuffer( 2 )
{
	float2	WidgetPos;
	float2	WidgetSize;
	float3	HighlightColor;
	float	PopOutThreshold;
	float2	PortraitUVOffset;
	float2	PortraitUVScale;
	float2	PortraitTextureSize;
	float	IsGrayscale;
}

VertexShader =
{
	MainCode VertexShader
	{
		Input = "VS_INPUT_PDX_GUI"
		Output = "VS_OUTPUT_PORTRAIT"
		Code
		[[
			PDX_MAIN
			{	
				VS_OUTPUT_PORTRAIT Out;
				float2 PixelPos = WidgetLeftTop + Input.LeftTop_WidthHeight.xy + Input.Position * Input.LeftTop_WidthHeight.zw;
				Out.Position = PixelToScreenSpace( PixelPos );
				Out.UV0 = Input.UVLeftTop_WidthHeight.xy + Input.Position * Input.UVLeftTop_WidthHeight.zw;
				Out.UV1 = (PixelPos - WidgetPos) / WidgetSize;
				Out.Color = Input.Color;
				
				float2 SizeRatio = PortraitTextureSize / WidgetSize;
				Out.Lod = floor( log2( min( SizeRatio.x, SizeRatio.y ) ) );
				
				return Out;
			}
		]]
	}
}


PixelShader =
{
	TextureSampler Frame
	{
		Index = 0
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
	}
	
	TextureSampler Mask
	{
		Index = 1
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
	}
	
	TextureSampler Portrait
	{
		Index = 2
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
	}
	
	TextureSampler Background
	{
		Index = 3
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
	}
	
	MainCode PixelShader
	{
		Input = "VS_OUTPUT_PORTRAIT"
		Output = "PDX_COLOR"
		Code
		[[
			//Blends Front on top of Back using Front's alpha channel
			float4 BlendColor( in float4 Back, in float4 Front )
			{				
				float4 Color;
				Color.rgb = Front.rgb*Front.a + Back.rgb*Back.a * ( 1.0f - Front.a );
				Color.a = Front.a + Back.a * ( 1.0f - Front.a );
				Color.rgb /= Color.a;
				return Color;
			}
			float4 BlendColorPreMultiplied( in float4 Back, in float4 Front )
			{				
				return Front + Back * ( 1.0f - Front.a );
			}
			PDX_MAIN
			{	
				float2 PortraitUV = Input.UV1;
				PortraitUV /= PortraitUVScale;
				PortraitUV -= PortraitUVOffset / PortraitUVScale;
				
				float4 vPortrait   = PdxTex2DLod( Portrait, PortraitUV, Input.Lod );
				vPortrait.rgb *= vPortrait.a;
				float4 vBackground = PdxTex2DLod0( Background, Input.UV1 );
				float  vMask       = PdxTex2DLod0( Mask, Input.UV1 ).a;
				// float  vMask       = PdxTex2DLod0( Mask, Input.UV1 );
				
				float4 vFrame = SampleImageSprite( Frame, Input.UV0 );
								
				float4 vColor;
				vColor.rgb = vBackground.rgb * vMask;
				vColor.a = vBackground.a * vMask;
				
				vFrame.rgb *= vFrame.a;
								
				if( Input.UV1.y < PopOutThreshold )
				{
					vColor = BlendColor( vColor, vFrame );
					vColor = BlendColor( vColor, vPortrait );
				}
				else
				{
					vPortrait *= vMask;
					vColor = BlendColor( vColor, vPortrait );
					vColor = BlendColor( vColor, vFrame );
				}
				#ifdef DISABLED
					vColor.rgb = DisableColor( vColor.rgb );
				#else
					if ( IsGrayscale > 0.5f )
					{
						vColor.rgb = DisableColor( vColor.rgb );
					}
				#endif
				
				vColor *= Input.Color;
				#ifndef NO_HIGHLIGHT
					vColor.rgb += HighlightColor * vColor.a;
				#endif
			    return vColor;			
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

Effect PdxGuiPortrait
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	
	Defines = { "PDX_GUI_CORNERED_SPRITE_SUPPORT" }
}

Effect Up
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	
	Defines = { "PDX_GUI_CORNERED_SPRITE_SUPPORT" }
}

Effect Over
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	
	Defines = { "PDX_GUI_CORNERED_SPRITE_SUPPORT" }
}

Effect Down
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	
	Defines = { "PDX_GUI_CORNERED_SPRITE_SUPPORT" }
}

Effect Disabled
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	
	Defines = { "DISABLED" "PDX_GUI_CORNERED_SPRITE_SUPPORT" "NO_HIGHTLIGHT" }
}
