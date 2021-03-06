using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Shoot : MonoBehaviour
{

    public float damage = 10f;
    public float range = 100f;
    public float fireRate = 15f;
    public float  impactForce = 50f;
    float nextTimeToFire = 0f;
    bool isShooting;

    public Camera fpsCamera;
    public GameObject bulletPrefab;
    public Transform shooter;
    public ParticleSystem muzzleFlash;

    // Start is called before the first frame update
    void Start()
    {
        fpsCamera = Camera.main;
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKey(KeyCode.Mouse0) && Time.time >= nextTimeToFire)
        {
            nextTimeToFire = Time.time + 1f / fireRate;
            ShootWeapon();
            muzzleFlash.Play();

        }

        if (Input.GetKeyUp(KeyCode.Mouse0))
        {
            muzzleFlash.Stop();
        }
        
    }

    void ShootWeapon()
    {

        InstantiateBullet();
        
      

        RaycastHit raycastHit;
        if(Physics.Raycast(fpsCamera.transform.position, fpsCamera.transform.forward , out raycastHit, range))
        {
            
            Debug.Log(raycastHit.transform.name);
            Damage damage = raycastHit.transform.GetComponent<Damage>();
            if (damage != null)
            {
                damage.TakeDamage(this.damage);
            }

            if( raycastHit.rigidbody != null)
            {
                raycastHit.rigidbody.AddForce(-raycastHit.normal * impactForce);
            }

        }
    }

    void InstantiateBullet()
    {
        Instantiate(bulletPrefab, shooter.position, Quaternion.identity);
    }

}
