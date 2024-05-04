# pdxgui_default.shader with a bunch of different effects
# Use effectname = "x" in the gui to use a different pixel shader for different gui widgets

Includes = {
	"cw/pdxgui.fxh"
	"cw/pdxgui_sprite.fxh"
	"cw/utility.fxh"
	"standardfuncsgfx.fxh" 
	# standardfuncsgfx.fxh imported for GlobalTime
	# If using in Victoria 3 change to "sharedconstants.fxh"
	# If using in CK3 or Imperator keep "standardfuncsgfx.fxh"
}

VertexShader =
{
	MainCode VS_Default
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
		MagFilter = "Point"
		MinFilter = "Point"
		MipFilter = "Point"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
	}
	MainCode PS_Default
	{	
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
	MainCode PS_GuiPosterize
	{ 
		Input = "VS_OUTPUT_PDX_GUI"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				// https://www.shadertoy.com/view/XlSSRW
				// Posterization for Gui elements

				float4 OutColor = SampleImageSprite( Texture, Input.UV0 );

				float nColors = 9.0;
				float vx_offset = 0.5;
				float2 coord = float2(0.0,0.0);
				float cutColor = 1./nColors;
				
			    OutColor.rgb = RGBtoHSV( OutColor.rgb );
			    float2 target_c = cutColor*floor(OutColor.gb/cutColor);
			    OutColor.rgb = HSVtoRGB( float3(OutColor.r,target_c) );

				#ifdef DISABLED
					OutColor.rgb = DisableColor( OutColor.rgb );
				#endif

				return OutColor;
			}
		]]
	}
	MainCode PS_GuiSharpen
	{	
		Input = "VS_OUTPUT_PDX_GUI"
		Output = "PDX_COLOR"
		Code
		[[
			float extractLuma(float3 c)
			{
			    return c.r * 0.299 + c.g * 0.587 + c.b * 0.114;
			}
			PDX_MAIN
			{
				// www.shadertoy.com/view/4tcGW2
				// Sharpen effect for gui elements

				float4 OutColor = SampleImageSprite( Texture, Input.UV0 );
				OutColor *= Input.Color;

				float3x3 YUVFromRGB = Create3x3(
				   float3(0.299,-0.14713, 0.615),
				   float3(0.587,-0.28886,-0.51499),
				   float3(0.114,0.436,-0.10001));

				float3x3 RGBFromYUV = Create3x3(
				    float3(1, 1, 1),
				    float3(0.0,-0.394,2.03211),
				    float3(1.13983,-0.580,0.0));

			    float3 yuv = mul(YUVFromRGB, OutColor.rgb);
			    float2 size = Input.Position.x / Input.Position.y;
			    
			    float accumY = 0.0; 
			    for(int i = -1; i <= 1; ++i) {
			        for(int j = -1; j <= 1; ++j) {
			            float2 offset = float2(i,j) / size;
			            float s = extractLuma(SampleImageSprite(Texture,Input.UV0 + offset).rgb);
			            float notCentre = min(float(i*i + j*j),1.0);
			            accumY += s * (9.0 - notCentre*10.0);
			        }
			    }
			    
			    accumY /= 22.0;
			    accumY = (accumY + yuv.x)*0.9;
			    
				OutColor = float4(mul(RGBFromYUV, float3(accumY,yuv.y,yuv.z)),OutColor.a);
				#ifdef DISABLED
					OutColor.rgb = DisableColor( OutColor.rgb );
				#endif

				return OutColor;
			}
		]]
	}
	MainCode PS_GuiChromaticAberration
	{	
		Input = "VS_OUTPUT_PDX_GUI"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				// https://www.shadertoy.com/view/Mds3zn
				// Chromatic Aberration for gui elements
				float4 OutColor = SampleImageSprite( Texture, Input.UV0 );
				OutColor *= Input.Color;

				// Chromatic Abberation Constants
				#define TIME_1 float(GlobalTime * 2.0)
				#define TIME_2 float(GlobalTime * 12.0)
				#define TIME_3 float(GlobalTime * 13.0)
				#define TIME_4 float(GlobalTime * 18.0)
				#define ABBERATION_INTENSITY 0.002
				#define ABBERATION_TIME_1 0.5

				float amount = 0.0;
				amount = (1.0 + sin(TIME_1)) * ABBERATION_TIME_1;
				amount *= 1.0 + sin(TIME_2) * 0.5;
				amount *= 1.0 + sin(TIME_3) * 0.5;
				amount *= 1.0 + sin(TIME_4) * 0.5;
				amount = pow(amount, 1.2);

				amount *= ABBERATION_INTENSITY;

			    float3 col;
			    col.r = SampleImageSprite( Texture, float2(Input.UV0.x+amount,Input.UV0.y) ).r;
			    col.g = SampleImageSprite( Texture, Input.UV0 ).g;
			    col.b = SampleImageSprite( Texture, float2(Input.UV0.x-amount,Input.UV0.y) ).b;

				col *= (1.0 - amount * 0.5);
				
			    OutColor = float4(col,OutColor.a);

			    #ifdef DISABLED
			    	OutColor.rgb = DisableColor( OutColor.rgb );
			    #endif

				return OutColor;
			}
		]]
	}
	MainCode PS_GuiAberration
	{	
		Input = "VS_OUTPUT_PDX_GUI"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				// https://github.com/dinfinity/mpc-pixel-shaders/blob/master/PS_Aberration1.hlsl
				// Aberration for gui elements
				float4 OutColor = SampleImageSprite( Texture, Input.UV0 );
				OutColor *= Input.Color;

				// Abberation 2 Constants
				float factor = 0.01;
				float xTrans = (Input.UV0.x*2)-1;
				float yTrans = 1-(Input.UV0.y*2);
				
				float angle = atan(yTrans/xTrans) + PI;

				angle += (sign(xTrans) == 1) ? PI : 0.0;

				float radius = sqrt(pow(xTrans,2) + pow(yTrans,2));
				float2 rC,gC,bC;
				float3 radii = float3(radius + radius * factor, radius, radius - radius * factor);

				rC.x = (radii[0] * cos(angle)+1.0)/2.0;
				rC.y = -1* ((radii[0] * sin(angle)-1.0)/2.0);

				gC.x = (radii[1] * cos(angle)+1.0)/2.0;
				gC.y = -1* ((radii[1] * sin(angle)-1.0)/2.0);

				bC.x = (radii[2] * cos(angle)+1.0)/2.0;
				bC.y = -1* ((radii[2] * sin(angle)-1.0)/2.0);

				float4 rA = SampleImageSprite(Texture, rC);
				float4 gA = SampleImageSprite(Texture, gC);
				float4 bA = SampleImageSprite(Texture, bC);

				float4 result = float4(rA[0], gA[1], bA[2], 1.0);
				OutColor = float4(result.rgb, OutColor.a);
			    #ifdef DISABLED
			    	OutColor.rgb = DisableColor( OutColor.rgb );
			    #endif

				return OutColor;
			}
		]]
	}
	MainCode PS_GuiEmboss
	{	
		Input = "VS_OUTPUT_PDX_GUI"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				// https://github.com/dinfinity/mpc-pixel-shaders/blob/master/PS_Color%20Emboss%202.hlsl
				float4 OutColor = SampleImageSprite( Texture, Input.UV0 );
				OutColor *= Input.Color;
				
				#define angleSteps 32 // default = 12
				#define radiusSteps 4
				#define totalSteps (radiusSteps * angleSteps)

				float ampFactor = 8;
				#define minRadius (1/Input.Position.x) // width = Input.Position.x
				#define maxRadius (6/Input.Position.x)

				#define angleDelta ((2 * PI) / angleSteps)
				#define radiusDelta ((maxRadius - minRadius) / radiusSteps)
				#define embossAngle (PI/4)

				// Transition from embossed to normal
				// float LerpFactor = 3;
				// static const float LerpY = 1;
				// LerpFactor *= pow( sin( GlobalTime ) * 0.5f + 0.5f, 3.5 ) * 0.5f;
				// ampFactor = lerp( ampFactor, LerpY, LerpFactor );

				float4 accumulatedColor = {0,0,0,0};	
				for (int radiusStep = 0; radiusStep < radiusSteps; radiusStep++) {
					float radius = minRadius + radiusStep * radiusDelta;

					for (float angle=0; angle <(2*PI); angle += angleDelta) {
						float xDiff = radius * cos(angle);
						float yDiff = radius * sin(angle);
						
						float2 currentCoord = Input.UV0 + float2(xDiff, yDiff);
						float4 currentColor = SampleImageSprite(Texture, currentCoord);
						float4 colorDiff = abs(OutColor - currentColor) ;
						float currentFraction = ((float)(radiusSteps+1 - radiusStep)) / (radiusSteps+1);
						accumulatedColor +=  currentFraction * colorDiff / totalSteps * sign(angle  -  PI);
					}
				}
				accumulatedColor *= ampFactor;

				//OutColor = OutColor+accumulatedColor; // down
				OutColor = OutColor-accumulatedColor; // up

				#ifdef DISABLED
					OutColor.rgb = DisableColor( OutColor.rgb );
				#endif
				
			    return OutColor;
			}
		]]
	}
	MainCode PS_GuiCameraFilm
	{
		Input = "VS_OUTPUT_PDX_GUI"
		Output = "PDX_COLOR"
		Code
		[[
			float3 channel_mix(float3 a, float3 b, float3 w) {
			    return float3(lerp(a.r, b.r, w.r), lerp(a.g, b.g, w.g), lerp(a.b, b.b, w.b));
			}

			float gaussian(float z, float u, float o) {
			    return (1.0 / (o * sqrt(2.0 * 3.1415))) * exp(-(((z - u) * (z - u)) / (2.0 * (o * o))));
			}

			float3 screen(float3 a, float3 b, float w) {
			    return lerp(a, vec3(1.0) - (vec3(1.0) - a) * (vec3(1.0) - b), w);
			}

			float3 soft_light(float3 a, float3 b, float w) {
			    return lerp(a, pow(a, pow(vec3(2.0), 2.0 * (vec3(0.5) - b))), w);
			}

			PDX_MAIN
			{
				// https://www.shadertoy.com/view/4t2fRz
				// Camera film filter effect for gui elements

				float4 OutColor = SampleImageSprite( Texture, Input.UV0 );
				OutColor *= Input.Color;

				#define SPEED 2.0
				#define INTENSITY 0.075
				#define MEAN 0.0 // What gray level noise should tend to.
				#define VARIANCE 0.5 // Controls the contrast/variance of noise.

				float t = GlobalTime / float(SPEED);
				float seed = dot(Input.UV0, float2(12.9898, 78.233));
				float noise = frac(sin(seed) * 43758.5453 + t);
				noise = gaussian(noise, float(MEAN), float(VARIANCE) * float(VARIANCE));
				float3 grain = vec3(noise) * (1.0 - OutColor.rgb);
				
				// Output options
				// Addition
				OutColor.rgb += grain * INTENSITY;
				// Screen
				//OutColor.rgb = screen(color.rgb, grain, INTENSITY);
				// Soft Light
				//OutColor.rgb = soft_light(color.rgb, grain, INTENSITY);
				// Lighten-Only
				//OutColor.rgb = max(color.rgb, grain * INTENSITY);

				#ifdef DISABLED
					OutColor.rgb = DisableColor( OutColor.rgb );
				#endif


				return OutColor;
			}
		]]
	}
	MainCode PS_GuiColorGrading
	{	
		Input = "VS_OUTPUT_PDX_GUI"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				// https://github.com/dinfinity/mpc-pixel-shaders/blob/master/PS_Color%20Grading.hlsl
				float4 OutColor = SampleImageSprite( Texture, Input.UV0 );
				OutColor *= Input.Color;

				float lum = (OutColor.r + OutColor.g + OutColor.b) / 3.0;
				float lumComp = 1.0 - lum;
				float3 startColor, endColor;
				startColor = float3(180.0/255,180.0/255,180.0/255);
				endColor = float3(70.0/255,160.0/255,255.0/255);

				startColor = float3(180.0/255,180.0/255,120.0/255);
				endColor = float3(200.0/255,140.0/255,50.0/255);

				// Modifying color calculation
				float4 modColor;
				modColor.r = lum*startColor.r + lumComp*endColor.r;
				modColor.g = lum*startColor.g + lumComp*endColor.g;
				modColor.b = lum*startColor.b + lumComp*endColor.b;
				modColor[3] = 1;
				// Color application
				float4 result = OutColor * modColor;

				// Luminance restoration
				float resultLum = (result.r + result.g + result.b) / 3.0;
				result *= lum / resultLum;  

				// Output options
				// OutColor = float4(c0.rgb, OutColor.a);
				// OutColor = float4(modColor.rgb, OutColor.a);
				OutColor = float4(result.rgb, OutColor.a);

				#ifdef DISABLED
					OutColor.rgb = DisableColor( OutColor.rgb );
				#endif
				
			    return OutColor;
			}
		]]
	}
	MainCode PS_GuiDreamView
	{	
		Input = "VS_OUTPUT_PDX_GUI"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				// https://github.com/dinfinity/mpc-pixel-shaders/blob/master/PS_Dream%20View.hlsl
				float4 OutColor = SampleImageSprite( Texture, Input.UV0 );
				OutColor *= Input.Color;

				float xTrans = (Input.UV0.x*2)-1;
				float yTrans = 1-(Input.UV0.y*2);
				
				float radius = sqrt(pow(xTrans,2) + pow(yTrans,2));

				float angleStart = 50;
				int angleSteps = 15;
				int radiusSteps = 8;
				float minRadius = 0/Input.UV0.x;
				float maxRadius = pow(radius,13)*1.0/Input.UV0.x;
				float ampFactor = 1.5;

				float4 accumulatedColor = float4(0.0,0.0,0.0,0.0);
				int totalSteps = radiusSteps * angleSteps;
				float angleDelta = (2 * PI) / angleSteps;
				float radiusDelta = (maxRadius - minRadius) / radiusSteps;

				for (int radiusStep = 0; radiusStep < radiusSteps; radiusStep++) {
					float radius = minRadius + radiusStep * radiusDelta;

					for (float angle=0+angleStart; angle <(2*PI)+angleStart; angle += angleDelta) {
						float2 currentCoord;

						float xDiff = radius * cos(angle);
						float yDiff = radius * sin(angle);
						
						currentCoord = Input.UV0 + float2(xDiff, yDiff);
						float4 currentColor = SampleImageSprite(Texture, currentCoord);
						float currentFraction = ((float)(radiusSteps+1 - radiusStep)) / (radiusSteps+1);

						accumulatedColor +=   currentFraction * currentColor / totalSteps;
						
					}
				}
				float4 result = 1.4*accumulatedColor * ampFactor / (1.9 - radius);
				OutColor = float4(result.rgb, OutColor.a);

				#ifdef DISABLED
					OutColor.rgb = DisableColor( OutColor.rgb );
				#endif
				
			    return OutColor;
			}
		]]
	}
	MainCode PS_GuiSaturate
	{	
		Input = "VS_OUTPUT_PDX_GUI"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				// https://github.com/dinfinity/mpc-pixel-shaders/blob/master/PS_Saturation.hlsl
				float4 OutColor = SampleImageSprite( Texture, Input.UV0 );
				OutColor *= Input.Color;
				static const float SAT_FACTOR = 2.0;
				static const float SAT_CORRECTION = 0.9;

				float luminance = (OutColor.r+OutColor.g+OutColor.b)/3;
				//Saturate
				float4 result = OutColor * SAT_FACTOR + (1-SAT_FACTOR)*luminance;
				OutColor = float4(result.rgb, OutColor.a);
				OutColor.rgb *= SAT_CORRECTION;

				#ifdef DISABLED
					OutColor.rgb = DisableColor( OutColor.rgb );
				#endif
				
			    return OutColor;
			}
		]]
	}
	MainCode PS_GuiShakyColor
	{	
		Input = "VS_OUTPUT_PDX_GUI"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				// https://github.com/dinfinity/mpc-pixel-shaders/blob/master/PS_ShakyColor.hlsl
				float4 OutColor = SampleImageSprite( Texture, Input.UV0 );
				OutColor *= Input.Color;
				
				float speedFactor = 1.5;
				float divider = 1500;
				float modClock = GlobalTime * speedFactor;

				float2 originalLocation = Input.UV0;
				float2 sourceLocation = Input.UV0;
				float2 sourceTwoLocation = Input.UV0;

				float clockSine =  sin(modClock*6)+ sin(modClock*4) + sin(modClock*7) + sin(modClock*8);
				clockSine = clockSine / divider;
				float clockSine2 =  cos(modClock*6)+ cos(modClock*6) + cos(modClock*7) + cos(modClock*8);
				clockSine2 = clockSine2/ divider;

				sourceLocation.x = sourceLocation.x + clockSine / 4.0 - clockSine2 / 4.0 - (clockSine / 2.0) +(clockSine2/2);
				sourceLocation.y = sourceLocation.y + clockSine / 4.0 + clockSine2 / 4.0 - (clockSine / 2.0) +(clockSine2/2);

				sourceTwoLocation.x = sourceTwoLocation.x - clockSine / 4.0 + clockSine2 / 4.0 - (clockSine / 2.0) +(clockSine2/2);
				sourceTwoLocation.y = sourceTwoLocation.y - clockSine / 4.0 - clockSine2 / 4.0 - (clockSine / 2.0) +(clockSine2/2);

				float4 sourceColor = SampleImageSprite(Texture, sourceLocation);
				float4 sourceTwoColor = SampleImageSprite(Texture, sourceTwoLocation);
				float4 originalColor = SampleImageSprite(Texture, originalLocation);
				float4 result = float4(sourceTwoColor.r, sourceColor.g, originalColor.b, 1.0);
				OutColor = float4(result.rgb, OutColor.a);

				#ifdef DISABLED
					OutColor.rgb = DisableColor( OutColor.rgb );
				#endif
				
			    return OutColor;
			}
		]]
	}
	MainCode PS_GuiVibrance
	{	
		Input = "VS_OUTPUT_PDX_GUI"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				// https://github.com/dinfinity/mpc-pixel-shaders/blob/master/PS_Vibrance.hlsl
				float4 OutColor = SampleImageSprite( Texture, Input.UV0 );
				OutColor *= Input.Color;
				float4 result = OutColor;

				float saturationRate = 20.0;
				float luminance = (OutColor.r + OutColor.g + OutColor.b)/3.0;

				float currentSaturation = ((abs(result.r-luminance) + abs(result.g-luminance) + abs(result.b-luminance))/3.0) * (1.0-luminance);
				float currentSaturationCompensation = (1.0 - currentSaturation)/10.0;

				float4 moreVibrant = result;
				float4 lessVibrant = result;
				float4 moreSaturated = result;

				moreVibrant.r += (result.r-luminance) * saturationRate * currentSaturation;
				moreVibrant.g += (result.g-luminance) * saturationRate * currentSaturation;
				moreVibrant.b += (result.b-luminance) * saturationRate * currentSaturation;

				lessVibrant.r += (result.r-luminance) * saturationRate * currentSaturationCompensation;
				lessVibrant.g += (result.g-luminance) * saturationRate * currentSaturationCompensation;
				lessVibrant.b += (result.b-luminance) * saturationRate * currentSaturationCompensation;

				moreSaturated.r += (result.r-luminance) * saturationRate * luminance;
				moreSaturated.g += (result.g-luminance) * saturationRate * luminance;
				moreSaturated.b += (result.b-luminance) * saturationRate * luminance;

			// 	result = lessVibrant;
			// 	result = moreSaturated;
			 	result = moreVibrant;
			 	result.rgb *= 0.9;

				OutColor = result;

				#ifdef DISABLED
					OutColor.rgb = DisableColor( OutColor.rgb );
				#endif
				
			    return OutColor;
			}
		]]
	}
	MainCode PS_GuiVignet
	{	
		Input = "VS_OUTPUT_PDX_GUI"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				// https://github.com/dinfinity/mpc-pixel-shaders/blob/master/PS_Vignetting2.hlsl
				float4 OutColor = SampleImageSprite( Texture, Input.UV0 );
				OutColor *= Input.Color;
			
				float innerRadius = 0.7;
				float outerRadius = 1.6;
				float opacity = 0.8;
				float correction = 0.2;

				float4 c0 = SampleImageSprite(Texture, Input.UV0);
				float verticalDim = 0.5 + sin (Input.UV0.y*PI)*0.9 ;
				
				float xTrans = (Input.UV0.x*2)-1;
				float yTrans = 1-(Input.UV0.y*2);
				
				float radius = sqrt(pow(xTrans,2) + pow(yTrans,2));

				float subtraction = max(0,radius - innerRadius) / (outerRadius-innerRadius);
				float factor = 1 - subtraction;

				float4 vignetColor = c0*factor;
				vignetColor *= verticalDim;

				vignetColor *= opacity;
				c0 *= 1-opacity;
				c0 *= correction;

				float4 output = c0+vignetColor;	
				OutColor = float4(output.rgb, OutColor.a);

				#ifdef DISABLED
					OutColor.rgb = DisableColor( OutColor.rgb );
				#endif
				
			    return OutColor;
			}
		]]
	}
	MainCode PS_GuiCrossProcessing
	{	
		Input = "VS_OUTPUT_PDX_GUI"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				// https://github.com/dinfinity/mpc-pixel-shaders/blob/master/PS_CrossProcessing.hlsl
				float4 OutColor = SampleImageSprite( Texture, Input.UV0 );
				OutColor *= Input.Color;
			
				float4 c0 = SampleImageSprite(Texture, Input.UV0);

				float factor[3];
				factor[0] = 0.11;
				factor[1] = 0.04;
				factor[2] = 0.09;

				int sign1[3];
				sign1[0] = -1;
				sign1[1] = -1;
				sign1[2] = 1;
				// int sign1[3];
				// sign1[0] = 1;
				// sign1[1] = -1;
				// sign1[2] = 1;

				// if (Input.UV0.x > 0.3) {
				c0[0] += factor[0] * sign1[0] * sin(c0[0] * 2 * PI);
				c0[1] += factor[1] * sign1[1] * sin(c0[1] * 2 * PI);
				c0[2] += factor[2] * sign1[2] * sin(c0[2] * 2 * PI);
				// }

				OutColor = float4(c0.rgb, OutColor.a);

				#ifdef DISABLED
					OutColor.rgb = DisableColor( OutColor.rgb );
				#endif
				
			    return OutColor;
			}
		]]
	}
	MainCode PS_GuiUnderwaterBlur
	{	
		Input = "VS_OUTPUT_PDX_GUI"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				// https://affirmaconsulting.wordpress.com/2011/02/03/pixel-shaders-w-source-and-a-demo-2/
				float4 OutColor = SampleImageSprite( Texture, Input.UV0 );
				OutColor *= Input.Color;
				
				float LocalTime = GlobalTime / 5;
				float2 poisson[12];
				poisson[0] = float2(-0.326212f, -0.40581f);
				poisson[1] = float2(-0.840144f, -0.07358f);
				poisson[2] = float2(-0.695914f, 0.457137f);
				poisson[3] = float2(-0.203345f, 0.620716f);
				poisson[4] = float2(0.96234f, -0.194983f);
				poisson[5] = float2(0.473434f, -0.480026f);
				poisson[6] = float2(0.519456f, 0.767022f);
				poisson[7] = float2(0.185461f, -0.893124f);
				poisson[8] = float2(0.507431f, 0.064425f);
				poisson[9] = float2(0.89642f, 0.412458f);
				poisson[10] = float2(-0.32194f, -0.932615);
				poisson[11] = float2(-0.791559f, -0.59771f);

				float2 Delta = float2(sin(LocalTime + Input.UV0.x*23 + Input.UV0.y*Input.UV0.y*17)*0.02, cos(LocalTime + Input.UV0.y*32 + Input.UV0.x*Input.UV0.x*13)*0.02);
				float2 NewUV = Input.UV0 + Delta;
				float4 Color = 0;

				for (int i = 0; i < 12; i++)
				{
				   float2 Coord = NewUV + (poisson[i] / 1000.0);
				   Color += SampleImageSprite(Texture, Coord) / 17.0;
				}
				Color += SampleImageSprite(Texture, Input.UV0) / 40;
				OutColor = float4(Color.rgb, OutColor.a);
				#ifdef DISABLED
					OutColor.rgb = DisableColor( OutColor.rgb );
				#endif
				
			    return OutColor;
			}
		]]
	}
	MainCode PS_GuiKaleidoscope
	{	
		Input = "VS_OUTPUT_PDX_GUI"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				// https://github.com/dinfinity/mpc-pixel-shaders/blob/master/PS_Kaleidoscope2.hlsl
				// Could maybe add movement to this, might be too much though
				float4 OutColor = SampleImageSprite( Texture, Input.UV0 );
				OutColor *= Input.Color;

				#define sectionWidth 30
				#define angleSectionStart 3
				#define typeDisplacement ((180/sectionWidth) * angleSectionStart)
				#define sectionFraction (radians(sectionWidth))

				float xTrans = (Input.UV0.x*2)-1;
				float yTrans = 1-(Input.UV0.y*2);
				float angle = atan(yTrans/xTrans)+ (PI/2);
				angle += (sign(xTrans) == -1) ? PI : 0.0;
				float radius = sqrt(pow(xTrans,2) + pow(yTrans,2));	
				float angleDegrees = degrees(angle);
				int angleType = angleDegrees /sectionWidth;
				
				angleType += typeDisplacement;
				float2 newCoord;
				float sampleAngle;
				if (angleType % 2 == 0) {
				   sampleAngle = angle -  (sectionFraction * angleType) - (PI/2);
				    newCoord.x = radius * cos(sampleAngle);
			        } else {
				    sampleAngle = angle -  (sectionFraction * (angleType + 1)) - (PI/2);
				    newCoord.x = -1 * radius * cos(sampleAngle);
				} 
			    newCoord.y = radius * sin(sampleAngle);
			    newCoord.x = (1.0 + newCoord.x) / 2;
			    newCoord.y = (1.0 - newCoord.y) / 2;

			    float4 res  = SampleImageSprite(Texture, newCoord);
				OutColor = float4(res.rgb, OutColor.a);
				#ifdef DISABLED
					OutColor.rgb = DisableColor( OutColor.rgb );
				#endif
			    return OutColor;
			}
		]]
	}
	MainCode PS_GuiEdges
	{	
		Input = "VS_OUTPUT_PDX_GUI"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				// https://github.com/dinfinity/mpc-pixel-shaders/blob/master/PS_Edges.hlsl
				float4 OutColor = SampleImageSprite( Texture, Input.UV0 );
				OutColor *= Input.Color;
				
				#define angleSteps 15
				#define radiusSteps 12
				#define totalSteps (radiusSteps * angleSteps)

				#define ampFactor 1.75
				#define minRadius (0.0/Input.Position.x)
				#define maxRadius (100.0/Input.Position.x)

				#define angleDelta ((2 * PI) / angleSteps)
				#define radiusDelta ((maxRadius - minRadius) / radiusSteps)

				float angleOffset = PI * 2;
				//angleOffset *= GlobalTime / 20;

				float4 accumulatedColor = float4(0,0,0,0);
				for (int radiusStep = 0; radiusStep < radiusSteps; radiusStep++) {
					float radius = minRadius + radiusStep * radiusDelta;

					for (float angle=0; angle <(2*PI); angle += angleDelta) {
						float modAngle = angle + angleOffset;
						modAngle -= (modAngle > 2*PI) ? 2*PI : 0.0;

						float2 currentCoord;
						float xDiff = radius * cos(modAngle);
						float yDiff = radius * sin(modAngle);
						
						currentCoord = Input.UV0 + float2(xDiff, yDiff);
						float4 currentColor = SampleImageSprite(Texture, currentCoord);
						float4 colorDiff = abs(OutColor - currentColor);
						float currentFraction = ((float)(radiusSteps+1 - radiusStep)) / (radiusSteps+1);
						accumulatedColor +=  currentFraction * colorDiff / totalSteps;
						
					}
				}
				accumulatedColor *= ampFactor;
				//float4 res = accumulatedColor; // Traditional edge style;
				//float4 res = 0.85*OutColor+accumulatedColor; // Smoother style;
				//float4 res = OutColor+accumulatedColor; // Angel style;
				float4 res = 1.25*OutColor-accumulatedColor; // Cell shaded style

				OutColor = float4(res.rgb, OutColor.a);
				#ifdef DISABLED
					OutColor.rgb = DisableColor( OutColor.rgb );
				#endif
			    return OutColor;
			}
		]]
	}
	MainCode PS_GuiCellShade
	{	
		Input = "VS_OUTPUT_PDX_GUI"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				// https://github.com/dinfinity/mpc-pixel-shaders/blob/master/PS_CellShadedStyle.hlsl
				float4 OutColor = SampleImageSprite( Texture, Input.UV0 );
				OutColor *= Input.Color;

				#define angleSteps 9
				#define radiusSteps 21
				#define totalSteps (radiusSteps * angleSteps)

				#define ampFactor 1.1
				#define minRadius (3/Input.Position.x)
				#define maxRadius (24/Input.Position.x)

				#define angleDelta ((2 * PI) / angleSteps)
				#define radiusDelta ((maxRadius - minRadius) / radiusSteps)
				float4 accumulatedColor = float4(0,0,0,0);

				for (int radiusStep = 0; radiusStep < radiusSteps; radiusStep++) {
					float radius = minRadius + radiusStep * radiusDelta;

					for (float angle=0; angle <(2*PI); angle += angleDelta) {
						float2 currentCoord;
						float xDiff = radius * cos(angle);
						float yDiff = radius * sin(angle);
						
						currentCoord = Input.UV0 + float2(xDiff, yDiff);
						float4 currentColor = SampleImageSprite(Texture, currentCoord);
						float4 colorDiff = abs(OutColor - currentColor);
						float currentFraction = ((float)(radiusSteps+1 - radiusStep)) / (radiusSteps+1);
						accumulatedColor +=  currentFraction * colorDiff / totalSteps;
					}
				}
				accumulatedColor *= ampFactor;
				float4 res = OutColor-accumulatedColor;
				OutColor = float4(res.rgb, OutColor.a);
				OutColor *= 1.2;
				#ifdef DISABLED
					OutColor.rgb = DisableColor( OutColor.rgb );
				#endif
			    return OutColor;
			}
		]]
	}
	MainCode PS_GuiBloom
	{	
		Input = "VS_OUTPUT_PDX_GUI"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				// https://github.com/dinfinity/mpc-pixel-shaders/blob/master/PS_Bloom.hlsl
				float4 OutColor = SampleImageSprite( Texture, Input.UV0 );
				OutColor *= Input.Color;

				#define angleSteps 12
				#define radiusSteps 10
				#define minRadius (0.0/Input.Position.x)
				#define maxRadius (10.0/Input.Position.x)
				#define ampFactor 1.3
				float correction = 0.6;

				float4 accumulatedColor = float4(0,0,0,0);
				int totalSteps = radiusSteps * angleSteps;
				float angleDelta = (2 * PI) / angleSteps;
				float radiusDelta = (maxRadius - minRadius) / radiusSteps;

				for (int radiusStep = 0; radiusStep < radiusSteps; radiusStep++) {
					float radius = minRadius + radiusStep * radiusDelta;

					for (float angle=0; angle <(2*PI); angle += angleDelta) {
						float2 currentCoord;

						float xDiff = radius * cos(angle);
						float yDiff = radius * sin(angle);
						
						currentCoord = Input.UV0 + float2(xDiff, yDiff);
						float4 currentColor = SampleImageSprite(Texture, currentCoord);
						float currentFraction = ((float)(radiusSteps+1 - radiusStep)) / (radiusSteps+1);

						accumulatedColor +=   currentFraction * currentColor / totalSteps;
					}
				}

				float4 outputPixel = SampleImageSprite(Texture, Input.UV0);
				outputPixel += accumulatedColor * ampFactor;
				outputPixel *= correction;
				OutColor = float4(outputPixel.rgb, OutColor.a);
				#ifdef DISABLED
					OutColor.rgb = DisableColor( OutColor.rgb );
				#endif
			    return OutColor;
			}
		]]
	}
	MainCode PS_GuiGloom
	{	
		Input = "VS_OUTPUT_PDX_GUI"
		Output = "PDX_COLOR"
		Code
		[[
			float4 AdjustSaturation(float4 color, float saturation)
			{
			    float grey = dot(color, float3(0.3, 0.59, 0.11));
			    return lerp(grey, color, saturation);
			}
			PDX_MAIN
			{
				float4 OutColor = SampleImageSprite( Texture, Input.UV0 );
				OutColor *= Input.Color;

				float GloomIntensity = 0.9;
				float BaseIntensity = 0.75;
				float GloomSaturation = 1.0;
				float BaseSaturation = 1.0;
				float threshold = 0.25f;

				float4 base = 1.0 - OutColor;
				float4 gloom = saturate((base - threshold) / (1 - threshold));
				
				gloom = AdjustSaturation(gloom, GloomSaturation) * GloomIntensity;
				base = AdjustSaturation(base, BaseSaturation) * BaseIntensity;
				base *= (1 - saturate(gloom));
				
				float4 res = 1.0 - (base + gloom);
				OutColor = float4(res.rgb, OutColor.a);
				#ifdef DISABLED
					OutColor.rgb = DisableColor( OutColor.rgb );
				#endif
				
			    return OutColor;
			}
		]]
	}
	MainCode PS_GuiPlasticWrap
	{	
		Input = "VS_OUTPUT_PDX_GUI"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				// https://github.com/dinfinity/mpc-pixel-shaders/blob/master/PS_Plastic%20Wrap.hlsl
				float4 OutColor = SampleImageSprite( Texture, Input.UV0 );
				OutColor *= Input.Color;

				#define angleSteps 13
				#define radiusSteps 21
				#define totalSteps (radiusSteps * angleSteps)

				#define ampFactor 40
				#define minRadius (2/Input.Position.x)
				#define maxRadius (36/Input.Position.x)

				#define angleDelta ((2 * PI) / angleSteps)
				#define radiusDelta ((maxRadius - minRadius) / radiusSteps)
				float correction = 0.7;

				float4 c0 = SampleImageSprite(Texture, Input.UV0);
				float4 accumulatedColor = float4(0,0,0,0);	

				for (int radiusStep = 1; radiusStep <= radiusSteps; radiusStep++) {
					float radius = minRadius + radiusDelta;

					for (float angle=0; angle <(2*PI); angle += angleDelta) {
						float2 currentCoord;

						float xDiff = radius * cos(angle);
						float yDiff = radius * sin(angle);
						
						currentCoord = Input.UV0 + float2(xDiff, yDiff);
						float4 currentColor = SampleImageSprite(Texture, currentCoord);
						float4 colorDiff = c0 - currentColor;

						accumulatedColor += ((radiusSteps+1 - radiusStep) /radiusSteps) * colorDiff / totalSteps;
					}
				}
				accumulatedColor *= ampFactor;

				//=-- Edge play
				float luminance = (accumulatedColor.r + accumulatedColor.g + accumulatedColor.b) / 3;
				c0 = (luminance >= 0) ? c0 + luminance : c0 - luminance;
				c0 *= correction;
				OutColor = float4(c0.rgb, OutColor.a);
				#ifdef DISABLED
					OutColor.rgb = DisableColor( OutColor.rgb );
				#endif
			    return OutColor;
			}
		]]
	}
	MainCode PS_GuiHueShift
	{	
		Input = "VS_OUTPUT_PDX_GUI"
		Output = "PDX_COLOR"
		Code
		[[
			float4 shiftHue(in float3 col, in float shift)
			{
				float3 P = vec3(0.55735) * dot(vec3(0.55735), col);
				float3 U = col - P;
				float3 V = cross(vec3(0.55735), U);    
				col = U * cos(shift * 6.2832) + V * sin(shift * 6.2832) + P;
				return float4(col, 1.0);
			}
			PDX_MAIN
			{
				// https://www.shadertoy.com/view/MdjBRy
				float4 OutColor = SampleImageSprite( Texture, Input.UV0 );
				OutColor *= Input.Color;

				float hue = abs(sin(GlobalTime * 0.1));
				float4 color = shiftHue(OutColor.rgb, hue);
				OutColor = float4(color.rgb, OutColor.a);

				#ifdef DISABLED
					OutColor.rgb = DisableColor( OutColor.rgb );
				#endif
				
			    return OutColor;
			}
		]]
	}
	MainCode PS_GuiOilPainting
	{	
		Input = "VS_OUTPUT_PDX_GUI"
		Output = "PDX_COLOR"
		Code
		[[

			float getVal(float2 uv, float2 Res)
			{
				return length(PdxTex2DLod(Texture,uv,.5+.5*log2(Res.x/1920.)).xyz);
			}
				
			float2 getGrad(float2 uv,float delta, float2 res)
			{
				float2 d=float2(delta,0);
				return float2(
					getVal(uv+d.xy, res)-getVal(uv-d.xy, res),
					getVal(uv+d.yx, res)-getVal(uv-d.yx, res)
				)/delta;
			}
			PDX_MAIN
			{
				// https://www.shadertoy.com/view/MtKcDG
				#define Res Input.Position.xy
				float4 OutColor = SampleImageSprite( Texture, Input.UV0 );
				
				float4 fragColor;
				float PaintSpec = .20;
				float offset = 0.75;

				float2 uv = Input.UV0;
				float3 n = float3(getGrad(uv,1.0/Input.Position.y, Input.Position.xy),600.0);

				n=normalize(n);
				fragColor=float4(n,1);
				float3 light = normalize(float3(-1,1,1.4));
				float diff=clamp(dot(n,light),0.,1.0);
				float spec=clamp(dot(reflect(light,n),float3(0,0,-1)),0.0,1.0);
				spec=pow(spec,25.0)*PaintSpec;
				float sh=clamp(dot(reflect(light*float3(-1,-1,1),n),float3(0,0,-1)),0.0,1.0);
				sh=pow(sh,4.0)*.1;
				fragColor = SampleImageSprite(Texture,uv)*lerp(diff,1.,offset)+spec*float4(.85,1.,1.15,1.)+sh*float4(.85,1.,1.15,1.);
				fragColor.w=1.;

				OutColor = float4(fragColor.rgb, OutColor.a);
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
	VertexShader = "VS_Default"
	PixelShader = "PS_Default"
}
Effect PdxGuiDefaultDisabled
{
	VertexShader = "VS_Default"
	PixelShader = "PS_Default"
	
	Defines = { "DISABLED" }
}

Effect PdxGuiDefaultNoAlpha
{
	VertexShader = "VS_Default"
	PixelShader = "PS_Default"
	BlendState = BlendStateNoAlpha
}
Effect PdxGuiDefaultNoAlphaDisabled
{
	VertexShader = "VS_Default"
	PixelShader = "PS_Default"
	BlendState = BlendStateNoAlpha
	
	Defines = { "DISABLED" }
}

Effect PdxGuiPreMultipliedAlpha
{
	VertexShader = "VS_Default"
	PixelShader = "PS_Default"
	BlendState = PreMultipliedAlpha
}
Effect PdxGuiPreMultipliedAlphaDisabled
{
	VertexShader = "VS_Default"
	PixelShader = "PS_Default"
	BlendState = PreMultipliedAlpha
	
	Defines = { "DISABLED" }
}

Effect GuiPosterize
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiPosterize"
}
Effect GuiPosterizeDisabled
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiPosterize"
	
	Defines = { "DISABLED" }
}

Effect GuiSharpen
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiSharpen"
}
Effect GuiSharpenDisabled
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiSharpen"
	
	Defines = { "DISABLED" }
}

Effect GuiChromaticAberration
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiChromaticAberration"
}
Effect GuiChromaticAberrationDisabled
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiChromaticAberration"
	
	Defines = { "DISABLED" }
}

Effect GuiCameraFilm
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiCameraFilm"
}
Effect GuiCameraFilmDisabled
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiCameraFilm"
	
	Defines = { "DISABLED" }
}

Effect GuiAberration
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiAberration"
}
Effect GuiAberrationDisabled
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiAberration"
	
	Defines = { "DISABLED" }
}

Effect GuiEmboss
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiEmboss"
}
Effect GuiEmbossDisabled
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiEmboss"
	
	Defines = { "DISABLED" }
}

Effect GuiColorGrading
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiColorGrading"
}
Effect GuiColorGradingDisabled
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiColorGrading"
	
	Defines = { "DISABLED" }
}

Effect GuiDreamView
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiDreamView"
}
Effect GuiDreamViewDisabled
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiDreamView"
	
	Defines = { "DISABLED" }
}

Effect GuiTopAndBottomDarken
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiTopAndBottomDarken"
}

Effect GuiSaturate
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiSaturate"
}
Effect GuiSaturateDisabled
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiSaturate"
	
	Defines = { "DISABLED" }
}

Effect GuiShakyColor
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiShakyColor"
}
Effect GuiShakyColorDisabled
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiShakyColor"
	
	Defines = { "DISABLED" }
}

Effect GuiVibrance
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiVibrance"
}

Effect GuiVibranceDisabled
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiVibrance"
	
	Defines = { "DISABLED" }
}

Effect GuiVignet
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiVignet"
}
Effect GuiVignetDisabled
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiVignet"
	
	Defines = { "DISABLED" }
}

Effect GuiCrossProcessing
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiCrossProcessing"
}
Effect GuiCrossProcessingDisabled
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiCrossProcessing"
	
	Defines = { "DISABLED" }
}

Effect GuiUnderwaterBlur
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiUnderwaterBlur"
}
Effect GuiUnderwaterBlurDisabled
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiUnderwaterBlur"
	
	Defines = { "DISABLED" }
}

Effect GuiKaleidoscope
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiKaleidoscope"
}
Effect GuiKaleidoscopeDisabled
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiKaleidoscope"
	
	Defines = { "DISABLED" }
}

Effect GuiEdges
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiEdges"
}
Effect GuiEdgesDisabled
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiEdges"
	
	Defines = { "DISABLED" }
}

Effect GuiCellShade
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiCellShade"
}
Effect GuiCellShadeDisabled
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiCellShade"
	
	Defines = { "DISABLED" }
}

Effect GuiBloom
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiBloom"
}
Effect GuiBloomDisabled
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiBloom"
	
	Defines = { "DISABLED" }
}

Effect GuiGloom
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiGloom"
}
Effect GuiGloomDisabled
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiGloom"
	
	Defines = { "DISABLED" }
}

Effect GuiPlasticWrap
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiPlasticWrap"
}
Effect GuiPlasticWrapDisabled
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiPlasticWrap"
	
	Defines = { "DISABLED" }
}

Effect GuiHueShift
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiHueShift"
}
Effect GuiHueShiftDisabled
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiHueShift"
	
	Defines = { "DISABLED" }
}

Effect GuiOilPainting
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiOilPainting"
}
Effect GuiOilPaintingDisabled
{
	VertexShader = "VS_Default"
	PixelShader = "PS_GuiOilPainting"
	
	Defines = { "DISABLED" }
}
