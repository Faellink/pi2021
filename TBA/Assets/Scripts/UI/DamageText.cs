using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DamageText : MonoBehaviour
{
    public float destroyTime = 2f;
    public Transform playerTarget;

    // Start is called before the first frame update
    void Start()
    {
        playerTarget = GameObject.FindWithTag("Player").transform;
        Destroy(gameObject,destroyTime);
    }

    // Update is called once per frame
    void Update()
    {
        transform.rotation = Quaternion.LookRotation(transform.position - playerTarget.position);
    }
}
