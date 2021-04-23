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

    void Spawn()
    {
        if (GameManager.canSpawnEnemies == true)
        {
            //Debug.Log("pode parir");
            Instantiate(enemyPrefab, transform.position, Quaternion.identity);
            GameManager.enemiesCounter++;
        }
        else
        {
            //Debug.Log("fecha as perna");
        }

    }
}
