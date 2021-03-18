using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Grenade : MonoBehaviour
{
    // Start is called before the first frame update
    public float delay = 3f;
    public float grenadeDamage = 50f;
    public float explosionRadius = 10f;
    public float grenadeForce = 500f;

    float countdown;
    bool hasExploded = false;

    public GameObject explosionEffect;

    void Start()
    {
        countdown = delay;
    }

    // Update is called once per frame
    void Update()
    {
        countdown -= Time.deltaTime;
        if(countdown <= 0f && !hasExploded){
            Explode();
            hasExploded = true;
        }
    }

    void Explode(){

        Instantiate(explosionEffect, transform.position, transform.rotation);
        
        Collider[] colliders =  Physics.OverlapSphere(transform.position, explosionRadius);
        foreach(Collider nearCollider in colliders){
            //
            EnemyRagdoll enemy = nearCollider.GetComponent<EnemyRagdoll>();
            if(enemy != null){
                enemy.enemyHealth -= grenadeDamage;
                if(enemy.enemyHealth <= 0f){
                    enemy.Die();
                    Collider[] collidersToExplode = Physics.OverlapSphere(transform.position, explosionRadius);
                    foreach(Collider collidersRagdoll in collidersToExplode){
                        Rigidbody ragdolls =  collidersRagdoll.GetComponent<Rigidbody>();
                        if(ragdolls != null){
                            ragdolls.AddExplosionForce(grenadeForce, transform.position, explosionRadius);
                        }

                    }
                }
            }
            //
        }

        // Collider[] collidersToMove =  Physics.OverlapSphere(transform.position, explosionRadius);
        // foreach(Collider nearCollider in colliders){
        //     Rigidbody rigid = nearCollider.GetComponent<Rigidbody>();
        //     if(rigid != null){
        //         rigid.AddExplosionForce(grenadeForce, transform.position, explosionRadius);
        //     }
        // }

        Destroy(gameObject);
    }

    void OnDrawGizmos() {
        Gizmos.color = Color.red;
        
        Gizmos.DrawWireSphere(transform.position, explosionRadius);
        
    }
}
