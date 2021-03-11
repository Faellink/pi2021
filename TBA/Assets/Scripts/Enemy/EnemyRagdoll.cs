﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyRagdoll : MonoBehaviour
{
    // Start is called before the first frame update

    Rigidbody mainRigidbody;
    Collider mainCollider;
    Animator animator;
    public float enemyHealth = 100f;

    void Start()
    {
        mainRigidbody = GetComponent<Rigidbody>();
        mainCollider = GetComponent<Collider>();
        animator = GetComponent<Animator>();
        SetRigidBodyState(true);
        SetColliders(false);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void Die(){
        //Destroy(gameObject, 10f);
        animator.enabled = false;
        SetRigidBodyState(false);
        SetColliders(true);
    }

    void SetRigidBodyState(bool state){
        Rigidbody[] rigidBodies = GetComponentsInChildren<Rigidbody>();
        foreach(Rigidbody rigidbody in rigidBodies){
            rigidbody.isKinematic = state;
        }
        mainRigidbody.isKinematic = !state;
    }

    void SetColliders(bool state){
        Collider[] colliders = GetComponentsInChildren<Collider>();
        foreach(Collider col in colliders){
            col.enabled = state;
        }
        mainCollider.enabled = !state;
    }
}