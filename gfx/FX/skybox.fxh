Includes = {
	"cw/camera.fxh"
}

Code
[[
	bool SKY_IsCameraTilted()
	{
	    static const float MIN_CAMERA_PITCH_COS = 0.935f;

	    float3 CameraLookAtDirXZ = float3(CameraLookAtDir.x, 0.0f, CameraLookAtDir.z);
	    float  CameraPitchCos    = dot(CameraLookAtDir, CameraLookAtDirXZ);

	    return CameraPitchCos > MIN_CAMERA_PITCH_COS;
	}
]]