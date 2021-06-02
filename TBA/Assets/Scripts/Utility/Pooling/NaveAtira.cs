using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NaveAtira : MonoBehaviour {

    public GameObject tiro;
    public float fireRate = 0.3f;

    public Pooling pooling;

	// Update is called once per frame
	void Update () {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            InvokeRepeating("Tiro", 0, fireRate);
        }
        if (Input.GetKeyUp(KeyCode.Space))
        {
            CancelInvoke();
        }
	}
    void Tiro()
    {
        //Instantiate(tiro, transform.position, Quaternion.identity);
        GameObject possoUsar = pooling.GetPooledObject();
        if(possoUsar != null)
        {
            possoUsar.transform.position = transform.position;
            possoUsar.SetActive(true);
        }
    }
}
