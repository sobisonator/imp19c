Includes = {
	"cw/utility.fxh"
	"cw/camera.fxh"
	"cw/random.fxh"
	"cw/fullscreen_vertexshader.fxh"
}

PixelShader =
{
	TextureSampler DepthBuffer
	{
		Ref = JominiDepthBuffer
		MagFilter = "Point"
		MinFilter = "Point"
		MipFilter = "Point"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
	}
	
	TextureSampler DepthBufferMultiSampled
	{
		Ref = JominiDepthBufferMultiSampled
		MagFilter = "Point"
		MinFilter = "Point"
		MipFilter = "Point"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
		MultiSampled = yes
	}
		
	Code
	[[		
		float GetViewSpaceDepth( float2 UV, float2 Resolution )
		{
		#ifdef MULTI_SAMPLED
			int2 PixelIndex = int2( UV * Resolution );
			float Depth = PdxTex2DMultiSampled( DepthBufferMultiSampled, PixelIndex, 0 ).r;
		#else
			float Depth = PdxTex2DLod0( DepthBuffer, UV ).r;
		#endif
			return CalcViewSpaceDepth( Depth );
		}
	]]

	MainCode PixelShaderSSAO
	{	
		ConstantBuffer( PdxConstantBuffer0 )
		{
			float2		Resolution;
			float 		InvAspectRatio;
			float		DepthDistance;
			float		MaxDepth;
			float		Radius;
			float		MaxRadius; 
			int			NumSamples;
			float		AOScale;
			float		AOBias;
			float		AOPower;
			
			float4		DiscSamples[16];
		}
	
		Input = "VS_OUTPUT_FULLSCREEN"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				float RandomAngle = CalcRandom( round( Input.uv * Resolution ) ) * 3.14159 * 2.0;
				float2 Rotate = float2( cos( RandomAngle ), sin( RandomAngle ) );
				float2x2 RotateMat = Create2x2( Rotate.x, Rotate.y, -Rotate.y, Rotate.x );
				
				float Depth = GetViewSpaceDepth( Input.uv, Resolution );				
				
				float AO = 0.5; // Add center sample
				
				// The radius should get smaller the further away it is
				float ScaledRadius = min( Radius / Depth, MaxRadius );
				//ScaledRadius = 0.02;
				
				for ( int i = 0; i < NumSamples; ++i )
				{
					float2 SamplePoint = DiscSamples[i].xy;
					SamplePoint = mul( RotateMat, SamplePoint );
					
					// Correct for the aspect ratio
					SamplePoint.x *= InvAspectRatio;
					
					float2 SampleOffset = SamplePoint * ScaledRadius;
					
					float SphereHeight = DiscSamples[i].z * DepthDistance;
					//SphereHeight = 2.0 * DepthDistance;
					//SphereHeight = DiscSamples[i].z * DepthDistance * ScaledRadius;
					
					// Sample the offset position
					float SampleDepth = GetViewSpaceDepth( Input.uv + SampleOffset, Resolution );
					
					// Find the difference between the sample and the center sample
					float DepthDifference = Depth - SampleDepth;
					//return float4( saturate(-DepthDifference * 0.01), 0, 0, 1 );
					
					// How much of the sphere do the sample occlude
					float Occlusion = saturate( ( DepthDifference / SphereHeight ) + 0.5 );
					
					// Used to mask out invalid occlusing object 
					float DistanceModifier = saturate( ( MaxDepth - DepthDifference ) / MaxDepth );
					Occlusion = lerp( 0.0, Occlusion, DistanceModifier );
					
					AO += Occlusion;
				}
				
				AO /= NumSamples + 1;
				AO = 1.0 - AO;
				AO = pow( AOScale * ( AO + AOBias ), AOPower );
			
				return float4( AO, 0.0, 0.0, 1.0 );
			}
		]]
	}
		
	MainCode PixelShaderSSAOBlur
	{
		TextureSampler BlurSource
		{
			Ref = PdxTexture1
			MagFilter = "Point"
			MinFilter = "Point"
			MipFilter = "Point"
			SampleModeU = "Clamp"
			SampleModeV = "Clamp"
		}
	
		ConstantBuffer( PdxConstantBuffer0 )
		{
			float4		ResolutionAndInv;
			float		Weight0;
			float 		Axis;
			float		DepthPow;
			int			NumSamples;
			float4 		Weights;
		};

		Input = "VS_OUTPUT_FULLSCREEN"
		Output = "PDX_COLOR"
		Code
		[[		
			PDX_MAIN
			{
				float2 Resolution = ResolutionAndInv.xy;
				float2 InvSize = ResolutionAndInv.zw;
				
				float AO = PdxTex2DLod0( BlurSource, Input.uv ).r * Weight0;
				float Depth = GetViewSpaceDepth( Input.uv, Resolution );
				
				float2 AxisOffset = InvSize * float2( Axis, 1.0 - Axis );
				float WeightSum = Weight0;
				for ( int i = 1; i < NumSamples; ++i )
				{
					float2 Offset = AxisOffset * i;
					
					float SampleDepth = GetViewSpaceDepth( Input.uv - Offset, Resolution );
					float DepthWeight = Weights[i-1] / pow( 1.0 + abs( Depth - SampleDepth ), DepthPow );
					float SampleAO = PdxTex2DLod0( BlurSource, Input.uv - Offset ).r;
					AO += SampleAO * DepthWeight;
					WeightSum += DepthWeight;
				
					SampleDepth = GetViewSpaceDepth( Input.uv + Offset, Resolution );
					DepthWeight = Weights[i-1] / pow( 1.0 + abs( Depth - SampleDepth ), DepthPow );
					SampleAO = PdxTex2DLod0( BlurSource, Input.uv + Offset ).r;
					AO += SampleAO * DepthWeight;
					WeightSum += DepthWeight;
				}
				
				AO /= WeightSum;
				
				return float4( AO, 0.0, 0.0, 1.0 );
			}
		]]
	}
}


BlendState BlendState
{
	BlendEnable = no
	WriteMask = "RED"
}

DepthStencilState DepthStencilState
{
	DepthEnable = no
	DepthWriteEnable = no
}


Effect SSAO
{
	VertexShader = "VertexShaderFullscreen"
	PixelShader = "PixelShaderSSAO"
}

Effect SSAOMultiSampled
{
	VertexShader = "VertexShaderFullscreen"
	PixelShader = "PixelShaderSSAO"
	
	Defines = { "MULTI_SAMPLED" }
}

Effect SSAOBlur
{
	VertexShader = "VertexShaderFullscreen"
	PixelShader = "PixelShaderSSAOBlur"
}

Effect SSAOBlurMultiSampled
{
	VertexShader = "VertexShaderFullscreen"
	PixelShader = "PixelShaderSSAOBlur"
	
	Defines = { "MULTI_SAMPLED" }
}
