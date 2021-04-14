using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HomingAttack : MonoBehaviour
{

    public Transform playerTarget;
    public float speed;
    public float rotationForce;

    public Rigidbody rigid;

    // Start is called before the first frame update
    void Start()
    {
        playerTarget = GameObject.FindGameObjectWithTag("PlayerTarget").transform;
        rigid = GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void Update()
    {
        Vector3 direction = playerTarget.position - rigid.position;
        direction.Normalize();
        Vector3 rotationAmount = Vector3.Cross(transform.forward, direction);
        rigid.angularVelocity = rotationAmount * rotationForce;
        rigid.velocity = transform.forward * speed;
        float moveY = rigid.velocity.y;
        moveY = 0;
    }
}
