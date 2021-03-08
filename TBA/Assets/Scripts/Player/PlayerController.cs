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

    Vector3 velocity;
    public Transform groundCheck;
    public float groundDistance = 0.5f;
    public LayerMask groundMask;

    bool isGrounded;
    bool onAir;


    // Start is called before the first frame update
    void Start()
    {
        _characterController = GetComponent<CharacterController>();
        _airSpeed = _speed / 2f;

    }

    // Update is called once per frame
    void Update()
    {
        PlayerMovement();
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

        if (onAir == true)
        {
            _speed = _airSpeed;
        }
        else
        {
            _speed = _airSpeed * 2f;
        }

        velocity.y += _gravity * Time.deltaTime;

        _characterController.Move(velocity * Time.deltaTime);
    }

}
