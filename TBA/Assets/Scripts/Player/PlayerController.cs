using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{

    CharacterController _characterController;
    [SerializeField]
    float _speed = 5f;
    float _airSpeed = 0;
    public float _gravity = -9.81f;
    public float _jumpForce = 10f; 
    public float playerHealth = 100f;

    Vector3 velocity;
    public Transform groundCheck;
    public float groundDistance = 0.5f;
    public LayerMask groundMask;

    private Vector3 lastPos= Vector3.zero;

    bool isGrounded;
    bool onAir = false;

    public CameraBobbing cameraBobbing;
    public CameraShake cameraShake;
    public float cameraShakeDuration;
    public float cameraShakeForce;

    public HelmetShake helmetShake;
    public float helmetShakeDuration;
    public float helmetShakeForce;

    // Start is called before the first frame update
    void Start()
    {
        _characterController = GetComponent<CharacterController>();
        _airSpeed = _speed / 2f;
        cameraBobbing = GetComponentInChildren<CameraBobbing>();
        cameraShake = GetComponentInChildren<CameraShake>();
        helmetShake = GetComponentInChildren<HelmetShake>();
        onAir = false;
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
                Debug.Log("walking");
                cameraBobbing.isWalking = true;
            }
            else
            {
                Debug.Log("stop");
                cameraBobbing.isWalking = false;
            }
        }
        DebugPause();
    }

    void PlayerMovement()
    {
        isGrounded = Physics.CheckSphere(groundCheck.position , groundDistance, groundMask);

        if (isGrounded && velocity.y <0)
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

    void DebugPause(){
        if(Input.GetKeyDown(KeyCode.Q)){
            Debug.Break();
        }
    }

    void OnTriggerEnter(Collider other) {
        if(other.gameObject.CompareTag("EnemyRangedAttack")){   
            playerHealth -= 10f;
            Destroy(other.gameObject);
            StartCoroutine(cameraShake.Shake(cameraShakeDuration,cameraShakeForce));
            StartCoroutine(helmetShake.Shake(helmetShakeDuration,helmetShakeForce));
        }    
    }

}
