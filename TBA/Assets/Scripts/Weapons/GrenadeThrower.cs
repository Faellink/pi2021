using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GrenadeThrower : MonoBehaviour
{

    public float throwForce = 50f;
    public GameObject grenadePrefab;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if(Input.GetMouseButtonDown(1)){
            ThrowGrenade();
        }
    }

    void ThrowGrenade(){
        GameObject grenade = Instantiate(grenadePrefab, transform.position, transform.rotation);
        Rigidbody rigid = grenade.GetComponent<Rigidbody>();
        rigid.AddForce(transform.forward * throwForce, ForceMode.VelocityChange);
    }
}
