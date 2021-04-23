using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemySpawner : MonoBehaviour
{

    public float spawnTimer;
    public float spawnRepeatTimer;

    public GameObject enemyPrefab;

    // Start is called before the first frame update
    void Start()
    {
        spawnTimer = Random.Range(1,10);
        spawnRepeatTimer = Random.Range(1,30);
        InvokeRepeating("Spawn", spawnTimer, spawnRepeatTimer);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void Spawn(){
        Instantiate(enemyPrefab, transform.position, Quaternion.identity);
    }
}
