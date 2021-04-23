using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using EZCameraShake;
using UnityEngine.UI;

public class PlayerController : MonoBehaviour
{

    CharacterController _characterController;
    [SerializeField]
    float _speed = 5f;
    float _airSpeed = 0;
    public float _gravity = -9.81f;
    public float _jumpForce = 10f;
    public float playerHealth = 100f;

    public static bool playerDied;

    Vector3 velocity;
    public Transform groundCheck;
    public float groundDistance = 0.5f;
    public LayerMask groundMask;

    private Vector3 lastPos = Vector3.zero;

    bool isGrounded;
    bool onAir = false;

    public CameraBobbing cameraBobbing;
    public GameObject posProcessingHitEffect;
    public float postProcessingTimer;

    // public CameraShake cameraShake;
    // public float cameraShakeDuration;
    // public float cameraShakeForce;

    // public HelmetShake helmetShake;
    // public float helmetShakeDuration;
    // public float helmetShakeForce;

    public float cameraShakeMagnitude;
    public float cameraShakeRoughness;
    public float cameraShakeFadeInTime;
    public float cameraShakeFadeOutTime;

    public Animator healthBarAnim;
    public RectTransform healthBar;
    public float hpX;
    public float debugDamage = 10f;




    // Start is called before the first frame update
    void Start()
    {
        _characterController = GetComponent<CharacterController>();
        _airSpeed = _speed / 2f;
        cameraBobbing = GetComponentInChildren<CameraBobbing>();
        healthBar = GameObject.FindGameObjectWithTag("HP").GetComponent<RectTransform>();
        healthBarAnim = GameObject.FindGameObjectWithTag("HP").GetComponent<Animator>();
        // cameraShake = GetComponentInChildren<CameraShake>();
        // helmetShake = GetComponentInChildren<HelmetShake>();
        hpX = 796f;
        onAir = false;
        playerDied = false;
    }

    // Update is called once per frame
    void Update()
    {
        PlayerMovement();
        //
        var dist = Vector3.Distance(transform.position, lastPos);
        lastPos = transform.position;
        if (Time.deltaTime > 0)
        { // avoid errors when game paused
            var speed = dist / Time.deltaTime; // calculate speed
            if (speed > 0.1f)
            {
                //Debug.Log("walking");
                cameraBobbing.isWalking = true;
            }
            else
            {
                //Debug.Log("stop");
                cameraBobbing.isWalking = false;
            }
        }
        // DebugPause();
        // DebugCameraShake();
        // DebugHealthBar();
        if(hpX <= 0 ){
            playerDied = true;
            Debug.Log("dead");
        }

    }

    void PlayerMovement()
    {
        isGrounded = Physics.CheckSphere(groundCheck.position, groundDistance, groundMask);

        if (isGrounded && velocity.y < 0)
        {
            velocity.y = -2f;
            onAir = false;
            //Debug.Log("Player Grounded");
        }

        float moveX = Input.GetAxis("Horizontal");
        float moveZ = Input.GetAxis("Vertical");

        Vector3 direction = transform.right * moveX + transform.forward * moveZ;

        _characterController.Move(direction * _speed * Time.deltaTime);

        if (Input.GetButtonDown("Jump") && isGrounded)
        {
            velocity.y = Mathf.Sqrt(_jumpForce * -2f * _gravity);
            onAir = true;
        }

        // if (onAir == true)
        // {
        //     _speed = _airSpeed;
        // }
        // else
        // {
        //     _speed = _airSpeed * 2f;
        // }

        velocity.y += _gravity * Time.deltaTime;

        _characterController.Move(velocity * Time.deltaTime);
    }

    // void DebugPause()
    // {
    //     if (Input.GetKeyDown(KeyCode.Q))
    //     {
    //         Debug.Break();
    //     }
    // }

    // void DebugCameraShake()
    // {
    //     if (Input.GetKeyDown(KeyCode.T))
    //     {
    //         CameraShaker.Instance.ShakeOnce(cameraShakeMagnitude, cameraShakeRoughness, cameraShakeFadeInTime, cameraShakeFadeOutTime);
    //         posProcessingHitEffect.SetActive(true);
    //     }
    // }

    // void DebugHealthBar()
    // {
    //     if (Input.GetKeyDown(KeyCode.U))
    //     {
    //         hpX -= debugDamage;
    //         healthBar.sizeDelta = new Vector2(hpX, 100);
    //     }
    // }

    void PlayerDamage()
    {

        StartCoroutine(HealthBarAnimationTimer());
        hpX -= debugDamage;
        healthBar.sizeDelta = new Vector2(hpX, 100);

        playerHealth -= debugDamage;

        CameraShaker.Instance.ShakeOnce(cameraShakeMagnitude, cameraShakeRoughness, cameraShakeFadeInTime, cameraShakeFadeOutTime);

        StartCoroutine(PostProcessingHit());

    }

    IEnumerator HealthBarAnimationTimer()
    {
        healthBarAnim.SetBool("DamageOn", true);
        yield return new WaitForSeconds(postProcessingTimer);
        healthBarAnim.SetBool("DamageOn", false);
    }

    IEnumerator PostProcessingHit()
    {
        posProcessingHitEffect.SetActive(true);
        yield return new WaitForSeconds(postProcessingTimer);
        posProcessingHitEffect.SetActive(false);
    }

    void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("EnemyRangedAttack"))
        {
            //playerHealth -= 10f;
            PlayerDamage();
            Destroy(other.gameObject);
            // StartCoroutine(cameraShake.Shake(cameraShakeDuration,cameraShakeForce));
            // StartCoroutine(helmetShake.Shake(helmetShakeDuration,helmetShakeForce));
            //CameraShaker.Instance.ShakeOnce(4f,4f,.1f,1f);
        }

        if(other.gameObject.CompareTag("EnemyMeleeHit")){
            PlayerDamage();
        }
    }

}
