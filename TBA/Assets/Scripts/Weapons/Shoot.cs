using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Shoot : MonoBehaviour
{

    public float shotdamage = 10f;
    public int randomDamage;

    public float range = 100f;
    public float fireRate = 15f;
    public float  impactForce = 50f;
    float nextTimeToFire = 0f;
    public bool isShooting;
    public bool canShoot;

    public float meleeDamage = 50f;
    public float meleeForce;
    

    public float explosionForce = 500f;
    public float explosionRadius = 10f;

    public Camera fpsCamera;
    public GameObject bulletPrefab;
    public Transform shooter;
    public ParticleSystem muzzleFlash;
    public GameObject hitEffect;

    public Collider[] coliders;

    public Vector3 explosionCenter;

    public Animator weaponAnim;

    public float heat;
    float heatMin = 0f;
    public float heatMax;
    public float heatValue;
    public float cooldown;
    float originalCooldown;
    public bool isOverheated;
    public float overheatTime;

    public Image hearBar;
    public float cooldownSpeed;
    
    public Coroutine overheatCoroutine;



    // Start is called before the first frame update
    void Start()
    {
        fpsCamera = Camera.main;
        weaponAnim = GetComponent<Animator>();
        weaponAnim.SetBool("isMelee", false);
        cooldown = Mathf.Clamp(cooldown,0f,200f);
        originalCooldown = cooldown;
    }

    // Update is called once per frame
    void Update()
    {


        if (Input.GetKey(KeyCode.Mouse0) && Time.time >= nextTimeToFire)
        {
            nextTimeToFire = Time.time + 1f / fireRate;
            ShootWeapon();
            isShooting = true;
            muzzleFlash.Play();
           
        }



        if (Input.GetKeyUp(KeyCode.Mouse0))
        {
            muzzleFlash.Stop();
            isShooting = false;
        }

        WeaponMelee();

        WeaponAnimation();
        
        Cooldown();

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

                foreach (TextMesh enemyDamageText in enemyTexts)
                {
                    enemyDamageText.text = enemy.enemyHealth.ToString();
                }

                if (enemy.enemyHealth <= 0f)
                {
                    enemy.Die();
                    Collider[] enemiesToAddForce = Physics.OverlapSphere(raycastHit.point, explosionRadius);
                    foreach (Collider enemiesToRagdoll in enemiesToAddForce)
                    {
                        Rigidbody ragdollRigid = enemiesToRagdoll.GetComponent<Rigidbody>();
                        if (ragdollRigid != null)
                        {
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

            Grenade enemyBallGrenade = raycastHit.transform.GetComponent<Grenade>();
            if(enemyBallGrenade != null){
                Debug.Log("acertou as bolas!");
                enemyBallGrenade.shooted = true;
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

    void WeaponMelee(){
        
        if(Input.GetKeyDown(KeyCode.F)){
        weaponAnim.Play("Melee");
        }

    }

    void WeaponAnimation(){

        if (weaponAnim.GetCurrentAnimatorStateInfo(0).IsName("Melee"))
        {
            //Debug.Log(weaponAnim.GetCurrentAnimatorStateInfo(0).IsName("Melee"));
            canShoot = false;
        }else{
            canShoot= true;
        }
        weaponAnim.SetBool("isShooting", isShooting);

    }

    void Cooldown()
    {

        if(isShooting == true){
            heat += heatValue;
        }
        
        if(heat > 0){
            heat -= cooldown;
        }

        heat = Mathf.Clamp(heat,heatMin,heatMax);

        if(heat >= heatMax - heatValue){
            
        }
        
        hearBar.fillAmount = heat/heatMax;
        
        //Debug.Log(hearBar.fillAmount);
    }

    


    void OnDrawGizmos() {
        Gizmos.color = Color.yellow;
        Gizmos.DrawWireSphere(explosionCenter, explosionRadius);
    }

    


    private void OnTriggerEnter(Collider other)
    {

        if (other.gameObject.CompareTag("Enemy"))
        {
            Debug.Log("enemy hit");
            EnemyRagdoll enemyMelee = other.gameObject.GetComponent<EnemyRagdoll>();
            enemyMelee.enemyHealth -= meleeDamage;
            enemyMelee.ShowDamage();

            TextMesh[] enemyTexts = enemyMelee.GetComponentsInChildren<TextMesh>();

            foreach (TextMesh enemyDamageText in enemyTexts)
            {
                enemyDamageText.text = enemyMelee.enemyHealth.ToString();
            }

            //

            Collider[] enemiesToAddForce = Physics.OverlapSphere(transform.position, explosionRadius);
            foreach (Collider enemiesToRagdoll in enemiesToAddForce)
            {
                Rigidbody ragdollRigid = enemiesToRagdoll.GetComponent<Rigidbody>();
                if (ragdollRigid != null)
                {
                    ragdollRigid.AddExplosionForce(explosionForce, transform.position, explosionRadius);
                }

            }

        }

        if(other.gameObject.CompareTag("EnemyRangedAttack")){
            Debug.Log("ball hit");
            Rigidbody ballRigidbody = other.gameObject.GetComponent<Rigidbody>();
            ballRigidbody.AddForce(fpsCamera.transform.forward * meleeForce);
        }

    }
}
