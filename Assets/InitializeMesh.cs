using UnityEngine;
using System.Collections;
using UnityEditor;

public class InitializeMesh : MonoBehaviour {


        void Start()
    {
        this.GetComponent<MeshFilter>().mesh = Build();
        this.GetComponent<MeshRenderer>().bounds.extents.Set(1000000f, 1000000f, 1000000f);
    }

    Mesh Build()
	{

             Vector3[] jani = new Vector3[65536];
     MeshFilter mesher = new MeshFilter();
     int[] indices = new int[65536];
        Mesh mesh = new Mesh();

        //this.GetComponent<SkinnedMeshRenderer>().sharedMesh = new Mesh();
		//mesher = GetComponent<SkinnedMeshRenderer> ();
        
        //using a skinned mesh renderer since in perspective views, the object will become entirely culled if the camera isn't
        //looking directly at the origin, while the vertices can be much further out. SMR let's us expand the render bounds
		for (int i = 0; i < indices.Length; i++) {
			indices[i] = i;
			

		}
        //with interpolation, the vertex count would be a multiple of 8192 (* 4 = 32768, the number i used before)
        //but since i still haven't accomplished good interpolation/filtering i kept it at 8192
        //which is the exact number of samples per channel it can access from the sample buffer texture.
        for (int i = 0, z = 0; z < 65536; z++)
        {
            for (int y = 0; y < 1; y++)
            {
                for (int x = 0; x < 1; x++, i++)
                {


                    jani[i] = new Vector3(x, y, z- (65536 / 2));

                }
            }
        }




        //mesher.sharedMesh.Clear ();
		mesh.vertices = jani;
        //jani is the name of the main character from a bollywood movie called makkhi
        //where he is killed by some dick and reincarnates as a revenge hungry housefly.
        //there's this one part where there's like a choir chanting his name
        //and the day i was working on this mesh script I just had that part stuck in my head
        //so i decided to title the array that because i don't ever want to forget this gold.
       
        //also there is a musical number in the movie and jani the fly is fucking dancing and singing
        //and his wife who is a human still loves his tiny CGI fly husband
        //10/10 would recommend watching it's so good oh my god
        mesh.SetIndices (indices, MeshTopology.LineStrip, 0);
        //this produces the mesh we need for our vertex shader to work from.
        //a straight one dimensional line with a ton of vertices going down (err, forward)

        //AssetDatabase.CreateAsset(mesh, "Assets/mesh3.asset");
        mesh.bounds.extents.Set(100000f, 100000f, 100000f);
        mesh.bounds = new Bounds(Vector3.zero, Vector3.one * 2000);

        return mesh;
    }

}