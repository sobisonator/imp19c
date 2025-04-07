Includes = {
	"cw/pdxgui.fxh"
	"cw/pdxgui_sprite.fxh"
	"standardfuncsgfx.fxh"
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
				float4 OutColor = SampleImageSprite( Texture, Input.UV0 );
				OutColor *= Input.Color;

				// https://www.shadertoy.com/view/4tlczB
				float2 UV = Input.UV0;
			    UV.y*=1.1;
			    UV.y-= 0.05;
			    float iTime = GlobalTime * -1 * 0.5;
			    float WaveSize = 12.0;

			    // wave animation
			    float2 Wave = sin((UV.x+iTime*0.1) * WaveSize) * 0.03;

			    float4 WaveFlag = SampleImageSprite(Texture, float3(UV.x, UV.y + Wave));

				float value = dot(float3(1, 1, 1) / 45, WaveFlag.xyz);
				float f = sin(GlobalTime * -1 * 0.5 * (1.0f + 0.0001 * abs(sin(Input.Position.y * 0.02))) + Input.Position.x * 0.06 + 0.5 * sin(Input.Position.y * 0.02));
				f *= f;
				f *= 1.0 - value;
				f *= f;
				float outerness = 1.0f - 2.0f * min(min(min(Input.UV0.x, Input.UV0.y), 1.0f - Input.UV0.x), 1.0f - Input.UV0.y);
				f *= outerness;
				f = lerp(0.75f, 1.0f, 1.0 - f);
				WaveFlag.xyz *= f;
				WaveFlag.xyz += lerp(0.08f, 0.25f, outerness) * float3(1.0f, 1.0f, 0.5f) * value * value * max(0.0, sin(GlobalTime * -3.3 + Input.Position.x * 0.12 + Input.Position.y * 0.14 + 0.51 * sin(Input.Position.y * 0.011)));

				OutColor = WaveFlag;

			    // UV.y*= 1.1;
			    // UV.y-= 1.0;

				// float SmallWaveScale = 5.5;
				// float WaveScale = 0.3;
				// float AnimationSpeed = 1.0;

				// float AnimSeed = UV.x;
				
				// float Time = GlobalTime * AnimationSpeed;
				
				// float SmallWaveV = Time - AnimSeed * SmallWaveScale;
				// float SmallWaveD = -( AnimSeed * SmallWaveScale );
				// float SmallWave = sin( SmallWaveV );
				// float CombinedWave = SmallWave;
				
				// // Wave
				// float3 AnimationDir = float3( 0, 0.08, -1 );
				// float Wave = WaveScale * smoothstep( 0.0, 0.12, AnimSeed ) * CombinedWave;
				// float Derivative = ( WaveScale * 1.0f) * AnimSeed * -( SmallWave + cos( SmallWaveV ) * SmallWaveD );
				// float2 WaveTangent = normalize( float2( 3.0f, Derivative ) );

				// float4 WaveFlag = SampleImageSprite(Texture, float3(UV.x, UV.y + WaveTangent));
				// OutColor = WaveFlag;

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
