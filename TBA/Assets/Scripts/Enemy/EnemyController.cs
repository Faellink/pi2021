using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;


public class EnemyController : MonoBehaviour
{

    public float meleeAttackRange = 2f;
    public float rangedAttackRange = 10f;

    public int rangedAttackAmmo;
    public int rangedAttackAmmoLimit = 1;

    public int meleeHits;
    public int meleeLimit = 1;
    public int randomMelee;

    

    bool canShoot;
    public bool canMelee;

    public float distance;
    public float attackDistance;

    public Transform playerTarget;
    NavMeshAgent navMeshAgent;

    EnemyRagdoll enemyRagdoll;

    Animator navAgentAnim;


    public SkinnedMeshRenderer skin;
    public Material zombieMaterial;
    public Material zombieMatA;
    public Material zombieMatB;
    public int randomMaterial;

    public GameObject rangedAttackPrefab;

    public Transform rangedAttackShooter;

    public int enemyBehaviour;

    //

    // State state;
    // enum State{
    //     Follow,
    //     AttackRange,
    //     AttackMelee,
    // }

    // Start is called before the first frame update
    void Start()
    {
        skin = GetComponentInChildren<SkinnedMeshRenderer>();
        if (skin==null)
        {
            //Debug.Log("nope");
        }
        randomMaterial = Random.Range(0,2);
        if (randomMaterial == 0)
        {
            //zombieMaterial = zombieMatA;
            skin.material = zombieMatA;
        }
        else
        {
            //zombieMaterial = zombieMatB;
            skin.material = zombieMatB;
        }
        playerTarget = GameObject.FindGameObjectWithTag("Player").transform;
        navMeshAgent = GetComponent<NavMeshAgent>();
        navAgentAnim = GetComponent<Animator>();
        enemyRagdoll = GetComponent<EnemyRagdoll>();
        enemyBehaviour = Random.Range(0, 2);
    }

    // Update is called once per frame
    void Update()
    {

        // if(enemyRagdoll.enemyHealth <= 0){
        //     gameObject.GetComponent<NavMeshAgent>().enabled = false;
        // }

        if (enemyRagdoll.enemyHealth > 0)
        {
            FollowPlayerTarget();
            //state = State.Follow;
        }
        else
        {
            //navMeshAgent.enabled = false;
            gameObject.GetComponent<NavMeshAgent>().enabled = false;
        }

        //FollowPlayerTarget();

        distance = Vector3.Distance(playerTarget.position, transform.position);


        if (enemyRagdoll.enemyHealth > 0)
        {
            transform.LookAt(playerTarget);

            if (enemyBehaviour == 0)
            {
                //ranged

                if (canShoot == false)
                {
                    Invoke("RangedAttackTimer", 0.5f);
                }

                if (distance < rangedAttackRange && canShoot == true)
                {
                    navAgentAnim.SetBool("isRange",true);
                    navMeshAgent.isStopped = true;
                    rangedAttackAmmo = 0;
                    //RangedAttack();
                    //Invoke("RangedAttack", 1f);
                }

            }
            else if (enemyBehaviour == 1)
            {
                //melee

                if (canMelee == false)
                {
                    Invoke("MeleeAttackTimer", 0.5f);
                }

                if (distance < rangedAttackRange && canMelee == true)
                {
                    navMeshAgent.isStopped = true;
                    meleeHits = 0;
                    Invoke("MeleeAttack", 0.5f);
                }

                // if (navAgentAnim.GetCurrentAnimatorStateInfo(0).IsName("Kick") || navAgentAnim.GetCurrentAnimatorStateInfo(0).IsName("Punch"))
                // {
                //     navAgentAnim.SetBool("isMelee", false);
                //     navMeshAgent.isStopped = true;
                // }
                // else
                // {
                //     navMeshAgent.isStopped = false;
                // }

                if (navAgentAnim.GetBool("isMelee"))
                {
                    //Debug.Log("meleedadac");
                    navMeshAgent.isStopped = true;
                
                }
                else
                {
                    navMeshAgent.isStopped = false;
                }
            }
        }


        // if(canShoot == false){
        //     Invoke("RangedAttackTimer", 0.5f);
        // }

        // if(distance <rangedAttackRange && canShoot == true){
        //     navMeshAgent.isStopped = true;
        //     rangedAttackAmmo=0;
        //     //RangedAttack();
        //     Invoke("RangedAttack", 1f);
        // }

        // if(canMelee == false){
        //     Invoke("MeleeAttackTimer", 0.5f);
        // }

        // if (distance < rangedAttackRange && canMelee == true)
        // {
        //     navMeshAgent.isStopped = true;
        //     meleeHits = 0;
        //     Invoke("MeleeAttack", 1f);
        // }

        // if(navAgentAnim.GetCurrentAnimatorStateInfo(0).IsName("EnemyMelee")){
        //     navAgentAnim.SetBool("isMelee", false);
        // }

        //transform.LookAt(playerTarget);

        EnemyAnimations();

        //Debug.Log(navMeshAgent.isStopped);

        // switch (state)
        // {
        //     case State.Follow:
        //         //follow
        //         FollowPlayerTarget();
        //         break;
        //     case State.AttackRange:
        //         //attack ranged

        //         break;
        //     case State.AttackMelee:
        //         //atack melee
        //         break;
        // }

        // if(enemyRagdoll.enemyHealth <= 0){
        //     gameObject.GetComponent<NavMeshAgent>().enabled = false;
        // }

    }

    void FollowPlayerTarget()
    {
        navMeshAgent.SetDestination(playerTarget.position);
    }

    void EnemyAnimations()
    {

        if (enemyRagdoll.enemyHealth > 0)
        {
            if (navMeshAgent.isStopped == true)
            {
                navAgentAnim.SetBool("isWalking", false);
            }
            else
            {
                navAgentAnim.SetBool("isWalking", true);
            }
        }

        //weaponAnim.GetCurrentAnimatorStateInfo(0).IsName("Melee")

    }

    void MeleeAttackTimer()
    {
        canMelee = true;
    }

    void MeleeAttack()
    {
        randomMelee = Random.Range(0, 2);
        
        navAgentAnim.SetInteger("MeleeType",randomMelee);
        if (meleeHits < meleeLimit)
        {
            //Instantiate(rangedAttackPrefab,rangedAttackShooter.position, Quaternion.LookRotation(transform.forward, transform.up));
            navAgentAnim.SetBool("isMelee", true);
            meleeHits++;
            navMeshAgent.isStopped = false;
        }
        canMelee = false;
    }

    void RangedAttackTimer()
    {
        canShoot = true;
    }

    void RangedAttack()
    {
        
        //throw energy ball
        //navMeshAgent.isStopped = true;
        //navMeshAgent.velocity = Vector3.zero;
        //StartCoroutine(RangedAttackCoroutine());
        //Instantiate(rangedAttackPrefab,rangedAttackShooter.position, Quaternion.identity);
        if (rangedAttackAmmo < rangedAttackAmmoLimit)
        {
            Instantiate(rangedAttackPrefab, rangedAttackShooter.position, Quaternion.LookRotation(transform.forward, transform.up));
            rangedAttackAmmo++;
            // navMeshAgent.isStopped = false;
            navMeshAgent.isStopped = navAgentAnim.GetCurrentAnimatorStateInfo(0).IsName("Attack Anim");
        }
        canShoot = false;
    }

    void Walk()
    {
        navMeshAgent.isStopped = false;
        navAgentAnim.SetBool("isWalking", true);
        navAgentAnim.SetBool("isRange", false);
        
    }

    public void OffMelee()
    {
        navAgentAnim.SetBool("isMelee", false);
        Debug.Log("off melee");
    }

    void OnDrawGizmos()
    {
        Gizmos.color = Color.yellow;
        Gizmos.DrawWireSphere(transform.position, meleeAttackRange);
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position, rangedAttackRange);
    }

    IEnumerator RangedAttackCoroutine()
    {
        yield return new WaitForSeconds(2f);
        //Debug.Log("attacking");
        if (rangedAttackAmmo < rangedAttackAmmoLimit)
        {
            Instantiate(rangedAttackPrefab, rangedAttackShooter.position, Quaternion.LookRotation(transform.forward, transform.up));
            rangedAttackAmmo++;
            navMeshAgent.isStopped = false;
        }
    }
}
