using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;


public class EnemyController : MonoBehaviour
{

    public float meleeAttackRange = 2f;
    public float rangedAttackRange = 10f;

    public float distance;
    public float attackDistance;

    public Transform playerTarget;
    NavMeshAgent navMeshAgent;

    EnemyRagdoll enemyRagdoll;

    // Start is called before the first frame update
    void Start()
    {
        playerTarget = GameObject.FindGameObjectWithTag("Player").transform;
        navMeshAgent = GetComponent<NavMeshAgent>();
        enemyRagdoll = GetComponent<EnemyRagdoll>();
    }

    // Update is called once per frame
    void Update()
    {
        if(enemyRagdoll.enemyHealth > 0){
            FollowPlayerTarget();
        }else{
            navMeshAgent.enabled = false;
        }
        //FollowPlayerTarget();

        distance = Vector3.Distance(playerTarget.position, transform.position);

    }

    void FollowPlayerTarget(){
        navMeshAgent.SetDestination(playerTarget.position);
    }

    void EnemyAnimations(){
        
    }

    void MeleeAttack(){
        //melee atack animation
    }

    void RangedAttack(){
        //throw energy ball
        navMeshAgent.isStopped = true;
    }

    void OnDrawGizmos() {
        Gizmos.color = Color.yellow;
        Gizmos.DrawWireSphere(transform.position, meleeAttackRange);
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position, rangedAttackRange);
    }
}
