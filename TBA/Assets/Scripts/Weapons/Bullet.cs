using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bullet : MonoBehaviour
{

    public float bulletSpeed = 100f;

    public Transform shooter;

    // Start is called before the first frame update
    void Start()
    {
        shooter = GameObject.Find("Shooter").transform;
        transform.up = shooter.forward;
    }

    // Update is called once per frame
    void Update()
    {
        BulletSpeed();
    }

    void BulletSpeed()
    {
        transform.Translate(Vector3.up * Time.deltaTime * bulletSpeed);
    }
}
