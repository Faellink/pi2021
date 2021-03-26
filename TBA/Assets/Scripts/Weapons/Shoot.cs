using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Shoot : MonoBehaviour
{

    public float shotdamage = 10f;
    public int randomDamage;

    public float range = 100f;
    public float fireRate = 15f;
    public float  impactForce = 50f;
    float nextTimeToFire = 0f;
    bool isShooting;

    public float explosionForce = 500f;
    public float explosionRadius = 10f;

    public Camera fpsCamera;
    public GameObject bulletPrefab;
    public Transform shooter;
    public ParticleSystem muzzleFlash;
    public GameObject hitEffect;

    public Collider[] coliders;

    public Vector3 explosionCenter;


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

        //InstantiateBullet();
        
      

        RaycastHit raycastHit;
        if(Physics.Raycast(fpsCamera.transform.position, fpsCamera.transform.forward , out raycastHit, range))
        {   
            explosionCenter = raycastHit.point;
            //
            EnemyRagdoll enemy = raycastHit.transform.GetComponent<EnemyRagdoll>();
            if (enemy != null)
            {             
               //enemy.Die();
                enemy.enemyHealth -= shotdamage;
                // randomDamage = Random.Range(10, 26);
                // enemy.enemyHealth -= randomDamage;
                
                //
                

                enemy.ShowDamage();

                TextMesh[] enemyTexts  = enemy.GetComponentsInChildren<TextMesh>();

                foreach(TextMesh enemyDamageText in enemyTexts){
                    enemyDamageText.text = enemy.enemyHealth.ToString();
                }

                if (enemy.enemyHealth <= 0f)
                {
                    enemy.Die();
                    Collider[] enemiesToAddForce = Physics.OverlapSphere(raycastHit.point, explosionRadius);
                    foreach(Collider enemiesToRagdoll in enemiesToAddForce){
                        Rigidbody ragdollRigid = enemiesToRagdoll.GetComponent<Rigidbody>();
                        if(ragdollRigid != null){
                            ragdollRigid.AddExplosionForce(explosionForce, raycastHit.point, explosionRadius);
                        }

                    }
                    
                }
            }
            
            

            //Debug.Log(raycastHit.transform.name);

            Damage damage = raycastHit.transform.GetComponent<Damage>();
            if (damage != null)
            {
                damage.TakeDamage(shotdamage);
            }

            GameObject hitGO =  Instantiate(hitEffect, raycastHit.point, Quaternion.LookRotation(raycastHit.normal));
            Destroy(hitGO, 2f);

            // if( raycastHit.rigidbody != null)
            // {
            //     raycastHit.rigidbody.AddForce(-raycastHit.normal * impactForce);
            // }

        }
    }

    // void InstantiateBullet()
    // {
    //     Instantiate(bulletPrefab, shooter.position, Quaternion.identity);
    // }

  

    void OnDrawGizmos() {
        Gizmos.color = Color.yellow;
        Gizmos.DrawWireSphere(explosionCenter, explosionRadius);
    }
    

}
