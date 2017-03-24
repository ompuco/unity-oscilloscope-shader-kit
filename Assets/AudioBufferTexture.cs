//QUICK NOTE: I haven't gotten around to cleaning/commenting this script very well yet but basically it reads 
//from the audio buffer from both channels and sends it to the shader as one long texture. 

//The methods of creating the texture could probably be improved a lot, as well as the math taking the data
//and turning it into colors (Mathf functions are really heavy sometimes).



//Feel free to tinker with this if you want to try optimizing it, but there shouldn't be much
//need to modify the stuff here. 8192 samples every frame is already p dang good.




using UnityEngine;
using UnityEngine.UI;
using System.Collections;

public class AudioBufferTexture : MonoBehaviour
{
    private Texture2D beam;//the databuffer texture
    private float[] dists;//stores left channel audio samples
    private float[] dists2;//stores right channel audio samples
    private Color[] colo;
    //public AudioListener listenr;
    // Use this for initialization
    void Start()
    {
        colo = new Color[8192 * 2];//number of color values = samples times channels
        beam = new Texture2D(8192, 2, TextureFormat.RGBAFloat, false);
        beam.wrapMode = TextureWrapMode.Clamp;
        beam.filterMode = FilterMode.Point;
        //gameObject.GetComponent<SkinnedMeshRenderer>().material.SetTexture("_MainTex", beam);

        dists = new float[8192]; dists2 = new float[8192];
    }


    void Update()
    {

        AudioListener.GetOutputData(dists, 0);//get samples from left channel
        AudioListener.GetOutputData(dists2, 1);//get samples from right channel

        for (int y = 0; y < 2; y++)
            for (int x = 0; x < 8192; x++)
            {

                if (y < 1)
                {
                    double currentp = Mathf.Clamp01((float)(dists[x]));//positive X
                    double currentn = (((float)Mathf.Clamp01(-((float) dists[x]))));//negative X

                    Color coloro = new Color((float)currentp, 0, (float)currentn, 0);
                    colo[x] = coloro;
                }
                else
                {


                    double currentp = Mathf.Clamp01((float)(dists2[x]));//positive Y
                    double currentn = (((float)Mathf.Clamp01(-((float)dists2[x]))));//negative Y


                    Color coloro = new Color((float)currentp, 0, (float)currentn, 0);
                    colo[x + 8192] = coloro;
                }
            }

        beam.SetPixels(colo, 0);
        beam.Apply();



        this.GetComponent<SkinnedMeshRenderer>().material.SetTexture("_MainTex", beam);//finally send audio buffer to shader!

    }
}

