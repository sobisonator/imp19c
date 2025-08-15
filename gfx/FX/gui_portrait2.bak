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
			struct PainterlySettings
			{
				int _KuwaharaSteps; // How many steps are we sampling away from the current point (more = less sharp)
				float _KuwaharaStepSize; // How big is each step we make? (1.0 = one pixel in source texture)

				int _OutlineSamples; // How many times to sample around each pixel
				float _OutlineWidth; // Width of outline, measured in pixels of texture
				float _OutlineAlphaThreshhold; // At which alpha does the outline kick in?
				float4 _OutlineColor; // Color of outline
			};

			// Kuwahara Filter - simple implementation with 4 square regions with one line overlap
			// https://en.wikipedia.org/wiki/Kuwahara_filter
			float4 ApplyKuwaharaFilter( float2 PortraitUV, float Lod, PainterlySettings Settings)
			{
				float2 SourcePixelUV = float2 (1.0 / PortraitTextureSize.x, 1.0 / PortraitTextureSize.y) ;

				float2 SampleStepSize = Settings._KuwaharaStepSize * SourcePixelUV;

				float NumSamples = float( ( Settings._KuwaharaSteps + 1 ) * (Settings._KuwaharaSteps + 1) );

				int x; int y; // Loop var
				float3 c = float3(0, 0, 0); // Color loop var

				float3 m[4] = {c, c, c, c}; // Collected colors
				float3 s[4] = {c, c, c, c}; // Collected square colors

				// Left-Bottom quadrant
				for ( y = -Settings._KuwaharaSteps; y <= 0; ++y)
				{
					for (int x = -Settings._KuwaharaSteps; x <= 0; ++x)
					{
						c = PdxTex2DLod( Portrait, PortraitUV + float2(x, y) * SampleStepSize, Lod).rgb;
						m[0] += c;
						s[0] += c * c;
					}
				}

				// Right-Bottom quadrant
				for ( y = -Settings._KuwaharaSteps; y <= 0; ++y)
				{
					for ( int x = 0; x <= Settings._KuwaharaSteps; ++x )
					{
						c = PdxTex2DLod( Portrait, PortraitUV + float2(x, y) * SampleStepSize, Lod).rgb;
						m[1] += c;
						s[1] += c * c;
					}
				}

				// Right-Top quadrant
				for ( y = 0; y <= Settings._KuwaharaSteps; ++y )
				{
					for ( int x = 0; x <= Settings._KuwaharaSteps; ++x )
					{
						c = PdxTex2DLod( Portrait, PortraitUV + float2(x, y) * SampleStepSize, Lod).rgb;
						m[2] += c;
						s[2] += c * c;
					}
				}

				// Left-Top quadrant
				for ( y = 0; y <= Settings._KuwaharaSteps; ++y )
				{
					for ( int x = -Settings._KuwaharaSteps; x <= 0; ++x )
					{
						c = PdxTex2DLod( Portrait, PortraitUV + float2(x, y) * SampleStepSize, Lod).rgb;
						m[3] += c;
						s[3] += c * c;
					}
				}

				float CurrentAlpha = PdxTex2DLod( Portrait, PortraitUV, Lod).a;
				float4 ColorOut;

				float MinimumSigma2 = 1e+2;
				float Sigma2 = MinimumSigma2;

				// Find Quadrant with least deviation, return the average color of that quadrant
				for ( int i = 0; i < 4; ++i )
				{
					m[i] /= NumSamples;
					s[i] = abs(s[i] / NumSamples - m[i] * m[i]);
					float Sigma2 = s[i].r + s[i].g + s[i].b;
					if ( Sigma2 < MinimumSigma2 )
					{
						MinimumSigma2 = Sigma2;
						ColorOut = float4(m[i], CurrentAlpha);
					}
				}

				return ColorOut;
			}
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

			float4 AddAlphaOutline( float4 Color, float2 PortraitUV, float Lod, PainterlySettings Settings)
			{
				if ( Color.a > Settings._OutlineAlphaThreshhold )
				{
					return Color;
				}

				float2 SourcePixelRatio = float2 (1.0 / PortraitTextureSize.x, 1.0 / PortraitTextureSize.y);

				float RadPerSample = ( (360.0 / float(Settings._OutlineSamples) ) * PI) / 180.0;
				float4 OutColor = float4( 0, 0, 0, 0 );
				float4 SampleColor;

				// Sample in a circle around the current point, find the highest alpha value
				for ( int i = 0; i < Settings._OutlineSamples; i++)
				{
					float SampleRad = float(i + 1) * RadPerSample;
					float2 Offset = float2(cos(SampleRad), -sin(SampleRad)) * SourcePixelRatio * Settings._OutlineWidth;
					SampleColor = PdxTex2DLod( Portrait, PortraitUV + Offset, Lod);
					if ( SampleColor.a > OutColor.a )
					{
						OutColor.xyz = Settings._OutlineColor.xyz;
						OutColor.a = SampleColor.a * Settings._OutlineColor.a;
					}
				}

				if ( OutColor.a > 0.0 )
				{
					return OutColor;
				}

				return Color;
			}
			PDX_MAIN
			{	
				float2 PortraitUV = Input.UV1;
				PortraitUV /= PortraitUVScale;
				PortraitUV -= PortraitUVOffset / PortraitUVScale;
				
				PainterlySettings Settings;
				Settings._KuwaharaSteps = 3;
				Settings._KuwaharaStepSize = 0.6;
				Settings._OutlineSamples = 12;
				Settings._OutlineWidth = 4.0;
				Settings._OutlineAlphaThreshhold = 0.9;
				Settings._OutlineColor = float4( 0.18, 0.15, 0.15, 1.0 );

				// We're overriding the GUI property `pop_out = yes` to mean 'add outline = yes' and `pop_out_v = 2.3` to mean 'outline width = 2.3'
				Settings._OutlineWidth = PopOutThreshold;

				float4 vPortrait = ApplyKuwaharaFilter( PortraitUV, Input.Lod, Settings );
 				vPortrait = AddAlphaOutline( vPortrait, PortraitUV, Input.Lod, Settings );

				float4 vBackground = PdxTex2DLod0( Background, Input.UV1 );
				float  vMask       = PdxTex2DLod0( Mask, Input.UV1 ).a;
				
				float4 vFrame = SampleImageSprite( Frame, Input.UV0 );
								
				float4 vColor;
				vColor.rgb = vBackground.rgb * vMask;
				vColor.a = vBackground.a * vMask;
				
				vFrame.rgb *= vFrame.a;
								
				if( Input.UV1.y < PopOutThreshold )
				{
					vColor = BlendColorPreMultiplied( vColor, vFrame );
					vColor = BlendColorPreMultiplied( vColor, vPortrait );
				}
				else
				{
					vPortrait *= vMask;
					vColor = BlendColorPreMultiplied( vColor, vPortrait );
					vColor = BlendColorPreMultiplied( vColor, vFrame );
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
