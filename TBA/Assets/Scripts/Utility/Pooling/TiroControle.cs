using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TiroControle : MonoBehaviour {

    Rigidbody2D rigid;
    public float velocidade;

	// Use this for initialization
	void OnEnable () {
        rigid = GetComponent<Rigidbody2D>();
        Invoke("MeDestroi", 3);
	}

    void OnDisable()
    {
        CancelInvoke();
    }
	
	// Update is called once per frame
	void Update () {
        rigid.velocity = new Vector2(0,
            velocidade);
	}

    void MeDestroi()
    {
        //Destroy(gameObject);
        gameObject.SetActive(false);
    }
}
