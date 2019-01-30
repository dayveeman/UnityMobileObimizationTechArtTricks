using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

namespace Yeti
{
	[Serializable]
	public class GlobalVar_Float
	{
	    public string VarFloatName;
	    public float VarFloat;
	}
	
	[Serializable]
	public class GlobalVar_Vec4
	{
	    public string VarVec4Name;
	    public Vector4 VarVec4;
	}
	
	[Serializable]
	public class GlobalVar_Color
	{
	    public string VarColorName;
	    public Color VarColor;
	}
	
	[Serializable]
	public class GlobalVar_Texture
	{
	    public string VarTextureName;
	    public Texture VarTexture;
	}
	
	[ExecuteInEditMode]
	public class GlobalShaderVariables : MonoBehaviour
	{
	    public List<GlobalVar_Float> GlobalFloat = new List<GlobalVar_Float>();
	    public List<GlobalVar_Vec4> GlobalVec4 = new List<GlobalVar_Vec4>();
	    public List<GlobalVar_Color> GlobalColor = new List<GlobalVar_Color>();
	    public List<GlobalVar_Texture> GlobalTexture = new List<GlobalVar_Texture>();
	
	    private int GlobalFloatNum;
	    private int GlobalVec4Num;
	    private int GlobalColorNum;
	    private int GlobalTextureNum;
	
	    private void Awake()
	    {
	        GlobalFloatNum  = GlobalFloat.Count;
	        GlobalVec4Num = GlobalVec4.Count;
	        GlobalColorNum = GlobalColor.Count;
	        GlobalTextureNum = GlobalTexture.Count;
	    }

		void Update()
	    {
	        for (int i = 0; i < GlobalFloatNum; ++i)
	        {
	            GlobalVar_Float gFloat = GlobalFloat[i];
	            Shader.SetGlobalFloat(gFloat.VarFloatName, gFloat.VarFloat);
	        }
	        for (int i = 0; i < GlobalVec4Num; ++i)
	        {
	            GlobalVar_Vec4 gVec = GlobalVec4[i];
	            Shader.SetGlobalVector(gVec.VarVec4Name, gVec.VarVec4);
	        }
	        for (int i = 0; i < GlobalColorNum; ++i)
	        {
	            GlobalVar_Color gColor = GlobalColor[i];
	            Shader.SetGlobalColor(gColor.VarColorName, gColor.VarColor);
	        }
	        for (int i = 0; i < GlobalTextureNum; ++i)
	        {
	            GlobalVar_Texture gTexture = GlobalTexture[i];
	            Shader.SetGlobalTexture(gTexture.VarTextureName, gTexture.VarTexture);
	        }
	    }
	}
}