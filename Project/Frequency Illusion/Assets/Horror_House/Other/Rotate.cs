using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotate : MonoBehaviour {
    public float x;
    public float y;
    public float z;

    // Use this for initialization
    void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
 
        transform.Rotate(x+0f, y+0f, z+0f);
    }
}
