/*

OMPU CO PRESENTS: AN OSCILLOSCOPE SHADER PROGRAM: HHHHHHHHHHHHHHHHHHHHHHHH

				TO DO:
1)create a quick system to enable/change interpolation from the main scope script. 
	1a)Also, make a main scope script instead of using three different scripts hacked together like the sad man i am.



/////////////////////////
UPDATE 8/5/18: 
Implemented a simple bicubic (I think?) interpolation method a couple months ago. 

It's not quite 1 to 1 with the actual scope, but it's better than before. 
Because of this, I've updated the mesh initializer to produce a much denser mesh.


Will have to set up an option for a low-quality mesh & shader setup that uses the old mesh so that it can work better
on older systems, since obviously there's (3 times) more geometry than before. Currently this shader has been optimized
a ton, but now only has support for the higher density mesh since it's rescaled for it. Hopefully I'll implement and
update this repo for that feature sooner than the last update.
/////////////////////////



2)implement interpolation filtering to produce less jagged and more authentic beam lines
	2a)figure out sinc/lanczos filtering and how to implement it in a shader like this

3)scope signal capacitance emulation (beam/image position averages around center of voltage, will have to find samples to share 
but it basically means that if an image doesn't have a strong center of voltage it might move all over the place (look up 
oscilloscope asteroids project for an example of using a border frame to keep the image stable)). this is important to
emulate in order to be able to combat it and make use of artifacts that occur because of it

4)strip down parts of the code since there's quite a few areas that are more complicated than they need to be.
I just wanted to at least get this out since I feel fried after spending a ton of hours cleaning the guck outta it.
	4b)remove excessive comments once i finally stop being nervous about posting my own code


bonus round)how2pronounce lanczos???? (V IMPORTANT!! make studies of this)

*/


Shader "Oscilloscope" {
	Properties{
	_Color("Color", Color) = (0.458823529,0.588235294,0.525490196,1)
	[Toggle] _OS ("Bicubic Interpolation", float) = 1.0
}

SubShader {
         Tags {  "IgnoreProjector"="True" "RenderType"="Transparent"}

	LOD 100
Blend One One
	
	Pass { // ZWrite Off
			//ZTest Off
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag 
			#pragma multi_compile_fog
			#define TAUR 2.5066282746310002
			#define NUM_COEF 128
#define TAU 6.283185307179586476925286766559
#define PI 3.14159265
			#include "UnityCG.cginc"

					
					







			struct appdata_t {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {        
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
				float4 texcoord2 : TEXCOORD2;
				UNITY_FOG_COORDS(1)
			};


	
	float _OS;



			
float Tex2Dat(float4 datex) { 
	float result = (datex.x + datex.y) - (datex.z + datex.w);
	//datex.x & datex.y represent positive floats
	//datex.z & datex.w represent negative floats
	return result;
}//custom function to unpack audio values from RGBA color




float4 pointer;//we'll use this to store the position we'll use to read from the audio buffer texture
sampler2D _AudioBuffer; //and this is the audio buffer texture
float4 _AudioBuffer_ST;
float4 _AudioBuffer_TexelSize;
fixed4 _Color; //color of the beam

float2 readData(uint id, float4 pointer)
{
float4 x1 = tex2Dlod(_AudioBuffer,pointer);
pointer.y=1;
float4 y1 = tex2Dlod(_AudioBuffer,pointer);
float2 r = float2(Tex2Dat(x1),Tex2Dat(y1));


return r;
}


float2 Filter(uint id, float4 pointer){
float tn = id%8;
pointer.x=(id*_AudioBuffer_TexelSize.x)/8.0;
float numberOfPoints = 8.0;
float t = 0;
//pointer.x=(1+pointer.x-_AudioBuffer_TexelSize.x*_OS)%1.0;

float2 p0 = readData(id,pointer);
pointer.x=(pointer.x+_AudioBuffer_TexelSize.x*_OS)%1.0;


float2 p1 = readData(id,pointer);
pointer.x=(pointer.x+_AudioBuffer_TexelSize.x*_OS)%1.0;


float2 p2 = readData(id,pointer);

      p0 = 0.5 * (p0 
         + p1);
		 
      p2 = 0.5 * (p1 
         + p2);

	t = tn / (numberOfPoints );
	float2 position = (1.0 - t) * (1.0 - t) * p0 + 2.0 * (1.0 - t) * t * p1 + t * t * p2;


//if(_Time.w%5<2.5)
return position;
//else
//return p1;
}


			v2f vert (appdata_t v, uint id : SV_VertexID, uint inst : SV_InstanceID)
			{			
				


				float interpol = 8;
				//above is the interpolation multiplier. this might be useful once i can figure out useful interpolation/filtering
				//but if interpolation is not being use, it should be set to 1. If you'd like to use interpolation to experiment
				//make sure to multiply the for loop number for the Z axis in InitializeMesh.cs. I'll see if I can add a public variable
				//to do this automatically in the soonest revision

				
				



				v2f o;

				float why = float(id);
				v.vertex.z=id;
				o.texcoord.y=v.vertex.z;
				//id*=step(3,id%4);

				pointer.x = fmod(((id)/(8192 * interpol)),1);
				pointer.y = 0; //switch to X set on horizontal line 0
			float4 X = tex2Dlod(_AudioBuffer, pointer);//grab current X value from texture at coordinate



			pointer.x = fmod(((id -interpol) / (8192 * interpol)), 1);//-interpol gets previous coord
			float4 preX = tex2Dlod(_AudioBuffer, pointer);//get previous position value for comparison later
			
			pointer.x = fmod(((id + interpol) / (8192 * interpol)), 1);//+interpol gets next coord
			float4 postX = tex2Dlod(_AudioBuffer, pointer);//get next position value for comparison later

			//X axis transform with the obtained current X position
			//			v.vertex.x += Tex2Dat(X);




			//			pointer.y = 1; //switch to Y set on horizontal line 1
						pointer.x = fmod(((id) / (8192 * interpol)), 1);
			float4 Y = tex2Dlod(_AudioBuffer, pointer); //grab current Y value from texture at coordinate

			pointer.x = fmod(((id - interpol) / (8192 * interpol)), 1);//-interpol gets previous coord
			float4 preY = tex2Dlod(_AudioBuffer, pointer); //get previous position value for comparison later
			
			pointer.x = fmod(((id + interpol) / (8192 * interpol)), 1);//+interpol gets next coord
			float4 postY = tex2Dlod(_AudioBuffer, pointer);//get next position value for comparison later



			//Y axis transform
			//v.vertex.y += Tex2Dat(Y);
			

			v.vertex.xy=Filter(id,pointer);
			
			float px = Tex2Dat(preX);
			float py = Tex2Dat(preY);
			float nx = Tex2Dat(X);
			float ny = Tex2Dat(Y);
			float fx = Tex2Dat(postX);
			float fy = Tex2Dat(postY);



			float2 diff = float2(abs(v.vertex.x - px), abs(v.vertex.y - py));


			o.texcoord2 = float4 (nx, ny, px, py);



			
			/*DEBUG THINGS, MAYBE COOL????
			//v.vertex.x *= step(fmod(why, 8), 0); //find out if the current vertex is an interpol vertex 
			//v.vertex.x = (v.vertex.x * step(fmod(why, 8), 6)) + (100*step(fmod(why, 8), 0)); //find out if the current vertex is an interpol vertex
			
			
			
			//debug//v.vertex.x += sin(fmod(id + 1, 8)) / 1000;//DEBUG: Draws a circle at each set of 7 vertices if interpolation is at 8
			//debug//v.vertex.y += cos(fmod(id + 1, 8)) / 1000;//DEBUG: see above u dink
			END DEBUG THINGS*/
			





			/* INTERPOLATION ATTEMPT FAILURE BELOW:
			//float fod = fmod(why + 1, 8);
			int fod = fmod(id, 8);
			
			float2 k[8];
			
			for (uint i = 0; i < 8; i++)
			{
				float t = float(i) / (8.0 - 1.0);
				float2 p0 = float2(exx, wyy);
				float2 p1 = float2(nx, ny);
				float2 p2 = float2(fx, fy);
				float2 position = (1.0 - t) * (1.0 - t) * p0
					+ 2.0 * (1.0 - t) * t * p1
					+ t * t * p2;
				k[i] = position;
			}

			v.vertex.xy = k[fmod(id, 8)];

			//i tried to get at least quadratic interpolation working to curve between the points,
			//but i'm really bad at this and couldn't get it to work yet.

			END OF SAD ATTEMPT*/


			float t=_Time.w*100;

			
			//v.vertex.xy+=float2(cos(float(id+t)/interpol/4),sin(float(id+t)/interpol/4))/50;
			
			//if(id%4<3)
			//v.vertex.xy=float2(cos(float(id+t)/interpol/4),sin(float(id+t)/interpol/4))/50;
			
			
			v.vertex.xy *= float2(4, 4);//just helps to make it a little bigger since the initial values aren't too huge
			v.vertex.z-=32768;//center the mesh offset on the Z axis by subtracting half the vertex count (each vert already moves forward one unit)
			

			

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = float2(0,id);//stores vertex id in the texcoord data to be accessed in the frag shader, useful for debugging interpolation
				//note to self: should probably combine texcoord and texcoord2 cause texcoord2 sounds dumb 
				//and i could probably do some of the number crunching before sending that data in texcoord.
				

				UNITY_TRANSFER_FOG(o,o.vertex);//i actually don't think this is important but i never removed it so ¯\_(ツ)_/¯
				//ps pls dont yell at me im sorry


				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target

			 {fixed4 col = _Color; 


			col.rgb -= ((-log(abs(i.texcoord.y/(8192))*1)));
			//REALLY shoddy code to simulate decay by Z depth (older samples are pushed back in the Z direction already)
			//could probably do it better but it works for now.

			
			col.rgb -= (abs((i.texcoord2.x) - (i.texcoord2.z)) + abs((i.texcoord2.y) - (i.texcoord2.w))); 
			//finds the difference between previous and current points and adjusts color accordingly.
			//the beam intensity is inversely proportionate to the length between the vertices that make its line.
			//i think this could be improved by using lanczos filter interpolation values?? other than that it seems to work p well
			
			/*
			//Following code used when testing interpolation, 8 vertices of interpolation per known sample (make sure mesh has 32768 verts initialized)
			float fod = floor(fmod(i.texcoord.y + 1, 8));
			col = float4((fod), (fod), 1, 1);// fmod(i.texcoord.y,.5)*10;
			*/

			col=.61;
			
			/*
			col.r=.5+sin((i.texcoord.y%8))/2;//step(6,i.texcoord.y%8);
			col.g=.5+cos((i.texcoord.y%8))/2;//1-step(4,i.texcoord.y%8);
			col.b=.5+cos((-i.texcoord.y%8))/2;//1-step(2,i.texcoord.y%8);

			col.r=step(6,i.texcoord.y%8);
			col.g=1-step(4,i.texcoord.y%8);
			col.b=1-step(2,i.texcoord.y%8);
			*/

			col=col/2+.5;

			col=_Color*(pow(i.texcoord.y/65536,1.05));
				UNITY_APPLY_FOG(i.fogCoord, col);

				return col;
			}
		ENDCG
	}
}

}
//WE DID IT!
//THANK YOU FOR JOINING ME ON MY EPIC QUEST
//you can buy souvenirs at the gift shop shaped like my fursona

//also if you would like to propose changes or contributions 
//i would be happy to hear and credit anyone who helps with this project!

//--------------
//all code by sam blye/ompu co 2017, i did it i'm the one that broke ur pc. all by myself
