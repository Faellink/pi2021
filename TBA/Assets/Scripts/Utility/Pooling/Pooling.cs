using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Pooling : MonoBehaviour {

    public GameObject obj;
    public int startCreated = 10;

    List<GameObject> pooledList = new List<GameObject>();

    public bool willGrow = true;

	// Use this for initialization
	void Start () {
        for (int i = 0; i < startCreated; i++)
        {
           pooledList.Add(Instantiate(obj));
            pooledList[i].SetActive(false);
        }
	}
	
	public GameObject GetPooledObject()
    {
        for (int i = 0; i < pooledList.Count; i++)
        {
            if (!pooledList[i].activeInHierarchy)
            {
                return pooledList[i];
            }
        }

        if (willGrow)
        {
            pooledList.Add(Instantiate(obj));
            return pooledList[pooledList.Count - 1];
        }

        return null;
    }
}
